From: =?UTF-8?B?VGltbyBUZXLDpHM=?= <timo.teras@iki.fi>
Subject: Re: still having r8169 woes with XID 18000000
Date: Fri, 04 Jun 2010 20:31:43 +0300
Message-ID: <4C09387F.1050403@iki.fi>
References: <4C08ED47.1030800@iki.fi> <20100604123641.ED8154CD45@orbit.nwl.cc> <4C08F953.1050800@iki.fi> <20100604134351.7981F4CD45@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?ZnJhbsOnb2lzIHJvbWlldQ==?= <romieu@fr.zoreil.com>,
	netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f223.google.com ([209.85.219.223]:38200 "EHLO
	mail-ew0-f223.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750849Ab0FDRbq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jun 2010 13:31:46 -0400
Received: by ewy23 with SMTP id 23so374192ewy.1
        for <netdev@vger.kernel.org>; Fri, 04 Jun 2010 10:31:43 -0700 (PDT)
In-Reply-To: <20100604134351.7981F4CD45@orbit.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/04/2010 04:43 PM, Phil Sutter wrote:
> On Fri, Jun 04, 2010 at 04:02:11PM +0300, Timo Ter=C3=A4s wrote:
>>> Comparing r8169-6.013 with it's predecessor 6.012, you'll find a ne=
wly
>>> enabled function rtl8169_phy_power_up() as well as some more invoca=
tions
>>> of rtl8169_phy_power_down().
>>>
>>> This is probably the solution to these (at least in our case) very
>>> sporadic, but highly annoying, problems. In fact, when our NIC didn=
't
>>> detect any link, it needed a full power-cycle (no success with
>>> reset-button), so almost not workaroundable.
>>
>> Sounds very similar to the problem I have. Thanks for the pointers!
>>
>> It looks like the r8169 driver does have phy power up code in it, bu=
t
>> it's only executed for specific versions of the chip. Realtek driver
>> seems to do it unconditionally.
>=20
> Hmm. I actually never looked at the corresponding parts of the
> in-tree-driver, but that would have definitely been the next step in
> order to fix it.
>=20
>> The check seems to be:
>>                 if ((tp->mac_version =3D=3D RTL_GIGA_MAC_VER_11) ||
>>                     (tp->mac_version =3D=3D RTL_GIGA_MAC_VER_12) ||
>>                     (tp->mac_version >=3D RTL_GIGA_MAC_VER_17)) {
>>
>> I wonder if I should just add my mac version there (_VER_05) and tes=
t if
>> it'll make it better.
>=20
> Surely worth a try. On the other hand, looking at the sheer mass of
> problem reports regarding this driver, making it worse is rather hard=
 to
> do I guess. :)

Ok. The issue is semi-reliably producible with just removing the
kernel driver and reloading it. The problem occurs maybe with 10-20% ch=
ance.

So far, it looks like the phy wakeup does not really help. Adding the
_VER_05 check did not help.

However, removing the specific phy config code
(rtl8169scd_hw_phy_config) which was introduced by commit 2e955856ff
seems to solve it. At least I was not able to reproduce the failure wit=
h
20-30 module reloads.

One more curiosity: if i do a hard power reset, the NIC has green link
indicator led after power up. When loading the kernel module it goes to
orange/red. I wonder why the difference.

- Timo

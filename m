From: Laurent Chavey <chavey@google.com>
Subject: Re: [PATCH 1/1] add ethtool loopback support
Date: Thu, 8 Apr 2010 14:18:38 -0700
Message-ID: <u2w97949e3e1004081418t8d47e25aoe999d29c6409de45@mail.gmail.com>
References: <pvmbpdtn8yh.fsf@chavey.mtv.corp.google.com> <1270751373.5055.22.camel@achroite.uk.solarflarecom.com>
	<4BBE33C9.5000507@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>, davem@davemloft.net,
	netdev@vger.kernel.org, therbert@google.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:34096 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754061Ab0DHVTD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 17:19:03 -0400
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [10.3.21.2])
	by smtp-out.google.com with ESMTP id o38LJ1fP017952
	for <netdev@vger.kernel.org>; Thu, 8 Apr 2010 23:19:01 +0200
Received: from gxk25 (gxk25.prod.google.com [10.202.11.25])
	by hpaq2.eem.corp.google.com with ESMTP id o38LIfQ5018080
	for <netdev@vger.kernel.org>; Thu, 8 Apr 2010 23:19:00 +0200
Received: by gxk25 with SMTP id 25so264694gxk.11
        for <netdev@vger.kernel.org>; Thu, 08 Apr 2010 14:19:00 -0700 (PDT)
In-Reply-To: <4BBE33C9.5000507@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 8, 2010 at 12:51 PM, Jeff Garzik <jeff@garzik.org> wrote:
> On 04/08/2010 02:29 PM, Ben Hutchings wrote:
>>
>> On Thu, 2010-04-08 at 10:35 -0700, chavey@google.com wrote:
>>>
>>> From: Ranjit Manomohan<ranjitm@google.com>
>>> Date: Wed, 7 Apr 2010 15:19:48 -0700
>>>
>>> Add an ethtool option to use internal loopback mode for testing.
>>> This feature is used for component and driver test coverage by putt=
ing
>>> the device in hardware loopback mode and sending / receiving networ=
k
>>> traffic from a user application to test the hardware and driver
>>> transmit / receive paths.
>>>
>>> Signed-off-by: laurent chavey<chavey@google.com>
>>> ---
>>> =A0include/linux/ethtool.h | =A0 16 ++++++++++++++++
>>> =A0net/core/ethtool.c =A0 =A0 =A0| =A0 40 +++++++++++++++++++++++++=
+++++++++++++++
>>> =A02 files changed, 56 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
>>> index b33f316..df1dcc7 100644
>>> --- a/include/linux/ethtool.h
>>> +++ b/include/linux/ethtool.h
>>> @@ -292,6 +292,18 @@ struct ethtool_stats {
>>> =A0 =A0 =A0 =A0__u64 =A0 data[0];
>>> =A0};
>>>
>>> +/* for setting the NIC into loopback mode */
>>> +struct ethtool_loopback {
>>> + =A0 =A0 =A0 u32 cmd; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* ETHTOOL_SL=
OOPBACK */
>>> + =A0 =A0 =A0 u32 type; =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* ethtool_loop=
back_type */
>>> +};
>>> +
>>> +enum ethtool_loopback_type {
>>> + =A0 =A0 =A0 ETH_MAC =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D 0x0000000=
1,
>>> + =A0 =A0 =A0 ETH_PHY_INT =A0 =A0 =A0 =A0 =A0 =A0 =3D 0x00000002,
>>> + =A0 =A0 =A0 ETH_PHY_EXT =A0 =A0 =A0 =A0 =A0 =A0 =3D 0x00000004
>>> +};
>>
>> [...]
>>
>> There are many different places you can loop back within a MAC or PH=
Y,
>> not to mention bypassing the MAC altogether. =A0See
>> drivers/net/sfc/mcdi_pcol.h, starting from the line
>> '#define MC_CMD_LOOPBACK_NONE 0'. =A0I believe we implement all of t=
hose
>> loopback modes on at least one board.
>>
>> Also are these supposed to be an enumeration or flags? =A0In theory =
you
>> could use wire-side and host-side loopback at the same time if they
>> don't overlap, but it's probably too much trouble to bother with. =A0=
Any
>> other combination is meaningless.
>
>
> Additionally, ethtool is intended as an interface that exports capabi=
lities
> generally useful to users. =A0Is this feature really something that u=
sers will
> make use of? =A0It seems more in the realm of design validation
>
> The existing ETHTOOL_TEST ioctl was intended as a coarse-grained meth=
od of
> verifying that the NIC is working, because fine-grained tests are ine=
vitably
> both NIC-specific, and too involved for all but the most sophisticate=
d users
> (read: the designers who built the NIC).
>
> So, consider this a _weak_ objection. =A0Sure we could implement this=
, but
> will it really be useful to most users?

we have some autotests that make use of this feature for e1000(e), forc=
edeth and
tg3 that we would like to share with the community to do perf / functio=
nal tests
regression.
>
> =A0 =A0 =A0 =A0Jeff
>
>
>

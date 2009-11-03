From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] e1000: the power down when running ifdown command
Date: Tue, 3 Nov 2009 13:37:47 -0800
Message-ID: <9929d2390911031337p6115fef0wc1b94e5141ead341@mail.gmail.com>
References: <4AEC05E8.40600@miraclelinux.com>
	 <9929d2390911021626j4a2e4a96neaba49ffd8775dc9@mail.gmail.com>
	 <4AF00097.4040708@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jesse.brandeburg@intel.com, peter.p.waskiewicz.jr@intel.com,
	john.ronciak@intel.com, davem@davemloft.net,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, svaidy@linux.vnet.ibm.com,
	e1000-devel@lists.sourceforge.net
To: Naohiro Ooiwa <nooiwa@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f188.google.com ([209.85.222.188]:39187 "EHLO
	mail-pz0-f188.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754975AbZKCVhm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 16:37:42 -0500
Received: by pzk26 with SMTP id 26so4235948pzk.4
        for <netdev@vger.kernel.org>; Tue, 03 Nov 2009 13:37:47 -0800 (PST)
In-Reply-To: <4AF00097.4040708@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2009/11/3 Naohiro Ooiwa <nooiwa@miraclelinux.com>:
> Jeff Kirsher wrote:
>> 2009/10/31 Naohiro Ooiwa <nooiwa@miraclelinux.com>:
>>
>> I have added this patch to my tree for testing. =C2=A0This patch req=
uires a
>> fair amount of regression testing, so once its passed testing I will
>> push the patch to David/netdev.
>
> I appreciate the marge your tree.
> If there is anything I can do, please let me know.
>
> And I know this patch is good for e100 driver too.
> I would really like to create patch for it.
> How do you think about e100 driver.
>
>
> Thanks,
> Naohiro Ooiwa
>

Patches are always welcome (referring to a e100 patch).

As far as the e1000 patch goes, it has a number of issues which were
found in testing.  Here are just a few problems we saw:
1. ethtool -t - crashes the system
2. ethtool eth0 - always shows link/speed as 1000/Full even when there
is no cable
3. ethtool -s eth0 autoneg on/off - system hang. Sometimes a copper
interface will show up as fiber after this.
4. ethtool -d/-S/-g etc - will corrupt the stats of the interface
while doing ifup/down

So it appears that more needs to be done to the driver to get this to
work as expected.

NAK

--=20
Cheers,
Jeff

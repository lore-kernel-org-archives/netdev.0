From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH] bonding: prevent deadlock on slave store with alb mode
Date: Tue, 24 May 2011 22:51:26 +0200
Message-ID: <4DDC1A4E.6080700@gmail.com>
References: <1306265765-8257-1-git-send-email-nhorman@tuxdriver.com> <20110524200047.GI21309@gospo.rdu.redhat.com> <4DDC116F.8020602@gmail.com> <20110524203714.GG28521@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:38121 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757087Ab1EXUv2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 16:51:28 -0400
Received: by wya21 with SMTP id 21so5307446wya.19
        for <netdev@vger.kernel.org>; Tue, 24 May 2011 13:51:27 -0700 (PDT)
In-Reply-To: <20110524203714.GG28521@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 24/05/2011 22:37, Neil Horman a =E9crit :

>>>> +		return -EINVAL;
>>
>> This will turn a warning into an error.
>>
> Yes, because it should have been an error all along.
>
>> This warning existed for long, but never caused the bonding setup to
>> fail. This patch cause some regression for user space. For example,
>> current ifenslave-2.6 package in Debian doesn't ensure bond is UP
>> before enslaving, because this was never required.
>>
> Thats not a regression, thats the kernel returning an error where it =
should have
> done so all along.  Just because a utility got away with it for awhil=
e and it
> didn't always cause a lockup, doesn't grandfather that application in=
 to a
> situation where the kernel has to support its broken behavior in perp=
ituity.
>
> Besides, iirc, the ifsenslave utility still uses the ioctl path, whic=
h this
> patch doesn't touch, so ifenslave is currently unaffected (although I=
 should
> look in the ioctl path to see if we have already added such a check, =
lest you be
> able to deadlock your system as previously indicated using that tool)=
=2E

Unfortunately, no. Recent versions of ifenslave-2.6 on Debian don't use=
 ioctl (ifenslave binary)=20
anymore, but only sysfs.

Documentation/bonding.txt should be updated to reflect this change.
pr_warning should be changed to pr_ err.
Bonding version should be bumped.

Anyway, I will fix this package, but I suspect there exist many user sc=
ripts that don't ensure bond=20
is up before enslaving.

	Nicolas.

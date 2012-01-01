From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH] bonding: fix error handling if slave is busy (v2)
Date: Sun, 01 Jan 2012 01:28:50 +0100
Message-ID: <4EFFA8C2.9040708@gmail.com>
References: <20111230144023.371be015@nehalam.linuxnetplumber.net>	<4EFF3419.4050504@gmail.com>	<20111231152646.6f0f98fc@nehalam.linuxnetplumber.net>	<4EFFA44E.10507@gmail.com> <20111231161322.40b16d69@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:46906 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750881Ab2AAA2f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Dec 2011 19:28:35 -0500
Received: by wibhm6 with SMTP id hm6so7729937wib.19
        for <netdev@vger.kernel.org>; Sat, 31 Dec 2011 16:28:34 -0800 (PST)
In-Reply-To: <20111231161322.40b16d69@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 01/01/2012 01:13, Stephen Hemminger a =E9crit :
> On Sun, 01 Jan 2012 01:09:50 +0100
> Nicolas de Peslo=FCan<nicolas.2p.debian@gmail.com>  wrote:
>
>> Le 01/01/2012 00:26, Stephen Hemminger a =E9crit :
>>> If slave device already has a receive handler registered, then the
>>> error unwind of bonding device enslave function is broken.
>>>
>>> The following will leave a pointer to freed memory in the slave
>>> device list, causing a later kernel panic.
>>> # modprobe dummy
>>> # ip li add dummy0-1 link dummy0 type macvlan
>>> # modprobe bonding
>>> # echo +dummy0>/sys/class/net/bond0/bonding/slaves
>>>
>>> The fix is to detach the slave (which removes it from the list)
>>> in the unwind path.
>>>
>>> Signed-off-by: Stephen Hemminger<shemminger@vyatta.com>
>>
>> Thanks Stephen.
>>
>> Reviewed-by: Nicolas de Peslo=FCan<nicolas.2p.debian@free.fr>
>
> The locking in bond driver is a tangled web.
>
> Would be cleaner to get rid of bond->lock altogether.
> Slave add/delete should be protected by RTNL, and the lookup should
> be converted to RCU.  The problem is that bonding driver implements
> own form of circular list to handle round-robin etc.

Bonding has become an incredibly complex thing, due to the large number=
 of corner cases it needs to=20
handle. And the locking system in probably part of the problem.

Unfortunately, I'm far from a Linux locking specialist, so I cannot com=
ment on this... I just=20
noticed that searching for RTNL in Documentations yields no result... :=
-(

	Nicolas.

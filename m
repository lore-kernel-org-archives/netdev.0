From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC PATCH] ipv4: release dev refcnt early when destroying inetdev
Date: Fri, 10 Sep 2010 16:57:16 +0200
Message-ID: <4C8A474C.3040502@6wind.com>
References: <4C8A3430.2070105@6wind.com> <1284128679.24675.38.camel@edumazet-laptop>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:38784 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750891Ab0IJO5V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Sep 2010 10:57:21 -0400
Received: by wwb34 with SMTP id 34so861019wwb.1
        for <netdev@vger.kernel.org>; Fri, 10 Sep 2010 07:57:19 -0700 (PDT)
In-Reply-To: <1284128679.24675.38.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 10.09.2010 16:24, Eric Dumazet a =C3=A9crit :
> Le vendredi 10 septembre 2010 =C3=A0 15:35 +0200, Nicolas Dichtel a =C3=
=A9crit :
>> Hi all,
>>
>> We got a scalability problem when we try to remove a lot of virtual =
interfaces.=20
>> After analysis, we found that a refcnt on a device was released too =
late.
>> Here is a proposal patch. If we are not missing something, the refcn=
t can be=20
>> release before call_rcu(). In IPv6, this is already the case.
>>
>> Comments are welcome.
>>
>>
>> Regards,
>> Nicolas
>> pi=C3=A8ce jointe diff=C3=A9rences entre fichiers
>> (0001-ipv4-release-dev-refcnt-early-when-destroying-inetd.patch)
>> From 6fe291ff56b1f94599dfaa57dfb0ed4c168b603f Mon Sep 17 00:00:00 20=
01
>> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>> Date: Fri, 10 Sep 2010 14:52:15 +0200
>> Subject: [PATCH] ipv4: release dev refcnt early when destroying inet=
dev
>>
>> When a virtual device is removed, refcnt on dev is released
>> after rcu barrier, hence we fall always in the msleep(250)
>> of netdev_wait_allrefs(). This causes a long delay when
>> a lot of interfaces are removed.
>> Refcnt can be released before this rcu barrier, this allows
>> to accelerate the removing of virtual interfaces.
>>
>> Test of removing 50 ipip tunnel interfaces:
>>  Before the patch:
>>   real    0m12.804s
>>   user    0m0.020s
>>   sys     0m0.000s
>>
>>  After the patch:
>>   real    0m0.988s
>>   user    0m0.004s
>>   sys     0m0.016s
>>
>> Signed-off-by: Wang Xuefu <xuefu.wang@6wind.com>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>> ---
>=20
> This is a well known problem, (many patches were sent some months ago=
)
> but your patch is not the right solution.
>=20
> As long as the idev is not yet freed, it can be used and we need to
> access idev->dev

Is this not true in IPv6? What is the difference?


Regards,
Nicolas

From: Sergey Popovich <popovich_sergei@mail.ru>
Subject: Re: Using HTB over MultiQ
Date: Thu, 07 Nov 2013 15:49:51 +0200
Message-ID: <15059450.XJdZrMIbNO@tuxracer>
References: <CAEzD07+Haf-Kg52H7GsxC5XiQn2KXozHbxgL4Lvn0grhFXVFmA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fallback8.mail.ru ([94.100.176.136]:38389 "EHLO
	fallback8.mail.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752413Ab3KGPFE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 10:05:04 -0500
Received: from smtp46.i.mail.ru (smtp46.i.mail.ru [94.100.177.106])
	by fallback8.mail.ru (mPOP.Fallback_MX) with ESMTP id 228254431D67
	for <netdev@vger.kernel.org>; Thu,  7 Nov 2013 17:54:14 +0400 (MSK)
Received: from [2a01:6d80:103:13::c3ea:4404] (port=53356 helo=tuxracer.localnet)
	by smtp46.i.mail.ru with esmtpa (envelope-from <popovich_sergei@mail.ru>)
	id 1VeQ1v-0003B2-7F
	for netdev@vger.kernel.org; Thu, 07 Nov 2013 17:53:51 +0400
In-Reply-To: <CAEzD07+Haf-Kg52H7GsxC5XiQn2KXozHbxgL4Lvn0grhFXVFmA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> But I see zero statistics on the leaf htb classes and nonzero
> statistics on the classifier filters:
> 
> ~$ tc -s -p filter list dev eth1
>  ...
>  filter parent 10: protocol ip pref 5 u32 fh 2:f2:800 order 2048 key
> ht 2 bkt f2 flowid 11:1736  (rule hit 306 success 306)
>    match IP src xx.xx.xx.xx/30 (success 306 )
>  ...
> 
> ~$ tc -s -s -d c ls dev eth1 classid 11:1736
>  class htb 11:1736 parent 11:1 leaf 1736: prio 0 quantum 12800 rate
> 1024Kbit ceil 1024Kbit burst 1599b/1 mpu 0b overhead 0b cburst 1599b/1
> mpu 0b overhead 0b level 0
>   Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>   rate 0bit 0pps backlog 0b 0p requeues 0
>   lended: 0 borrowed: 0 giants: 0
>   tokens: 195312 ctokens: 195312
> 
> I think I've lost from view the some aspects of settings.
> Has anyone setuped the like complex scheme over the multiq discipline?

Since

commit 64153ce0a7b61b2a5cacb01805cbf670142339e9
Author: Eric Dumazet
Date:   Thu Jun 6 14:53:16 2013 -0700

    net_sched: htb: do not setup default rate estimators

rate estimators do not setup by default. To enable rate estimators
you could try to load module sch_htb with htb_rate_est=1 
or echo 1 >/sys/module/sch_htb/parameters/htb_rate_est and recreate
hierarchy.

-- 
SP5474-RIPE
Sergey Popovich

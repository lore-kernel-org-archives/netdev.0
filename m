From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: sch_generic: missing u64 in psched_ratecfg_precompute()?
Date: Wed, 27 Mar 2013 07:33:08 -0700
Message-ID: <1364394788.15753.4.camel@edumazet-glaptop>
References: <4306359.Sd6orIF4zo@tuxracer.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Sergey Popovich <popovich_sergei@mail.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:42487 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752094Ab3C0OdL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 10:33:11 -0400
Received: by mail-ie0-f174.google.com with SMTP id aq17so7209180iec.19
        for <netdev@vger.kernel.org>; Wed, 27 Mar 2013 07:33:10 -0700 (PDT)
In-Reply-To: <4306359.Sd6orIF4zo@tuxracer.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-03-27 at 15:00 +0200, Sergey Popovich wrote:
> Hello!
> 
> It seems that commit
> 
>   commit 292f1c7ff6cc10516076ceeea45ed11833bb71c7                                                                                             
>   Author: Jiri Pirko <jiri@resnulli.us>                                                                                                       
>   Date:   Tue Feb 12 00:12:03 2013 +0000                                                                                                      
>                                                                                                                                             
>       sch: make htb_rate_cfg and functions around that generic
> 
> adds little regression.
> 
> Before
> ----
> # tc qdisc add dev eth0 root handle 1: htb default ffff
> # tc class add dev eth0 classid 1:ffff htb rate 5Gbit
> # tc -s class show dev eth0
> class htb 1:ffff root prio 0 rate 5000Mbit ceil 5000Mbit burst 625b cburst 
> 625b 
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0) 
>  rate 0bit 0pps backlog 0b 0p requeues 0 
>  lended: 0 borrowed: 0 giants: 0
>  tokens: 31 ctokens: 31
> 
> After
> ----
> # tc qdisc add dev eth0 root handle 1: htb default ffff
> # tc class add dev eth0 classid 1:ffff htb rate 5Gbit
> # tc -s class show dev eth0
> class htb 1:ffff root prio 0 rate 1544Mbit ceil 1544Mbit burst 625b cburst 
> 625b
>  Sent 5073 bytes 41 pkt (dropped 0, overlimits 0 requeues 0)
>  rate 1976bit 2pps backlog 0b 0p requeues 0
>  lended: 41 borrowed: 0 giants: 0
>  tokens: 1802 ctokens: 1802
> 
> This probably due to lost u64 cast of rate parameter in 
> psched_ratecfg_precompute() (net/sched/sch_generic.c).
> 
> Simple patch attached. Tested and found working for me at least
> on amd64.
> 

Good catch !

Could you send an official patch, with your "Signed-off-by: Sergey
Popovich <popovich_sergei@mail.ru>" ?

Thanks

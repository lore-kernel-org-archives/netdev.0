From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next 1/1] net_sched: Introduce skbmod action
Date: Thu, 08 Sep 2016 09:02:53 -0700
Message-ID: <1473350573.15733.61.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1472386756-23085-1-git-send-email-jhs@emojatatu.com>
         <1472400467.14381.252.camel@edumazet-glaptop3.roam.corp.google.com>
         <b075631d-92cc-d016-3786-aaacb3d5c13a@mojatatu.com>
         <b117fac2-c73f-2d42-3843-52f9717224d9@mojatatu.com>
         <1472494817.14381.267.camel@edumazet-glaptop3.roam.corp.google.com>
         <2a6e36a6-f128-ba9d-4d69-90ff5383fb75@mojatatu.com>
         <68852282-b009-7b5b-6887-1630935b1913@mojatatu.com>
         <1472561089.14381.296.camel@edumazet-glaptop3.roam.corp.google.com>
         <a90c3d11-e1e9-3f58-5400-8b910d707351@mojatatu.com>
         <1473171919.10725.3.camel@edumazet-glaptop3.roam.corp.google.com>
         <6a0f8bfd-97d2-1e08-7ad7-b5791cb4312c@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, daniel@iogearbox.net,
        xiyou.wangcong@gmail.com,
        John Fastabend <john.r.fastabend@intel.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36710 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932496AbcIHQC4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 12:02:56 -0400
Received: by mail-pf0-f194.google.com with SMTP id x24so2679424pfa.3
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2016 09:02:56 -0700 (PDT)
In-Reply-To: <6a0f8bfd-97d2-1e08-7ad7-b5791cb4312c@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-09-08 at 06:38 -0400, Jamal Hadi Salim wrote:
> On 16-09-06 10:25 AM, Eric Dumazet wrote:
> 
> >
> > Just use u16 in the array ?
> >
> > u16 tmpaddr[ETH_ALEN / 2]; /* ether_addr_copy() requirement */
> >
> > ether_addr_copy((u8 *)tmpaddr, eth_hdr(skb)->h_dest);
> > ...
> >
> 
> Ok - thanks Eric. BTW:
> Nobody has answered my other question:
> I can get stats to increment with:
> bstats_update(&d->tcf_bstats, skb);
> but not:
> bstats_cpu_update(this_cpu_ptr(d->common.cpu_bstats), skb);

This simply works for me.

But maybe you read the stats at the wrong place ?

Pleas give us more details, thanks !

lpaa24:~# tc -s action list action mirred ; tc -s -d qd sh dev ifb10

	action order 0: mirred (Egress Redirect to device ifb10) stolen
 	index 3 ref 1 bind 1 installed 18 sec
 	Action statistics:
	Sent 6647111559 bytes 4433436 pkt (dropped 0, overlimits 14473 requeues 0) 
	backlog 0b 0p requeues 0 
qdisc mq 1: root 
 Sent 6394816791 bytes 4225732 pkt (dropped 88025, overlimits 0 requeues 0) 
 backlog 108069552b 71406p requeues 0 
qdisc netem 8016: parent 1:5 limit 100000 delay 50.0ms loss 2%
 Sent 776873149 bytes 513412 pkt (dropped 10766, overlimits 0 requeues 0) 
 rate 721506Kbit 59595pps backlog 6952420b 4594p requeues 0 
qdisc netem 8018: parent 1:7 limit 100000 delay 50.0ms loss 2%
 Sent 1290830041 bytes 852967 pkt (dropped 18497, overlimits 0 requeues 0) 
 rate 1246Mbit 102941pps backlog 76607984b 50616p requeues 0 
qdisc netem 8013: parent 1:2 limit 100000 delay 50.0ms loss 2%
 Sent 783039400 bytes 517411 pkt (dropped 10512, overlimits 0 requeues 0) 
 rate 471897Kbit 38979pps backlog 688870b 455p requeues 0 
qdisc netem 8015: parent 1:4 limit 100000 delay 50.0ms loss 2%
 Sent 715503442 bytes 472806 pkt (dropped 9734, overlimits 0 requeues 0) 
 rate 432373Kbit 35713pps backlog 1627550b 1075p requeues 0 
qdisc netem 8019: parent 1:8 limit 100000 delay 50.0ms loss 2%
 Sent 735599060 bytes 486064 pkt (dropped 9915, overlimits 0 requeues 0) 
 rate 441280Kbit 36448pps backlog 2747910b 1815p requeues 0 
qdisc netem 8017: parent 1:6 limit 100000 delay 50.0ms loss 2%
 Sent 755679663 bytes 499311 pkt (dropped 10130, overlimits 0 requeues 0) 
 rate 445158Kbit 36765pps backlog 2174290b 1439p requeues 0 
qdisc netem 8014: parent 1:3 limit 100000 delay 50.0ms loss 2%
 Sent 689812958 bytes 455833 pkt (dropped 9583, overlimits 0 requeues 0) 
 rate 566772Kbit 46812pps backlog 13988176b 9244p requeues 0 
qdisc netem 8012: parent 1:1 limit 100000 delay 50.0ms loss 2%
 Sent 647479078 bytes 427928 pkt (dropped 8888, overlimits 0 requeues 0) 
 rate 559420Kbit 46207pps backlog 3282352b 2168p requeues 0 

From: Patrick McHardy <kaber@trash.net>
Subject: Re: Question about HFSC atm+man patches
Date: Mon, 24 Nov 2008 15:11:22 +0100
Message-ID: <492AB60A.9050606@trash.net>
References: <49292F54.4020803@ziu.info> <4929632F.3050200@trash.net> <492AB29A.3010601@ziu.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Michal Soltys <soltys@ziu.info>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64385 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751643AbYKXOLc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 09:11:32 -0500
In-Reply-To: <492AB29A.3010601@ziu.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michal Soltys wrote:
> Patrick McHardy wrote:
>> Michal Soltys wrote:
>>> Would such approach be valid and possibly accepted ?
>>
>> We already support generic size adjustment for all qdiscs. I'm
>> not sure about the userspace interface though.
>>
> 
> More about what I have in mind - in april '08 there was set of 8 patches
> -
> http://kerneltrap.org/mailarchive/linux-netdev/2008/4/9/1386524/thread#mid-1386524 
> 
> 
> They added atm adaptation to tbf, htb, cbq and filter's action police.
> The rate table is precalculated in userspace, and depending on tc
> invocation - will be either unaltered, or the times will be set
> according to lengths aligned to atm cells (tc_calc_rtable, in 
> tc/tc_core.c).
> 
> On the kernel's side, rata table is consulted through qdisc_l2t
> function, where overhead and cell_align are taken into account as well.
> 
> Anyway - HFSC wasn't included in that patchset, as it didn't use rate
> table - so what I have in mind is essentially:
> 
> len = hfsc_l2_adapt(q->overhead,qdisc_pkt_len(skb));
> 
> instead of
> 
> len = qdisc_pkt_len(skb);

qdisc_pkt_len already returns an adjusted length based on "size tables".
Check out qdisc_enqueue()/qdisc_enqueue_root() for details.

Is there something missing for overhead calculation?

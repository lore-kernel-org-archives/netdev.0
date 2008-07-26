From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH v2 2/3] net_sched: Add accessor function for packet
	length for qdiscs
Date: Sat, 26 Jul 2008 16:18:44 +0200
Message-ID: <20080726141844.GB2873@ami.dom.local>
References: <20080725105748.GB10399@ff.dom.local> <20080725.035712.33516738.davem@davemloft.net> <20080725113757.GC10399@ff.dom.local> <20080725.044928.261427957.davem@davemloft.net> <488B24E6.4020003@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jussi.kivilinna@mbnet.fi,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:34467 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751886AbYGZORV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jul 2008 10:17:21 -0400
Received: by ug-out-1314.google.com with SMTP id h2so63261ugf.16
        for <netdev@vger.kernel.org>; Sat, 26 Jul 2008 07:17:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <488B24E6.4020003@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 26, 2008 at 03:21:42PM +0200, Patrick McHardy wrote:
> David Miller wrote:
>> From: Jarek Poplawski <jarkao2@gmail.com>
>> Date: Fri, 25 Jul 2008 11:37:57 +0000
>>
>>> On Fri, Jul 25, 2008 at 03:57:12AM -0700, David Miller wrote:
>>>> Even TCP depends upon that NET_XMIT_* return value having some real
>>>> meaning, remember the HTB bug we tracked down last week? :-)
>>> Do you mean this bug you've forgotten to fix yet?
>>
>> I have not forgotten, it is in TODO list. :)
>>
>> I want to also inquire with Patrick about whether he is going to
>> perform the audit in this area which he said he wanted to do :-)
>
> I'm a bit backlogged, so it will take some more time.
>
>> Well, we have patch which fixes the problem for the tester, so we
>> could just merge that and at least have HTB fixed.  But we know there
>> are other instances of the same return value propagation problem and
>> Patrick's audit is sure to turn up other similar turds...

My proposal (as before) is to apply this patch now (it could hit more
people than we know), but I would do small changes yet:
- to do htb_activate() if (cl->un.leaf.q->q.qlen),
- to skip bstats.packets and .bytes updating for anything but
  NET_XMIT_SUCCESS,
so, both things just like in sch_hfsc.

> The other problem that affects all qdiscs supporting actions is
> TC_ACT_QUEUED/TC_ACT_STOLEN getting mapped to NET_XMIT_SUCCESS
> even though the packet is not queued, corrupting upper qdiscs'
> qlen counters.

Why can't we (temporarily) simply check such cl->un.leaf.q->q.qlen
before and after enqueing?

Jarek P.

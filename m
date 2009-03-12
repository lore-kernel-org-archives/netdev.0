From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: DRR example, how to replace SFQ
Date: Thu, 12 Mar 2009 07:25:08 +0000
Message-ID: <20090312072508.GA4104@ff.dom.local>
References: <200903120201.49195.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f178.google.com ([209.85.218.178]:38060 "EHLO
	mail-bw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750835AbZCLHZP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 03:25:15 -0400
Received: by bwz26 with SMTP id 26so63117bwz.37
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2009 00:25:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200903120201.49195.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 12, 2009 at 02:01:49AM +0200, Denys Fedoryschenko wrote:
> If i understand right, it must look like this to simulate SFQ 
> This example with just 2 "queues".
> 
> tc qdisc add dev eth0.100 root handle 1: htb
> 
> tc class add dev eth0.100 parent 1: classid 1:1 htb rate 15Kbit ceil 15Kbit
> 
> tc qdisc add dev eth0.100 parent 1:1 handle 2: drr
> 
> tc class add dev eth0.100 parent 2: classid 2:1 drr quantum 1600
> tc class add dev eth0.100 parent 2: classid 2:2 drr quantum 1600
> 
> tc qdisc add dev eth0.100 parent 2:1 handle 10: bfifo 9000
> tc qdisc add dev eth0.100 parent 2:2 handle 11: bfifo 9000
> 
> tc filter add dev eth0.100 parent 1: protocol ip prio 5 u32 match u32 0 0 
> flowid 1:1
> 
> tc filter add dev eth0.100 parent 2: protocol ip prio 10 handle 1 flow keys 
> dst divisor 2 baseclass 2:1
> 
> Is it correct?

Generally looks OK, but examples from cls_flow changelog could be
followed:

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=e5dfb815181fcb186d6080ac3a091eadff2d98fe

Jarek P.

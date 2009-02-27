From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: pkt_sched: add DRR scheduler, any idea how to use it?
Date: Fri, 27 Feb 2009 10:51:02 +0000
Message-ID: <20090227105102.GE4156@ff.dom.local>
References: <200902261826.17228.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f176.google.com ([209.85.220.176]:40945 "EHLO
	mail-fx0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760163AbZB0KvK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 05:51:10 -0500
Received: by fxm24 with SMTP id 24so980900fxm.37
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2009 02:51:07 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <200902261826.17228.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26-02-2009 17:26, Denys Fedoryschenko wrote:
> I tried
> 
> c qdisc add dev ifb0 handle 1 root htb
> 
> tc class add dev ifb0 classid 1:100 parent 1:0 htb rate 100Kbit ceil 100Kbit
> tc qdisc add dev ifb0 parent 1:100 handle 2 drr
> 
> Packets directed by filter to 1:100, all gots dropped. And even i am adding
> tc class add dev ifb0 parent 2:0 classid 2:1 drr quantum 16384
> 
> or 
> 
> tc class add dev ifb0 parent 2:0 classid 2:0 drr quantum 16384
> 
> or 
> 
> tc class add dev ifb0 parent 2:0 classid 2:1 drr quantum 16384
> tc qdisc add dev ifb0 parent 2:1 handle 3 bfifo limit 10000
> 
> 
> Always it is 
> qdisc drr 2: parent 1:100
>  Sent 0 bytes 0 pkt (dropped 32, overlimits 0 requeues 0)
>  rate 0bit 0pps backlog 0b 0p requeues 0
> 
> Any simple example how to use it?

Something like above plus filters to these classes, so similarly to
HFSC or HTB (but no defaults). You could try to simulate sch_sfq()
behaviour using cls_flow (one class per flow).

Jarek P.

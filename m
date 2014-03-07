From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] pkt_sched: fq: do not hold qdisc lock while allocating
 memory
Date: Fri, 07 Mar 2014 15:02:42 -0800
Message-ID: <1394233362.20149.47.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1394175472.20149.6.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140307.170450.1316250102185751283.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:45806 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752060AbaCGXCo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2014 18:02:44 -0500
Received: by mail-pb0-f48.google.com with SMTP id md12so4767221pbc.7
        for <netdev@vger.kernel.org>; Fri, 07 Mar 2014 15:02:44 -0800 (PST)
In-Reply-To: <20140307.170450.1316250102185751283.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-03-07 at 17:04 -0500, David Miller wrote:

> Eric I think you can simplify things a little further, and in fact I
> think it makes these functions easier to understand.
> 
> The fq_resize() part should just grab the lock around the rehash and
> the update of q->fq_root and q->fq_trees_log.
> 
> fq_change() should only grab the lock around the fq_dequeue() loop
> and the call to qdisc_tree_descrease_qlen().  The rest of this
> function is just validating netlink attributes and looking at state
> that cannot change while we hold RTNL.

Hmm, but all these parameters we change in fq_change() are read by other
cpus doing enqueue()/dequeue().

They are integers, so a race would be not a big deal I guess, but better
add a fat comment then ;)

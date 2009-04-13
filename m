From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: initial congestion window for connections in the listen queue
Date: Tue, 14 Apr 2009 00:54:40 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0904140051100.9234@wrl-59.cs.helsinki.fi>
References: <200904132346.15783.opurdila@ixiacom.com>
 <20090413.142653.267913010.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: opurdila@ixiacom.com, Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:47916 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753546AbZDMVyo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2009 17:54:44 -0400
In-Reply-To: <20090413.142653.267913010.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 13 Apr 2009, David Miller wrote:

> From: Octavian Purdila <opurdila@ixiacom.com>
> Date: Mon, 13 Apr 2009 23:46:15 +0300
> 
> > 
> > A question for the TCP wizards:
> > 
> >>struct sock *tcp_create_openreq_child(struct sock *sk, 
> >>        struct request_sock >*req, struct sk_buff *skb)
> >>{
> >>...
> >>         /* So many TCP implementations out there (incorrectly) count the
> >>          * initial SYN frame in their delayed-ACK and congestion control
> >>          * algorithms that we must have the following bandaid to talk 
> >>          * efficiently to them.  -DaveM
> >>          */
> >>          newtp->snd_cwnd = 2;
> > 
> > Shouldn't the same logic from tcp_init_cwnd() be used here?
> > 
> >>From my traces, this seems to prevent TSO from helping short lived 
> > connections.
> 
> On any standard ethernet MTU or larger, you should be getting
> an initial CWND of 3 or 4 because of the logic in tcp_init_cwnd().
> 
> Don't just guesstimate what initial ->snd_cwnd value the
> kernel is using by looking casually at tcpdump traces.  Add
> some kernel debugging printk's and find out for sure.

A long-standing feature in tcp_init_metrics() is such that any of its goto 
reset prevents call to tcp_init_cwnd(). I never remembered to fix that.

-- 
 i.

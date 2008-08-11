From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: qdisc and down links (regression)
Date: Mon, 11 Aug 2008 10:34:05 -0700
Message-ID: <20080811103405.7c096f6d@extreme>
References: <20080807.154735.148985698.davem@davemloft.net>
	<20080807.185024.155026077.davem@davemloft.net>
	<20080808143201.009caf54@extreme>
	<20080808.232427.227852834.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vgr.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:40525 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751680AbYHKReI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Aug 2008 13:34:08 -0400
In-Reply-To: <20080808.232427.227852834.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 08 Aug 2008 23:24:27 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <stephen.hemminger@vyatta.com>
> Date: Fri, 8 Aug 2008 14:32:01 -0700
> 
> > It fixes it for qdisc but not for ingress filters
> > 
> > # tc qdisc add dev eth0 handle ffff: ingress
> > # tc filter add dev eth0 parent ffff: protocol ip \
> >    prio 50 u32 match ip src 0.0.0.0/0 police rate 800kbit burst 10k drop flowid :1
> > RTNETLINK answers: Invalid argument
> > We have an error talking to the kernel
> > 
> > Another problem is that the ingress qdisc can no longer be deleted
> > successfully.
> 
> These problems should be fixed by the following patch which
> I've just pushed to net-2.6:
> 
> pkt_sched: Fix ingress deletion and filter attachment.
> 
> Based upon bug reports by Stephen Hemminger.
> 
> We still had some cases using ->qdisc instead of ->qdisc_sleeping.
> 
> Also, qdisc_lookup() should return ingress qdiscs.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>

Thanks, all fixed.

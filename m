From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: qdisc and down links (regression)
Date: Fri, 8 Aug 2008 14:32:01 -0700
Message-ID: <20080808143201.009caf54@extreme>
References: <20080807143036.1ae10482@extreme>
 <20080807.154735.148985698.davem@davemloft.net>
 <20080807.185024.155026077.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vgr.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:35324 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755040AbYHHVcE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Aug 2008 17:32:04 -0400
In-Reply-To: <20080807.185024.155026077.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 07 Aug 2008 18:50:24 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: David Miller <davem@davemloft.net>
> Date: Thu, 07 Aug 2008 15:47:35 -0700 (PDT)
> 
> > From: Stephen Hemminger <stephen.hemminger@vyatta.com>
> > Date: Thu, 7 Aug 2008 14:30:36 -0700
> > 
> > > Before the mulitqueue changes in 2.6.27-rc it was possible to setup
> > > queueing disciplines before the link came up (carrier active). This
> > > no longer works. If link is down, the qdisc is the noop_qdisc and
> > > any configuration changes don't seem to be shown.
> > 
> > I'll see why this happens, it wasn't an intentional change.
> 
> This should fix it, let me know if it doesn't:

It fixes it for qdisc but not for ingress filters

# tc qdisc add dev eth0 handle ffff: ingress
# tc filter add dev eth0 parent ffff: protocol ip \
   prio 50 u32 match ip src 0.0.0.0/0 police rate 800kbit burst 10k drop flowid :1
RTNETLINK answers: Invalid argument
We have an error talking to the kernel

Another problem is that the ingress qdisc can no longer be deleted
successfully.

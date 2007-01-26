From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6: Implement RFC 4429 Optimistic Duplicate Address
 Detection
Date: Sat, 27 Jan 2007 00:44:29 +0900 (JST)
Message-ID: <20070127.004429.96717403.yoshfuji@linux-ipv6.org>
References: <20070125212651.GB12136@hmsreliant.homelinux.net>
	<45B92BA5.1050505@hp.com>
	<20070126142730.GA15916@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, sri@us.ibm.com, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	kaber@coreworks.de, netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:47069 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030626AbXAZPnR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jan 2007 10:43:17 -0500
In-Reply-To: <20070126142730.GA15916@hmsreliant.homelinux.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20070126142730.GA15916@hmsreliant.homelinux.net> (at Fri, 26 Jan 2007 09:27:30 -0500), Neil Horman <nhorman@tuxdriver.com> says:

> I'm looking for it at the moment, but I too had assumed that redirecting the
> outgoing packet to the default router would happen automatically within the
> routing code as a result of not having a completed neighbor entry available.
> Since I've modified ndisc_send_ns such that we will never send Neighbor
> solicitations from an optimistic address, as per section 3.2, we'll never get a
> completed neightbor entry while the address is optimistic.  If thats not the
> case, I'd welcome some suggestions on how to implement this (given that I'm not
> overly familiar with the code right now).  From what I see, I think the routing
> code will select the default route when rti6_nexthop is null during route
> selection, which it will be if the neighbor entry doesn't get resolved.  Not
> 100% sure though.  Let me know what you think.

(Now I remember that I hit similar issue before when I once
tried to implement this....)

Well... no, you cannot assume that routing code solves this issue.
This is not so trivial, and I am not aware clean solution yet...

On reason of this issue is because the source address may not be
probided by user, and the source address selection will be done
after looking up routing table.

One possibiliy is to solve by rt->rt6i_nexthop->output(),
but I guess we will hit some race condition.

Hmm...

--yoshfuji

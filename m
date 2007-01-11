From: Gavin McCullagh <gavin.mccullagh@nuim.ie>
Subject: Re: fixing opt-ack DoS against TCP stack
Date: Thu, 11 Jan 2007 13:19:08 +0000
Message-ID: <20070111131908.GS31536@nuim.ie>
References: <20070109103718.GE31536@nuim.ie> <20070109112656.1d6ee9ba@freekitty>
Reply-To: Gavin McCullagh <gavin.mccullagh@nuim.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Cc: David Malone <David.Malone@nuim.ie>,
	Douglas Leith <doug.leith@nuim.ie>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.nuim.ie ([149.157.1.19]:55404 "EHLO LARCH.MAY.IE"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030352AbXAKNTL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jan 2007 08:19:11 -0500
Received: from retina-bcl.hamilton.local ([149.157.192.252])
 by NUIM.IE (PMDF V6.2-X17 #30789) with ESMTPA id <01MBSYVX1KWQ00YBY6@NUIM.IE>
 for netdev@vger.kernel.org; Thu, 11 Jan 2007 13:19:32 +0000 (GMT)
In-reply-to: <20070109112656.1d6ee9ba@freekitty>
To: netdev@vger.kernel.org
Content-disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

[ moving this to netdev as requested ]

On Tue, 09 Jan 2007, Stephen Hemminger wrote:

> Actually, this paper seems to be a zombified version of:
> 	http://www.cs.ucsd.edu/~savage/papers/CCR99.pdf

Thanks.  In fairness to them, the emphasis is slightly different, Savage et
al are more interested in improving a receiver's performance, whereas
Sherwood seems more interested in a DoS attack.  However...

> It is not clear that current Linux systems are prone to the attack for a
> couple of reasons. First, Linux does more counts packets not bytes so
> extra ack's would be ignored. Turning on ABC would also help.

The issue I'm raising is not as much how you could artifically increase
Cwnd by dividing ACKs or sending them early.  The issue as I see it is that
if the receiver doesn't send dup acks, the sender never backs off and may
eventually flood its own link.  As the receiver need only ACK the odd
packet, the amplification can be substantial.

As this issue is already moreorless solved (in the research sense), I'm not
keen to spend a lot of time writing it up.  So, here's a quick throw
together of a small example experiment I ran yesterday.

	http://www.hamilton.ie/gavinmc/drop_dupack_attack/

> Lastly, the patch looks like it could cause more problems. It probably would
> break some application and other non-attacking TCP stacks. For this case, IMHO
> we need to wait for more research. If you want to pursue the problem, it needs
> to go through the RFC process.

I must admit I didn't read the patch in detail.  As I understand it, the
fix should (in principal) be compatible with other TCP stacks who should
just see an odd extra dropped packet and react with a duplicate ack as
usual.

Gavin


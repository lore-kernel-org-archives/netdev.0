From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 3/4] llc: use a device based hash table to speed up
 multicast delivery
Date: Thu, 3 Dec 2009 16:37:28 -0800
Message-ID: <20091203163728.44a9c0f1@nehalam>
References: <1259879498-27860-1-git-send-email-opurdila@ixiacom.com>
	<1259879498-27860-4-git-send-email-opurdila@ixiacom.com>
	<20091203152513.643c471a@nehalam>
	<200912040153.11395.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46668 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754560AbZLDAhm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2009 19:37:42 -0500
In-Reply-To: <200912040153.11395.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 4 Dec 2009 01:53:11 +0200
Octavian Purdila <opurdila@ixiacom.com> wrote:

> On Friday 04 December 2009 01:25:13 you wrote:
> > On Fri,  4 Dec 2009 00:31:37 +0200
> > 
> > Octavian Purdila <opurdila@ixiacom.com> wrote:
> > > This patch adds a per SAP device based hash table to solve the
> > > multicast delivery scalability issues for the case where the are a
> > > large number of interfaces and a large number of sockets (bound to the
> > > same SAP) are used.
> > 
> > Rather than adding hash table and rwlock, why not hash list RCU
> > and a single spin lock
> > 
> 
> I have a partial version with RCU and single spinlock, but then I ran into a 
> (Eric's I think) patch which moved the UDP lock per bucket. And since RCU 
> can't help on the write side (in this instance each time we bound or delete 
> the socket) it was not clear to me what is the best approach.

The lock is held for such a brief period on connection setup that a single
spinlock is probably ok.

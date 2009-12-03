From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH 3/4] llc: use a device based hash table to speed up multicast delivery
Date: Fri, 4 Dec 2009 01:53:11 +0200
Message-ID: <200912040153.11395.opurdila@ixiacom.com>
References: <1259879498-27860-1-git-send-email-opurdila@ixiacom.com> <1259879498-27860-4-git-send-email-opurdila@ixiacom.com> <20091203152513.643c471a@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:28039 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754990AbZLCX4U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 18:56:20 -0500
In-Reply-To: <20091203152513.643c471a@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 04 December 2009 01:25:13 you wrote:
> On Fri,  4 Dec 2009 00:31:37 +0200
> 
> Octavian Purdila <opurdila@ixiacom.com> wrote:
> > This patch adds a per SAP device based hash table to solve the
> > multicast delivery scalability issues for the case where the are a
> > large number of interfaces and a large number of sockets (bound to the
> > same SAP) are used.
> 
> Rather than adding hash table and rwlock, why not hash list RCU
> and a single spin lock
> 

I have a partial version with RCU and single spinlock, but then I ran into a 
(Eric's I think) patch which moved the UDP lock per bucket. And since RCU 
can't help on the write side (in this instance each time we bound or delete 
the socket) it was not clear to me what is the best approach.

Should I go ahead with the RCU and single lock?


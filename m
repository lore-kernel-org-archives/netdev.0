From: Brent Cook <bcook@bpointsys.com>
Subject: Re: Question about David's blog entry for NetCONF 2006, Day 1
Date: Fri, 22 Sep 2006 10:47:55 -0500
Message-ID: <200609221047.55238.bcook@bpointsys.com>
References: <45130EF2.2090509@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 70-253-197-251.ded.swbell.net ([70.253.197.251]:9326 "EHLO
	bpointsys.com") by vger.kernel.org with ESMTP id S964770AbWIVPry
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Sep 2006 11:47:54 -0400
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <45130EF2.2090509@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 21 September 2006 17:15, Rick Jones wrote:
> I was reading David's blog entries on the netdev meeting in Japan, and
>
> have a question about this bit:
> > Currently, things like Xen have to put the card into promiscuous
> > mode, accepting all packets, which is quite inefficient.
>
> Is the inefficient bit meant for accepting all packets, or more broadly
> that the promiscuous path is quite inefficient compared to the
> non-promiscuous path?
>
> I ask because I would have thought that if the system were connected to
> a switch (*), the number of packets received through a NIC in
> promiscuous mode would be nearly the same as when it was not in
> promiscuous mode - the delta being (perhaps) multicast frames.
>
> rick jones
>
> (*) "Today," it seems 99 times out of 10 systems are connected to
> switches not hubs.

It depends on how good your switch is. Say you have a bank of 8 servers on a 
8-port switch, each running 16 Xen instances with virtual NICs and different 
MAC addresses. If the switch does not have enough resources in its MAC table 
(likely for an 8-port switch) to cache 136 entries (8 * (16 + 1) mac 
addresses), it will broadcast any packet that is not in the cache to every 
port on the switch, effectively making the switch into a hub for certain 
usage patterns.

Of course, this is an argument for getting a better switch, but the 
possibility of virtual MAC addresses might cause some surprising resource 
utilization problems for network administrators who are used to counting 
physical ports.

 - Brent

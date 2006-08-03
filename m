From: stephen@dino.dnsalias.com (Stephen J. Bevan)
Subject: [patch] RFC: matching interface groups
Date: Wed, 2 Aug 2006 21:08:07 -0700
Message-ID: <17617.30375.336813.199864@localhost.localdomain>
References: <1154452209.6395.77.camel@bzorp.balabit>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from S010600014e000000.vc.shawcable.net ([70.79.40.36]:52204 "EHLO
	dino.dnsalias.com") by vger.kernel.org with ESMTP id S932337AbWHCEIa
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 00:08:30 -0400
To: Balazs Scheidler <bazsi@balabit.hu>
In-Reply-To: <1154452209.6395.77.camel@bzorp.balabit>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Balazs Scheidler writes:
 > I would like to easily match a set of dynamically created interfaces
 > from my packet filter rules. The attached patch forms the basis of my
 > implementation and I would like to know whether something like this is
 > mergeable to mainline.
[snip]
 > The implementation:
 > 
 > Each interface can belong to a single "group" at a time, an interface
 > comes up without being a member in any of the groups.

You can get a similar effect by (ab)using the iflink field i.e. set
the iflink to the parent interface and modify
ip_tables.c:ip_packet_match to check the ifindex (or iflink if
defined) for a match.  An advantage of this is that it doesn't require
adding any new fields and the only kernel change is to
ip_tables.c:ip_packet_match (and its caller).  That said, an explicit
group (or zone as various firewall vendors call it) is cleaner.

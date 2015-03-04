From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 0/7] Basic MPLS support take 2
Date: Tue, 03 Mar 2015 19:06:39 -0600
Message-ID: <87vbihtvts.fsf_-_@x220.int.ebiederm.org>
References: <874mq22imc.fsf_-_@x220.int.ebiederm.org>
	<20150303.144509.1694022322984204895.davem@davemloft.net>
	<87mw3tzv8u.fsf@x220.int.ebiederm.org>
	<20150303.153310.624302583835136622.davem@davemloft.net>
	<87h9u1y8y8.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, roopa <roopa@cumulusnetworks.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	santiago@crfreenet.org, Simon Horman <horms@verge.net.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:59365 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757887AbbCDBKY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 20:10:24 -0500
In-Reply-To: <87h9u1y8y8.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Tue, 03 Mar 2015 17:09:35 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On top of my two pending neighbour table prep patches here is the mpls
support refactored to use them, and edited to not drop routes when
an interface goes down.  Additionally the addition of RTA_LLGATEWAY
has been replaced with the addtion of RTA_VIA.  RTA_VIA being an
attribute that includes the address family as well as the address
of the next hop.

MPLS is at it's heart simple and I have endeavoured to maintain that
simplicity in my implemenation.

This is an implementation of a RFC3032 forwarding engine, and basic MPLS
egress logic.  Which should make linux sufficient to be a mpls
forwarding node or to be a LSA (Label Switched Router) as it says in all
of the MPLS documents.  The ingress support will follow but it deserves
it's own discussion so I am pushing it separately.

Eric W. Biederman (7):
      mpls: Refactor how the mpls module is built
      mpls: Basic routing support
      mpls: Add a sysctl to control the size of the mpls label table
      mpls: Basic support for adding and removing routes
      mpls: Functions for reading and wrinting mpls labels over netlink
      mpls: Netlink commands to add, remove, and dump routes
      mpls: Multicast route table change notifications

 Documentation/networking/mpls-sysctl.txt |  20 +
 include/linux/socket.h                   |   2 +
 include/net/net_namespace.h              |   4 +
 include/net/netns/mpls.h                 |  17 +
 include/uapi/linux/rtnetlink.h           |  10 +
 net/Makefile                             |   2 +-
 net/mpls/Kconfig                         |  23 +-
 net/mpls/Makefile                        |   1 +
 net/mpls/af_mpls.c                       | 974 +++++++++++++++++++++++++++++++
 net/mpls/internal.h                      |  59 ++
 10 files changed, 1110 insertions(+), 2 deletions(-)

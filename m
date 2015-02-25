From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 0/8] Basic MPLS support
Date: Wed, 25 Feb 2015 11:09:23 -0600
Message-ID: <87pp8xx6ik.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, roopa <roopa@cumulusnetworks.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	santiago@crfreenet.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:53634 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752166AbbBYRM5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 12:12:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


While trying to figure out what MPLS is and why MPLS support is not in
the kernel on a lark I sat down and wrote an MPLS implemenation, so I
could answer those questions for myself.

>From what I can tell the short answer is MPLS is trivial-simple and the
we don't have an in-kernel implementation because no one has sat down
and done the work to have a good mergable implementation.

MPLS has it's good sides and it's bad sides but at the end of the day
MPLS has users, and having an in-kernel implementation should help us
understand MPLS and focus our conversations dealing with MPLS and
VRFs.

Having MPLS in our toolkit as the entire world begins playing with
overlay networks aka ``network virtualization'' to support VM and
container migration seems appropriate as MPLS is the historical solution
to this problem.

Constructive criticism about the netlink interface is especially
appreciated.  Hopefully we can have at least one protocol in the kernel
where the netlink interface doesn't have nasty corner case.

As for linux users.  The conversations I had at netdev01 this sounds
like a case of if I build it people will use the code.

Eric

Eric W. Biederman (8):
      mpls: Refactor how the mpls module is built
      mpls: Basic routing support
      mpls: Add a sysctl to control the size of the mpls label table
      mpls: Basic support for adding and removing routes
      mpls: Functions for reading and wrinting mpls labels over netlink
      mpls: Netlink commands to add, remove, and dump routes
      mpls: Multicast route table change notifications
      ipmpls: Basic device for injecting packets into an mpls tunnel

 Documentation/networking/mpls-sysctl.txt |  20 +
 include/linux/socket.h                   |   2 +
 include/net/net_namespace.h              |   4 +
 include/net/netns/mpls.h                 |  17 +
 include/uapi/linux/if_arp.h              |   1 +
 include/uapi/linux/rtnetlink.h           |   4 +
 net/Makefile                             |   2 +-
 net/mpls/Kconfig                         |  28 +-
 net/mpls/Makefile                        |   2 +
 net/mpls/af_mpls.c                       | 919 +++++++++++++++++++++++++++++++
 net/mpls/internal.h                      |  59 ++
 net/mpls/ipmpls.c                        | 219 ++++++++
 12 files changed, 1275 insertions(+), 2 deletions(-)

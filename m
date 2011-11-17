From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 1/2] net: add network priority cgroup infrastructure
Date: Thu, 17 Nov 2011 06:56:31 -0500
Message-ID: <20111117115630.GA21527@hmsreliant.think-freely.org>
References: <1321476666-8225-1-git-send-email-nhorman@tuxdriver.com>
 <1321476666-8225-2-git-send-email-nhorman@tuxdriver.com>
 <4EC4EF46.7010009@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Love, Robert W" <robert.w.love@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:50000 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756906Ab1KQL5V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 06:57:21 -0500
Content-Disposition: inline
In-Reply-To: <4EC4EF46.7010009@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 17, 2011 at 03:25:58AM -0800, John Fastabend wrote:
> On 11/16/2011 12:51 PM, Neil Horman wrote:
> > This patch adds in the infrastructure code to create the network priority
> > cgroup.  The cgroup, in addition to the standard processes file creates two
> > control files:
> > 
> > 1) prioidx - This is a read-only file that exports the index of this cgroup.
> > This is a value that is both arbitrary and unique to a cgroup in this subsystem,
> > and is used to index the per-device priority map
> > 
> > 2) priomap - This is a writeable file.  On read it reports a table of 2-tuples
> > <name:priority> where name is the name of a network interface and priority is
> > indicates the priority assigned to frames egresessing on the named interface and
> > originating from a pid in this cgroup
> > 
> > This cgroup allows for skb priority to be set prior to a root qdisc getting
> > selected. This is benenficial for DCB enabled systems, in that it allows for any
> > application to use dcb configured priorities so without application modification
> > 
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> > Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> > CC: Robert Love <robert.w.love@intel.com>
> > CC: "David S. Miller" <davem@davemloft.net>
> > ---
> >  include/linux/cgroup_subsys.h |    8 +
> >  include/linux/netdevice.h     |    4 +
> >  include/net/netprio_cgroup.h  |   66 ++++++++
> >  include/net/sock.h            |    3 +
> >  net/Kconfig                   |    7 +
> >  net/core/Makefile             |    1 +
> >  net/core/dev.c                |   13 ++
> >  net/core/netprio_cgroup.c     |  340 +++++++++++++++++++++++++++++++++++++++++
> >  net/core/sock.c               |   22 +++-
> >  net/socket.c                  |    2 +
> >  10 files changed, 465 insertions(+), 1 deletions(-)
> >  create mode 100644 include/net/netprio_cgroup.h
> >  create mode 100644 net/core/netprio_cgroup.c
> > 
> 
> Hi Neil,
> 
> couple more comments.
> 
Thanks John, I'll fix these points up and post a v2 later today.
Neil

> 

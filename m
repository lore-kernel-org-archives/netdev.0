From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 1/2] net: add network priority cgroup infrastructure (v2)
Date: Fri, 18 Nov 2011 06:50:36 -0500
Message-ID: <20111118115036.GB7907@hmsreliant.think-freely.org>
References: <1321476666-8225-1-git-send-email-nhorman@tuxdriver.com>
 <1321566472-28969-1-git-send-email-nhorman@tuxdriver.com>
 <1321566472-28969-2-git-send-email-nhorman@tuxdriver.com>
 <4EC5CE48.8020603@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Love, Robert W" <robert.w.love@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:41947 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753310Ab1KRLul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2011 06:50:41 -0500
Content-Disposition: inline
In-Reply-To: <4EC5CE48.8020603@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 17, 2011 at 07:17:28PM -0800, John Fastabend wrote:
> On 11/17/2011 1:47 PM, Neil Horman wrote:
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
> 
> one more nit... can we convert the rcu_dereference() into rtnl_dereference()
> where it is relevant?
> 
Yeah, I'm sorry, I thought you had typo'ed that, I didn't realize we actualy had
a rtnl specific variant of the rcu_dereference macro.  I'll take care of it
today.
Neil

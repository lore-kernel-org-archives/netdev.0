From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: net: Add network priority cgroup
Date: Mon, 14 Nov 2011 06:47:00 -0500
Message-ID: <20111114114700.GA27284@hmsreliant.think-freely.org>
References: <1320868655-32592-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Robert Love <robert.w.love@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:56565 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752091Ab1KNLrI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 06:47:08 -0500
Content-Disposition: inline
In-Reply-To: <1320868655-32592-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 09, 2011 at 02:57:33PM -0500, Neil Horman wrote:
> Data Center Bridging environments are currently somewhat limited in their
> ability to provide a general mechanism for controlling traffic priority.
> Specifically they are unable to administratively control the priority at which
> various types of network traffic are sent.
>  
> Currently, the only ways to set the priority of a network buffer are:
> 
> 1) Through the use of the SO_PRIORITY socket option
> 2) By using low level hooks, like a tc action
> 
> (1) is difficult from an administrative perspective because it requires that the
> application to be coded to not just assume the default priority is sufficient,
> and must expose an administrative interface to allow priority adjustment.  Such
> a solution is not scalable in a DCB environment
> 
> (2) is also difficult, as it requires constant administrative oversight of
> applications so as to build appropriate rules to match traffic belonging to
> various classes, so that priority can be appropriately set. It is further
> limiting when DCB enabled hardware is in use, due to the fact that tc rules are
> only run after a root qdisc has been selected (DCB enabled hardware may reserve
> hw queues for various traffic classes and needs the priority to be set prior to
> selecting the root qdisc)
> 
> 
> I've discussed various solutions with John Fastabend, and we saw a cgroup as
> being a good general solution to this problem.  The network priority cgroup
> allows for a per-interface priority map to be built per cgroup.  Any traffic
> originating from an application in a cgroup, that does not explicitly set its
> priority with SO_PRIORITY will have its priority assigned to the value
> designated for that group on that interface.  This allows a user space daemon,
> when conducting LLDP negotiation with a DCB enabled peer to create a cgroup
> based on the APP_TLV value received and administratively assign applications to
> that priority using the existing cgroup utility infrastructure.
> 
> Tested by John and myself, with good results
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> CC: John Fastabend <john.r.fastabend@intel.com>
> CC: Robert Love <robert.w.love@intel.com>
> CC: "David S. Miller" <davem@davemloft.net>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

Bump, any other thoughts here?  Dave T. has some reasonable thoughts regarding
the use of skb->priority, but IMO they really seem orthogonal to the purpose of
this change.  Any other reviews would be welcome.

John, Robert, if you're supportive of these changes, some Acks would be
appreciated.


Regards
Neil

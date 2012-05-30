From: Eldad Zack <eldad@fogrefinery.com>
Subject: Re: [PATCH] 8021q/vlan: process NETDEV_GOING_DOWN
Date: Wed, 30 May 2012 21:11:02 +0200 (CEST)
Message-ID: <alpine.DEB.2.02.1205302055140.1587@debianer>
References: <1338330635-27259-1-git-send-email-eldad@fogrefinery.com> <20120529.204040.644013889059321702.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120529.204040.644013889059321702.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Tue, 29 May 2012, David Miller wrote:
> From: Eldad Zack <eldad@fogrefinery.com>
> Date: Wed, 30 May 2012 00:30:35 +0200
> 
> > In the current flow, when you take down a physical device that has
> > VLANs configured on it, the NETDEV_GOING_DOWN notification will be
> > sent too late, i.e., no data can be sent to the wire anymore.
> 
> Why do you need to send data?  Any queued up data should be purged not
> sent.

In case a certain protocol needs to send a "dying gasp" packet, when you 
administrativly shutdown the port (which is also what happens when you 
restart the machine).

I'm working on an implementation of such protocol (LLDP) on my free 
time. The specification says that it should send a (compact) shutdown 
message, with the TTL field set to zero, so that other stations are informed
of the shutdown - and it works fine with the main interface, but not with 
VLANs, since the notifier is called too late.
With that small change it works as well.

Another use for it would be the Ethernet CFM, which has a similar 
requirement.

On the other hand, I might've missed something. Is there a better way to 
be informed of a shutdown than listening for the GOING_DOWN 
event, so the frame can be sent to the wire when it's appropriate?

Eldad

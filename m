From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6.12-rc2] bonding: partially back out
 dev_set_mac_address
Date: Thu, 7 Apr 2005 21:45:17 -0700
Message-ID: <20050407214517.0d50703d.davem@davemloft.net>
References: <200504071959.j37JxZ8g003626@death.nxdomain.ibm.com>
	<4255FF69.4090208@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4255FF69.4090208@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 07 Apr 2005 23:50:01 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

> Jay Vosburgh wrote:
> > 	This patch backs out some of the calls to dev_set_mac_address
> > and replaces them with calls to a similar function that does not call
> > notifier_call_chain.
> > 
> > 	The reason for this is that the rtnetlink event handler and its
> > descendents make GFP_KERNEL memory allocation requests, and the bonding
> > driver makes some of its MAC address change calls from timer context
> > with a lock held (notably the ALB mode).
> > 
> > 	Rearranging the bonding driver to not call this way is a fairly
> > involved change; this patch merely reverts one part of bonding to the
> > way it used to be.
> 
> Do I need to forward this for -rc3?

No, read the rest of the thread, we're discussing an alternative
version of the fix.

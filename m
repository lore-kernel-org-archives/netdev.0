From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6.12-rc2] bonding: partially back out
 dev_set_mac_address
Date: Thu, 7 Apr 2005 13:31:51 -0700
Message-ID: <20050407133151.5887c946.davem@davemloft.net>
References: <200504071959.j37JxZ8g003626@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jay Vosburgh <fubar@us.ibm.com>
In-Reply-To: <200504071959.j37JxZ8g003626@death.nxdomain.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 07 Apr 2005 12:59:35 -0700
Jay Vosburgh <fubar@us.ibm.com> wrote:

> 	This patch backs out some of the calls to dev_set_mac_address
> and replaces them with calls to a similar function that does not call
> notifier_call_chain.
> 
> 	The reason for this is that the rtnetlink event handler and its
> descendents make GFP_KERNEL memory allocation requests, and the bonding
> driver makes some of its MAC address change calls from timer context
> with a lock held (notably the ALB mode).
> 
> 	Rearranging the bonding driver to not call this way is a fairly
> involved change; this patch merely reverts one part of bonding to the
> way it used to be.

You can't remove that notifier call, you will break ipv4 ARP,
ipv6 neighbour discovery, and bridging if you do that.

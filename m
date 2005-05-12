From: David Gibson <david@gibson.dropbear.id.au>
Subject: Re: [PATCH 4/4] iseries_veth: Cleanup skbs to prevent
	unregister_netdevice() hanging
Date: Thu, 12 May 2005 21:28:57 +1000
Message-ID: <20050512112857.GC32694@localhost.localdomain>
References: <200505121809.45419.michael@ellerman.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com,
	Jeff Garzik <jgarzik@pobox.com>, linux-kernel@vger.kernel.org,
	PPC64-dev <linuxppc64-dev@ozlabs.org>
Return-path: <linuxppc64-dev-bounces@ozlabs.org>
To: Michael Ellerman <michael@ellerman.id.au>
Content-Disposition: inline
In-Reply-To: <200505121809.45419.michael@ellerman.id.au>
List-Unsubscribe: <https://ozlabs.org/cgi-bin/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc64-dev>
List-Post: <mailto:linuxppc64-dev@ozlabs.org>
List-Help: <mailto:linuxppc64-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/cgi-bin/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc64-dev-bounces@ozlabs.org
Errors-To: linuxppc64-dev-bounces@ozlabs.org
List-Id: netdev.vger.kernel.org

On Thu, May 12, 2005 at 06:09:45PM +1000, Michael Ellerman wrote:
> Hi Andrew, Jeff,
> 
> The iseries_veth driver is badly behaved in that it will keep TX packets
> hanging around forever if they're not ACK'ed and the queue never fills up.
> 
> This causes the unregister_netdevice code to wait forever when we try to take
> the device down, because there's still skbs around with references to our
> struct net_device.
> 
> There's already code to cleanup any un-ACK'ed packets in veth_stop_connection()
> but it's being called after we unregister the net_device, which is too late.
> 
> The fix is to rearrange the module exit function so that we cleanup any
> outstanding skbs and then unregister the driver.
> 
> Signed-off-by: Michael Ellerman <michael@ellerman.id.au>

Nice catch.

Acked-by: David Gibson <david@gibson.dropbear.id.au>

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/people/dgibson

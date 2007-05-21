From: Kieran Mansley <kmansley@solarflare.com>
Subject: Re: [PATCH 0/4] [Net] Support Xen accelerated network
	plugin modules
Date: Mon, 21 May 2007 11:18:40 +0100
Message-ID: <1179742720.4118.18.camel@moonstone.uk.level5networks.com>
References: <1179494148.14376.7.camel@moonstone.uk.level5networks.com>
	<20070521081401.GA1091@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: muli@il.ibm.com, Stephen Hemminger <shemminger@linux-foundation.org>,
	xen-devel@lists.xensource.com, Jeff Garzik <jgarzik@pobox.com>,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <xen-devel-bounces@lists.xensource.com>
In-Reply-To: <20070521081401.GA1091@gondor.apana.org.au>
List-Unsubscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

On Mon, 2007-05-21 at 18:14 +1000, Herbert Xu wrote:
> On Fri, May 18, 2007 at 02:15:48PM +0100, Kieran Mansley wrote:
> > This set of patches provides the hooks and support necessary for
> > accelerated network plugin modules to attach to Xen's netback and
> > netfront.  These modules provide a fast path for network traffic where
> > there is hardware support available for the netfront driver to send and
> > receive packets directly to a NIC (such as those available from
> > Solarflare).
> 
> The RX side looks reasonble.  For TX, what sort of conditions are you
> likely to use to decide whether a packet gets fast path or not?

For us, at the moment, we TX-fast-path packets to MAC addresses that we
would also RX-fast-path from.  i.e. Those for which we have a filter in
the NIC for.  This boils down to a hash table lookup on the MAC
addresses.  We do a couple of other checks too (make sure it's IPV4, TCP
or UDP, unicast) to keep things simple.

> Also for TX, you'll need a better way of managing queue stopping/starting
> since presumably you only want to wake the queue when both fast path and
> slow path have free slots.

Hmm, good point.  At the moment the queue is stopped if either fast or
slow path is busy, and restarted if either fast or slow path becomes
not-busy.  I suppose this would work OK if we could guarantee that the
slow path wouldn't restart the queue that had been stopped by the fast
path, and vice versa, but at the moment that's not the case, so you're
right it needs looking at.

Kieran

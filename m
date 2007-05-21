From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/4] [Net] Support Xen accelerated network plugin modules
Date: Mon, 21 May 2007 18:14:01 +1000
Message-ID: <20070521081401.GA1091@gondor.apana.org.au>
References: <1179494148.14376.7.camel@moonstone.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xen-devel@lists.xensource.com, netdev@vger.kernel.org,
	muli@il.ibm.com
To: Jeff Garzik <jgarzik@pobox.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Kieran Mansley <kmansley@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1373 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755689AbXEUIPA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 May 2007 04:15:00 -0400
Content-Disposition: inline
In-Reply-To: <1179494148.14376.7.camel@moonstone.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 18, 2007 at 02:15:48PM +0100, Kieran Mansley wrote:
> 
> I've also CC'd netdev@vger.kernel.org as some of the files being patched
> may be merged into upstream linux soon, and so folks there may have
> opinions too.

Jeff and Stephen, could you both take a look at these proposed patches
against the Xen netfront driver and see whether the hooks that they add
look OK from a Linux network driver point of view?

> This set of patches provides the hooks and support necessary for
> accelerated network plugin modules to attach to Xen's netback and
> netfront.  These modules provide a fast path for network traffic where
> there is hardware support available for the netfront driver to send and
> receive packets directly to a NIC (such as those available from
> Solarflare).

The RX side looks reasonble.  For TX, what sort of conditions are you
likely to use to decide whether a packet gets fast path or not?

Also for TX, you'll need a better way of managing queue stopping/starting
since presumably you only want to wake the queue when both fast path and
slow path have free slots.

> We have found that using this approach to accelerating network traffic,
> domU to domU connections (across the network) can achieve close to the
> performance of dom0 to dom0 connections on a 10Gbps ethernet.  This is
> roughly double the bandwidth seen with unmodified Xen. 

That sounds good.  I wonder how much of this difference goes away if we
had LRO though.

Here's an interesting experiment, what if you only used these hooks on
the receive side for your 10Gbps transfer? Of course, you need to make
sure that TSO is working properly on the sending side.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

From: Christian Limpach <Christian.Limpach@cl.cam.ac.uk>
Subject: Re: [Xen-devel] [RFC PATCH 34/35] Add the Xen virtual network device	driver.
Date: Tue, 9 May 2006 13:43:59 +0100
Message-ID: <20060509124359.GA5407@cl.cam.ac.uk>
References: <20060509085201.446830000@sous-sol.org> <E1FdQoP-0007iN-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Wright <chrisw@sous-sol.org>, linux-kernel@vger.kernel.org,
	virtualization@lists.osdl.org, xen-devel@lists.xensource.com,
	netdev@vger.kernel.org, ian.pratt@xensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta1.cl.cam.ac.uk ([128.232.0.15]:53121 "EHLO mta1.cl.cam.ac.uk")
	by vger.kernel.org with ESMTP id S932485AbWEIMoN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 May 2006 08:44:13 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1FdQoP-0007iN-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 09, 2006 at 09:55:33PM +1000, Herbert Xu wrote:
> Hi Chris:
> 
> Chris Wright <chrisw@sous-sol.org> wrote:
> >
> > +/** Send a packet on a net device to encourage switches to learn the
> > + * MAC. We send a fake ARP request.
> > + *
> > + * @param dev device
> > + * @return 0 on success, error code otherwise
> > + */
> > +static int send_fake_arp(struct net_device *dev)
> 
> I think we talked about this before.  I don't see why Xen is so special
> that it needs its own gratuitous arp routine embedded in the driver.
> If this is needed at all (presumably for migration) then it should be
> performed by the management scripts which can send grat ARP packets just
> as easily.

There's at least two reasons why having it in the driver is preferable:
- synchronizing sending the fake ARP request with when the device is
  operational -- you really want to make this well synchronized to keep
  unreachability as short as possible, especially when doing live
  migration
- anybody but the guest might not know (all) the MAC addresses for which
  to send a fake ARP request

    christian


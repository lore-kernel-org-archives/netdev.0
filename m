From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: Re: [PATCH] mlx4_en: fix transmit of packages when blue frame is
 enabled
Date: Mon, 10 Oct 2011 11:29:26 +0200
Message-ID: <20111010092926.GO2681@mtldesk30>
References: <1318145118.29415.371.camel@pasglop>
 <AE90C24D6B3A694183C094C60CF0A2F6D8AE78@saturn3.aculab.com>
 <20111010084726.GM2681@mtldesk30>
 <1318237284.29415.422.camel@pasglop>
 <20111010091611.GN2681@mtldesk30>
 <1318238645.29415.426.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight@ACULAB.COM>, netdev@vger.kernel.org,
	Eli Cohen <eli@mellanox.co.il>, linuxppc-dev@lists.ozlabs.org,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:49581 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753097Ab1JJJ3d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2011 05:29:33 -0400
Received: by mail-bw0-f46.google.com with SMTP id zt4so8238829bkb.19
        for <netdev@vger.kernel.org>; Mon, 10 Oct 2011 02:29:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1318238645.29415.426.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 10, 2011 at 11:24:05AM +0200, Benjamin Herrenschmidt wrote:
> On Mon, 2011-10-10 at 11:16 +0200, Eli Cohen wrote:
> 
> > Until then I think we need to have the logic working right on ppc and
> > measure if blue flame buys us any improvement in ppc. If that's not
> > the case (e.g because write combining is not working), then maybe we
> > should avoid using blueflame in ppc.
> > Could any of the guys from IBM check this and give us feedback?
> 
> I don't have the necessary hardware myself to test that but maybe Thadeu
> can.
> 
> Note that for WC to work, things must be mapped non-guarded. You can do
> that by using ioremap_prot() with pgprot_noncached_wc(PAGE_KERNEL) or
> ioremap_wc() (dunno how "generic" the later is).

I use the io mapping API:

at driver statrt:
        priv->bf_mapping = io_mapping_create_wc(bf_start, bf_len);
        if (!priv->bf_mapping)
                err = -ENOMEM;

and then:
        uar->bf_map = io_mapping_map_wc(priv->bf_mapping, uar->index << PAGE_SHIFT);

        
Will this work on ppc?

> 
> >From there, you should get write combining provided that you don't have
> barriers between every access (ie those copy operations in their current
> form should do the trick).
> 
> Cheers,
> Ben.
> 
> > > Maybe it's time for us to revive those discussions about providing a
> > > good set of relaxed MMIO accessors with explicit barriers :-)
> > > 
> > > Cheers,
> > > Ben.
> > >  
> 

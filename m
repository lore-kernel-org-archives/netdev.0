From: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Subject: Re: [patch] svcrdma: endian bug in send_write_chunks()
Date: Thu, 12 Jan 2012 14:28:21 -0500
Message-ID: <20120112192821.GA9592@fieldses.org>
References: <20120112064722.GB2408@elgon.mountain>
 <20120112162141.GC6563@fieldses.org>
 <1326395759.6198.7.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Tom Tucker <tom-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
To: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1326395759.6198.7.camel-SyLVLa/KEI9HwK5hSS5vWB2eb7JE58TQ@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 12, 2012 at 02:15:59PM -0500, Trond Myklebust wrote:
> On Thu, 2012-01-12 at 11:21 -0500, J. Bruce Fields wrote: 
> > On Thu, Jan 12, 2012 at 09:47:22AM +0300, Dan Carpenter wrote:
> > > Sparse complains because arg_ch->rs_length is declared as network
> > > endian but we're treating it as CPU endian.
> > 
> > This looks like it would actually change behavior on a little endian
> > architecture, so how did this work before?
> > 
> > >From some quick grepping, I see assignments both of the form
> > 
> > 	...rs_length = ntohl(...)
> > 
> > and
> > 
> > 	...rs_length = htonl(...)
> > 
> > but only see one declaration for a field named rs_length.
> > 
> > So my best guess would be that the code is ugly but working as is, and
> > needs cleanup by someone who knows how this field was intended to be
> > used.
> 
> It looks to me as if rs_handle and rs_offset are being similarly abused.
> Basically, we need a serious clean up in svc_rdma_marshall.c to separate
> out those variables that are in XDR-encoded form and those that are not.

(Here everybody takes one step back and pretends to be engrossed in some
other thread.)

--b.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: xen-netback stable backports request (regression fixes)
Date: Wed, 5 Jun 2013 09:56:30 +0100
Message-ID: <1370422590.24512.135.camel@zakaz.uk.xensource.com>
References: <1369734465.3469.52.camel@zakaz.uk.xensource.com>
	 <20130605045532.GA10475@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <stable@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	xen-devel <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>
To: Greg KH <greg@kroah.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20130605045532.GA10475@kroah.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-06-04 at 21:55 -0700, Greg KH wrote:
> On Tue, May 28, 2013 at 10:47:45AM +0100, Ian Campbell wrote:
> > Hi Dave, stable folks,
> > 
> > The following set of patches fix a xen netback regression caused by the
> > fixes for CVE-2013-0216 / CVE-2013-0217 / XSA-39 (the original change
> > was several patches starting at 48856286b64e), we'd like to see them
> > backported to stable branches if possible. I think the fixups have now
> > been in Linus tree since around the start of May.
> > 
> > Wei and I are happy to help with backports if necessary. Some of the
> > patches are cleanups which make backports easier but if you would prefer
> > we could produce backports without them.
> > 
> > 27f85228 xen-netback: remove skb in xen_netbk_alloc_page
> 
> I've applied this one.

Thanks.

> > 2810e5b9 xen-netback: coalesce slots in TX path and fix regressions
> 
> This patch does not apply cleanly to 3.9-stable.  So I can't apply
> anything else.  Can you please provide backports?

Wei, can you do this please?

> > 03393fd5 xen-netback: don't disconnect frontend when seeing oversize packet
> > ac69c26e xen-netback: remove redundent parameter in netbk_count_requests
> > 59ccb4eb xen-netback: avoid allocating variable size array on stack
> > 37641494 xen-netback: better names for thresholds
> 
> Why are these last two patches needed for a stable tree?

For the first we thought that allocating a variable size array on the
stack was bad practice which could lead to a stack overflow. The default
is safe but can be overridden by a module parameter.

The other renames the module parameter which we thought was useful for
consistency between newer kernels and the stable branches.

> > In addition there are some useful related (but not security relevant)
> > fixes to netfront:
> > 
> > e2d617c0 xen-netfront: remove unused variable `extra'
> > 7158ff6d xen-netfront: frags -> slots in xennet_get_responses
> > 697089dc xen-netfront: frags -> slots in log message
> > 9ecd1a75 xen-netfront: reduce gso_max_size to account for max TCP header
> 
> Why are they needed for stable releases?  What do they fix?

The last one prevents the network stack from handing us frames which we
cannot possibly fit into the Xen PV wire format and therefore would be
obliged to drop -- this was causing packet loss in real use.

I originally thought the other three we useful precursors which made the
backport of the last one easier, but looking at it again I don't think
this is actually the case -- there should only be a small amount of
trivial to resolve rejects due to the frags->slots renaming. Sorry for
getting this wrong. 

Ian.

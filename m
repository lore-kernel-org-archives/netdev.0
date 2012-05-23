From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH] xen/netback: calculate correctly the SKB slots.
Date: Wed, 23 May 2012 09:12:42 -0400
Message-ID: <20120523131242.GA15406@phenom.dumpdata.com>
References: <1337621793-12486-1-git-send-email-konrad.wilk@oracle.com>
 <1337627640.2979.33.camel@bwh-desktop.uk.solarflarecom.com>
 <1337678512.10118.40.camel@zakaz.uk.xensource.com>
 <20120522180901.GC22488@phenom.dumpdata.com>
 <F02ED76F3FCF8C468AD22A7618C05BBBB18DBFFE61@FTLPMAILBOX01.citrite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Adnan Misherfi <adnan.misherfi@oracle.com>
To: Simon Graham <simon.graham@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <F02ED76F3FCF8C468AD22A7618C05BBBB18DBFFE61@FTLPMAILBOX01.citrite.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 22, 2012 at 03:01:55PM -0400, Simon Graham wrote:
> > >
> > > > >  	int i, copy_off;
> > > > >
> > > > >  	count = DIV_ROUND_UP(
> > > > > -			offset_in_page(skb->data)+skb_headlen(skb),
> > PAGE_SIZE);
> > > > > +			offset_in_page(skb->data + skb_headlen(skb)),
> > PAGE_SIZE);
> > > >
> > > > The new version would be equivalent to:
> > > > 	count = offset_in_page(skb->data + skb_headlen(skb)) != 0;
> > > > which is not right, as netbk_gop_skb() will use one slot per page.
> > >
> > > Just outside the context of this patch we separately count the frag
> > > pages.
> > >
> > > However I think you are right if skb->data covers > 1 page, since the
> > > new version can only ever return 0 or 1. I expect this patch papers
> > over
> > > the underlying issue by not stopping often enough, rather than
> > actually
> > > fixing the underlying issue.
> > 
> > Ah, any thoughts? Have you guys seen this behavior as well?
> 
> We ran into this same problem and the fix we've been running with for a while now (been meaning to submit it!) is:

Where is the patchqueue of the patches? Is it only on the src.rpm or
is it in some nice mercurial tree? Asking b/c if we run into other trouble
it would be also time-saving for us (and I presume other companies
too) to check that. Thanks!

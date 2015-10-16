From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH] xen-netback: correctly check failed allocation
Date: Fri, 16 Oct 2015 10:05:21 +0100
Message-ID: <20151016090521.GJ32638@zion.uk.xensource.com>
References: <1444932148-15633-1-git-send-email-wuninsu@gmail.com>
 <CAGoFzNdCef+tutWgabSahHqV0rkC9FdNpjrQEsxk8GMeBA0TKQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, Taesoo Kim <taesoo@gatech.edu>,
	Yeongjin Jang <yeongjin.jang@gatech.edu>,
	"Yun, Insu" <insu@gatech.edu>
To: Insu Yun <wuninsu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:50924 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752024AbbJPJFZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 05:05:25 -0400
Content-Disposition: inline
In-Reply-To: <CAGoFzNdCef+tutWgabSahHqV0rkC9FdNpjrQEsxk8GMeBA0TKQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 15, 2015 at 02:02:47PM -0400, Insu Yun wrote:
> I changed patch with valid format.
> 
> On Thu, Oct 15, 2015 at 2:02 PM, Insu Yun <wuninsu@gmail.com> wrote:
> 
> > Since vzalloc can be failed in memory pressure,
> > writes -ENOMEM to xenstore to indicate error.
> >
> > Signed-off-by: Insu Yun <wuninsu@gmail.com>
> > ---
> >  drivers/net/xen-netback/xenbus.c | 6 ++++++
> >  1 file changed, 6 insertions(+)
> >
> > diff --git a/drivers/net/xen-netback/xenbus.c
> > b/drivers/net/xen-netback/xenbus.c
> > index 929a6e7..56ebd82 100644
> > --- a/drivers/net/xen-netback/xenbus.c
> > +++ b/drivers/net/xen-netback/xenbus.c
> > @@ -788,6 +788,12 @@ static void connect(struct backend_info *be)
> >         /* Use the number of queues requested by the frontend */
> >         be->vif->queues = vzalloc(requested_num_queues *
> >                                   sizeof(struct xenvif_queue));
> > +       if (!be->vif->queues) {
> > +               xenbus_dev_fatal(dev, -ENOMEM,
> > +                                "allocating queues");
> > +               return;
> >
> 
> I didn't use goto err, because another error handling is not required
> 

It's recommended in kernel coding style to use "goto" style error
handling. I personally prefer that to arbitrary return in function body,
too.

It's not a matter of whether another error handling is required or not,
it's about cleaner code that is easy to reason about and consistent
coding style.

The existing code is not perfect, but that doesn't mean we should follow
bad example.

Wei.

> 
> > +       }
> > +
> >         be->vif->num_queues = requested_num_queues;
> >         be->vif->stalled_queues = requested_num_queues;
> >
> > --
> > 1.9.1
> >
> >
> 
> 
> -- 
> Regards
> Insu Yun

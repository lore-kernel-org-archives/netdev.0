From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: Netlink messages without NLM_F_REQUEST flag
Date: Wed, 7 Jun 2017 11:07:02 -0600
Message-ID: <20170607170702.GB7507@obsidianresearch.com>
References: <20170607161901.GD1127@mtr-leonro.local>
 <20170607163758.GA25313@obsidianresearch.com>
 <CALq1K=Jj_jJ5_OAiiws-es37tFEsLeLJeSvnU+bfwd0KLkGM3Q@mail.gmail.com>
 <20170607164750.GA7507@obsidianresearch.com>
 <20170607170037.GG1127@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kaike Wan <kaike.wan-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, John Fleck <john.fleck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Ira Weiny <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Jiri Pirko <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        RDMA mailing list <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170607170037.GG1127-U/DQcQFIOTAAJjI8aNfphQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 07, 2017 at 08:00:37PM +0300, Leon Romanovsky wrote:
> On Wed, Jun 07, 2017 at 10:47:50AM -0600, Jason Gunthorpe wrote:
> > On Wed, Jun 07, 2017 at 07:43:44PM +0300, Leon Romanovsky wrote:
> > > On Wed, Jun 7, 2017 at 7:37 PM, Jason Gunthorpe
> > > <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org> wrote:
> > > > On Wed, Jun 07, 2017 at 07:19:01PM +0300, Leon Romanovsky wrote:
> > > >> It makes me wonder if it is expected behavior for
> > > >> ibnl_rcv_reply_skb() to handle !NLM_F_REQUEST messages and do we
> > > >> really need it? What are the scenarios?  In my use case, which is
> > > >> for sure different from yours, I'm always setting NLM_F_REQUEST
> > > >> while communicating with kernel.
> > > >
> > > > If I recall the user space SA code issues REQUESTS from the kernel to
> > > > userspace, so userspace returns with the response format. This is
> > > > abnormal for netlink hence the special function.
> > >
> > > In netlink semantics, kernel side is supposed to send netlink
> > > notification message and userspace is supposed to send REQUEST.
> >
> > That pattern is for async communications, the SA stuff needs a sync
> > protocol, unfortunately.
> 
> There is special flag NLM_F_ACK for it and userspace will set
> NLM_F_REQUEST | NLM_F_ACK once synchronization is needed.

AFAIK, that is different, that is acking and retriggering a single shot
notification, not completing a kernel initiated handshake.

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

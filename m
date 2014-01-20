From: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net] tun: handle copy failure in tun_put_user()
Date: Mon, 20 Jan 2014 11:52:02 +0200
Message-ID: <20140120095202.GA11280@redhat.com>
References: <1390187808-5462-1-git-send-email-jasowang@redhat.com>
 <20140119.194856.491294439635992592.davem@davemloft.net>
 <20140120084349.GA7677@redhat.com>
 <52DCED12.501@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jason Wang <jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <52DCED12.501-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 20, 2014 at 05:32:02PM +0800, Jason Wang wrote:
> On 01/20/2014 04:43 PM, Michael S. Tsirkin wrote:
> > On Sun, Jan 19, 2014 at 07:48:56PM -0800, David Miller wrote:
> >> From: Jason Wang <jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> >> Date: Mon, 20 Jan 2014 11:16:48 +0800
> >>
> >>> This patch return the error code of copy helpers in tun_put_user() instead of
> >>> ignoring them.
> >>>
> >>> Cc: Michael S. Tsirkin <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> >>> Signed-off-by: Jason Wang <jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> > I'm not sure we need to worry about this too much.
> > But if yes, a bunch of places besides tun should be
> > changed.
> 
> Yes, I send the patch because the error processing here is different
> from what macvtap does. Macvtap just return error in this case and so do
> packet socket.

I suspect we just need to document that invalid address simply results
in unspecified behaviour.  We try to return EFAULT to help debugging
sometimes but it's on a best effort basis.
>From this point of view EFAULT seems easier to debug than truncating the packet.
In any case even if we change Linux - applications won't be able to rely
on this for a long while.
So maybe we shouldn't do anything.


> >  Consider for example udp_recvmsg: it
> > never seems to return any error except -EAGAIN.
> >
> > Is this a bug? Man page for recvmsg says:
> >      EFAULT The receive buffer pointer(s)  point  outside  the process's  address
> >               space.
> >
> > this isn't very clear: does this mean "all pointers are invalid"
> > or "some pointers are invalid"?
> > Also, what if pointers themselves are valid but length
> > makes us go outside the address space?
> >
> > I'm guessing the simplest way is to clarify in the man page that
> > passing invalid pointers / lengths is not guaranteed
> > to result in EFAULT and that Linux makes no guarantees
> > about the returned length in this case.
> >
> > Cc linux-man in case they can suggest some insights on this.
> >
> >> If you perform some of the copy successfully, you have to report that
> >> length rather than just an error.
> >>
> >> Otherwise userland has no way to determine how much of the data was
> >> successfully sourced.
> >>
> >> I'm not applying this, sorry.
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> > the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > Please read the FAQ at  http://www.tux.org/lkml/
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

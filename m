From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] net: Implement SO_PEERCGROUP
Date: Thu, 13 Mar 2014 09:48:40 -0400
Message-ID: <20140313134840.GA18914@redhat.com>
References: <1394657163-7472-1-git-send-email-vgoyal@redhat.com>
 <1394657163-7472-3-git-send-email-vgoyal@redhat.com>
 <CAHA+R7OrNoa7_J-rOskxgdvkM5gAnQyoFBeCXSziY7XMd-yLNA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	ssorce-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jkaluza-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	kay-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: Cong Wang <cwang-xCSkyg8dI+0RB7SZvlqPiA@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAHA+R7OrNoa7_J-rOskxgdvkM5gAnQyoFBeCXSziY7XMd-yLNA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 12, 2014 at 01:58:57PM -0700, Cong Wang wrote:
> On Wed, Mar 12, 2014 at 1:46 PM, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> > @@ -1098,6 +1135,16 @@ static int unix_stream_connect(struct socket *sock, struct sockaddr *uaddr,
> >         if (newsk == NULL)
> >                 goto out;
> >
> > +       err = init_peercgroup(newsk);
> > +       if (err)
> > +               goto out;
> > +
> > +       err = alloc_cgroup_path(sk);
> > +       if (err)
> > +               goto out;
> > +
> > +       err = -ENOMEM;
> > +
> 
> Don't we need to free the cgroup_path on error path
> in this function?

Previous allocated cgroup_path is now in newsk->cgroup_path and I was
relying on __sk_free() freeing that memory if error happens.

unix_release_sock(sk)
  sock_put()
    sk_free()
      __sk_free()
        kfree(sk->cgroup_path)

Do you see a problem with that?

Thanks
Vivek

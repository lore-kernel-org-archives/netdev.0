From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC] net/unix_diag: Provide UDIAG_SHOW_VFS2 attribute to fetch
 complete inode number
Date: Wed, 25 Oct 2017 10:27:07 +0300
Message-ID: <20171025072707.GA3102@uranus>
References: <20171024214814.GO5343@uranus>
 <20171025002509.GA12438@outlook.office365.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NETDEV <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Andrey Vagin <avagin@openvz.org>,
        "David S. Miller" <davem@davemloft.net>,
        Pavel Emelyanov <xemul@virtuozzo.com>
To: Andrei Vagin <avagin@virtuozzo.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171025002509.GA12438@outlook.office365.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 24, 2017 at 05:25:16PM -0700, Andrei Vagin wrote:
> On Wed, Oct 25, 2017 at 12:48:14AM +0300, Cyrill Gorcunov wrote:
> > Currently unix_diag_vfs structure reports unix socket inode
> > as u32 value which of course doesn't fit to ino_t type and
> 
> BTW: As far as I understand, it is not a problem right now, because
> get_next_ino returns int. And I'm agree that it maybe a problem in a
> future and it is better to be ready.
> 
> > the number may be trimmed. Lets rather deprecate old UDIAG_SHOW_VFS
> > interface and provide UDIAG_SHOW_VFS2 (with one field "__zero" reserved
> > which we could extend in future).
> 
> There is one more place where we return ino as u32:
> 
> static int sk_diag_dump_peer(struct sock *sk, struct sk_buff *nlskb)
> ....
>                 return nla_put_u32(nlskb, UNIX_DIAG_PEER, ino);

Managed to miss it, thanks!

> > +struct unix_diag_vfs2 {
> > +	__u64	udiag_vfs_ino;
> > +	__u32	udiag_vfs_dev;
> > +	__u32	__zero;		/* Reserve for future use */
> 
> How can a user understand whether this field is used or not?

Checking out if it zero or not.

> Each netlink attribute has its size in a header. Any attribute can be
> extended, and users can understand which fields are filled by
> a size of an attribute.

Well, that's correct, but it implies that any extension has different
size. I though of extending this structure (if ever needed) the way
that same attribute may carry different structures equal in size and
setting up @__zero field with some bit would help. On the other side
it become more complex than needed, so now I think I should simply
drop __zero out.

Thanks for comments, Andrew!

	Cyrill

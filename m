From: Fields Bruce James <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH 1/2] SUNRPC: accept() may return sockets that are still
 in SYN_RECV
Date: Thu, 28 Jul 2016 10:21:06 -0400
Message-ID: <20160728142106.GA27786@fieldses.org>
References: <1469541080-4184-1-git-send-email-trond.myklebust@primarydata.com>
 <20160726154354.GA6692@fieldses.org>
 <7C18520C-D486-4466-8D9D-FF2052B03F0E@primarydata.com>
 <20160727184806.GA19229@fieldses.org>
 <1469645951.17736.13.camel@edumazet-glaptop3.roam.corp.google.com>
 <332ACE13-83D0-4516-9B2D-200250ED3437@primarydata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	List Linux NFS Mailing <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	List Linux Network Devel Mailing <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Yuchung Cheng <ycheng-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
To: Trond Myklebust <trondmy-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <332ACE13-83D0-4516-9B2D-200250ED3437-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 27, 2016 at 07:11:23PM +0000, Trond Myklebust wrote:
> Hi Eric,
>=20
> > On Jul 27, 2016, at 14:59, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wr=
ote:
> >=20
> > On Wed, 2016-07-27 at 14:48 -0400, Fields Bruce James wrote:
> >> On Tue, Jul 26, 2016 at 04:08:29PM +0000, Trond Myklebust wrote:
> >>>=20
> >>>> On Jul 26, 2016, at 11:43, J. Bruce Fields <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org=
> wrote:
> >>>>=20
> >>>> On Tue, Jul 26, 2016 at 09:51:19AM -0400, Trond Myklebust wrote:
> >>>>> We're seeing traces of the following form:
> >>>>>=20
> >>>>> [10952.396347] svc: transport ffff88042ba4a 000 dequeued, inuse=
=3D2
> >>>>> [10952.396351] svc: tcp_accept ffff88042ba4 a000 sock ffff88042=
a6e4c80
> >>>>> [10952.396362] nfsd: connect from 10.2.6.1, port=3D187
> >>>>> [10952.396364] svc: svc_setup_socket ffff8800b99bcf00
> >>>>> [10952.396368] setting up TCP socket for reading
> >>>>> [10952.396370] svc: svc_setup_socket created ffff8803eb10a000 (=
inet ffff88042b75b800)
> >>>>> [10952.396373] svc: transport ffff8803eb10a000 put into queue
> >>>>> [10952.396375] svc: transport ffff88042ba4a000 put into queue
> >>>>> [10952.396377] svc: server ffff8800bb0ec000 waiting for data (t=
o =3D 3600000)
> >>>>> [10952.396380] svc: transport ffff8803eb10a000 dequeued, inuse=3D=
2
> >>>>> [10952.396381] svc_recv: found XPT_CLOSE
> >>>>> [10952.396397] svc: svc_delete_xprt(ffff8803eb10a000)
> >>>>> [10952.396398] svc: svc_tcp_sock_detach(ffff8803eb10a000)
> >>>>> [10952.396399] svc: svc_sock_detach(ffff8803eb10a000)
> >>>>> [10952.396412] svc: svc_sock_free(ffff8803eb10a000)
> >>>>>=20
> >>>>> i.e. an immediate close of the socket after initialisation.
> >>>>=20
> >>>> Interesting, thanks!
> >>>>=20
> >>>> So the one thing I don't understand is why this is correct behav=
ior for
> >>>> accept--I thought it wasn't supposed to return a socket until it=
 was
> >>>> fully established.
> >>>=20
> >>> inet_accept() appears to allow SYN_RECV:
> >>=20
> >> OK.  Cc'ing netdev just to make sure we didn't overlook anything.
> >>=20
> >=20
> > SYN_RECV after accept() is a TCP Fast Open property I think.
> >=20
> > Maybe you are playing with some global TCP Fast Open settings ?
> >=20
>=20
> The Linux kernel client should not be using TCP fast open, but it is =
possible that some of the other NFSv3 clients we=E2=80=99re using are.
> Would a standard knfsd listener respond to a TCP fast open request, o=
r would the default behaviour be to ignore it?
>=20
> If the default behaviour for the server is to allow fast open, then w=
e do need these patches, IMO.

Even if it's not a default, if there's a configuration that allows
accept to return a socket in SYN_RECV state, then knfsd should handle i=
t
gracefully, especially as long as it's this easy.

It'd still be useful to understand why this is happening, though....

--b.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

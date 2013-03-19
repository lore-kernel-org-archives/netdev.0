From: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
Subject: Re: [PATCH 2/2] man/send(2): document a long standing bug that can
 cause spurious EPERM errors
Date: Tue, 19 Mar 2013 11:12:23 +0100
Message-ID: <20130319101223.GA3672@localhost>
References: <1363675513.4767.6.camel@nexus>
 <1363675960.4767.10.camel@nexus>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>,
	Hirotaka Sasaki <sasaki.hirotaka-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>
To: Fernando Luis =?iso-8859-1?Q?V=E1zquez?= Cao
	<fernando_b1-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1363675960.4767.10.camel@nexus>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 19, 2013 at 03:52:40PM +0900, Fernando Luis V=E1zquez Cao w=
rote:
> Subject: [PATCH 2/2] man/send(2): document a long standing bug that c=
an cause spurious EPERM errors
>=20
> This bug has been known since early 2009 (the latest) and  discussed =
in
> netdev before:
>=20
> http://marc.info/?l=3Dlinux-netdev&w=3D2&r=3D1&s=3DPossible+race+cond=
ition+in+conntracking+&q=3Db
>=20
> It seems that a proper fix would be non trivial, so document the bug
> in the meantime.
>
> Reported-by: Hirotaka Sasaki <sasaki.hirotaka-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>
> Signed-off-by: Fernando Luis Vazquez Cao <fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>
> ---
>=20
> diff -urNp man-pages-3.50-orig/man2/send.2 man-pages-3.50/man2/send.2
> --- man-pages-3.50-orig/man2/send.2	2013-03-19 15:18:03.784306647 +09=
00
> +++ man-pages-3.50/man2/send.2	2013-03-19 15:30:40.788060426 +0900
> @@ -420,6 +420,11 @@ Linux may return
>  .B EPIPE
>  instead of
>  .BR ENOTCONN .
> +
> +Linux may return spurious
> +.B EPERM
> +errors when netfilter's conntrack module is loaded and two or more
> +UDP packets belonging to the same connection are processed in parall=
el.

The Connection tracking system may drop packets for different reasons
under rare circunstances, not only in this case.

I'd prefer if you only apply patch 1/2.
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

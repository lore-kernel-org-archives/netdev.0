From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH RFC] tun: export underlying socket
Date: Mon, 14 Sep 2009 11:01:54 +0300
Message-ID: <15ddcffd0909140101waf04e91i918dd94143b1a7f4@mail.gmail.com>
References: <20090910125929.GA32593@redhat.com>
	 <200909110017.27668.paul.moore@hp.com>
	 <20090911045943.GA1613@redhat.com> <20090911053610.GA10324@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Paul Moore <paul.moore@hp.com>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	Or Gerlitz <ogerlitz@voltaire.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:8628 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752996AbZINIBw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2009 04:01:52 -0400
Received: by fg-out-1718.google.com with SMTP id 22so463708fge.1
        for <netdev@vger.kernel.org>; Mon, 14 Sep 2009 01:01:54 -0700 (PDT)
In-Reply-To: <20090911053610.GA10324@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/11/09, Michael S. Tsirkin <mst@redhat.com> wrote:
>> On Fri, Sep 11, 2009 at 12:17:27AM -0400, Paul Moore wrote:
>>> No comments on the code at this point - I'm just trying to understa=
nd the
>>> intended user right now which I'm assuming is the vhost-net bits yo=
u sent previously

> More specifically, vhost would then be patched with:
>
>=A0=A0diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
>=A0=A0index aeffb3a..b54f9d6 100644
>=A0=A0--- a/drivers/vhost/net.c
>=A0=A0+++ b/drivers/vhost/net.c
>=A0=A0@@ -331,15 +331,26 @@ err:
> =A0=A0=A0=A0=A0=A0=A0=A0return ERR_PTR(r);
> =A0=A0}
>
>=A0=A0+static struct socket *get_tun_socket(int fd)
>=A0=A0+{
>=A0=A0+=A0=A0=A0=A0=A0=A0 struct file *file =3D fget(fd);
>=A0=A0+=A0=A0=A0=A0=A0=A0 if (!file)
>=A0=A0+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 return ERR_PTR(-EBAD=
=46);
>=A0=A0+=A0=A0=A0=A0=A0=A0 return tun_get_socket(file);
>=A0=A0+}
>=A0=A0+
> =A0=A0static struct socket *get_socket(int fd)

Michael,

your latest posting "[PATCHv5 3/3] vhost_net: a kernel-level virtio
server" doesn't have a function named get_socket, so I don't see how
one can really get what you are up with this snip from vhost/net.c

Or.

> =A0=A0{
> =A0=A0=A0=A0=A0=A0=A0=A0struct socket *sock;
> =A0=A0=A0=A0=A0=A0=A0=A0sock =3D get_raw_socket(fd);
>
> =A0=A0=A0=A0=A0=A0=A0=A0if (!IS_ERR(sock))
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0return sock;
>
> +=A0=A0=A0=A0=A0=A0 sock =3D get_tun_socket(fd);
>=A0=A0+=A0=A0=A0=A0=A0=A0 if (!IS_ERR(sock))
>=A0=A0+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 return sock;
> =A0=A0=A0=A0=A0=A0=A0=A0return ERR_PTR(-ENOTSOCK);
> =A0=A0}
>
> =A0=A0static long vhost_net_set_socket(struct vhost_net *n, int fd)
> =A0=A0{
> =A0=A0=A0=A0=A0=A0=A0=A0struct socket *sock, *oldsock =3D NULL;
>

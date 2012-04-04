From: chetan loke <loke.chetan@gmail.com>
Subject: Re: [RFC PATCH 2/2] PID-based packet filtering support
Date: Wed, 4 Apr 2012 14:57:11 -0400
Message-ID: <CAAsGZS6CoNuTBQ+YUjBc+Y9+oviHPrbrwGCCN0mZmTm5DCt8ow@mail.gmail.com>
References: <cover.1333466900.git.nuno.martins@caixamagica.pt>
	<19b9f7a0f38c1bab367da6f6cf622c8c2b3a4920.1333466900.git.nuno.martins@caixamagica.pt>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Alfredo Matos <alfredo.matos@caixamagica.pt>,
	Paulo Trezentos <paulo.trezentos@caixamagica.pt>
To: Nuno Martins <nuno.martins@caixamagica.pt>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:33254 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932516Ab2DDS5M convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 14:57:12 -0400
Received: by pbcun15 with SMTP id un15so606610pbc.19
        for <netdev@vger.kernel.org>; Wed, 04 Apr 2012 11:57:12 -0700 (PDT)
In-Reply-To: <19b9f7a0f38c1bab367da6f6cf622c8c2b3a4920.1333466900.git.nuno.martins@caixamagica.pt>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 4, 2012 at 5:16 AM, Nuno Martins
<nuno.martins@caixamagica.pt> wrote:


> +int get_local_packet_info_from_fd(unsigned int fd, struct packetInfo=
 *ret)

rename 'ret' to 'pi' or pkt_info or pick a name (must match the
struct). And not just here but everywhere else.

> +{
> + =C2=A0 =C2=A0 =C2=A0 struct file *f =3D fget(fd);
> +
> + =C2=A0 =C2=A0 =C2=A0 if (f !=3D NULL) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 fput(f);

why not 'fput' after you return from 'get_local_packet_info_from_file' =
?

> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return get_local_p=
acket_info_from_file(f, ret);
> + =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 return -3;
> +}
> +


> +int get_local_packet_info_from_file(struct file *f, struct packetInf=
o *ret)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct socket *socket =3D NULL;
> + =C2=A0 =C2=A0 =C2=A0 short type;
> + =C2=A0 =C2=A0 =C2=A0 unsigned short family;
> + =C2=A0 =C2=A0 =C2=A0 int err =3D 0;
> +
> + =C2=A0 =C2=A0 =C2=A0 if (f !=3D NULL) {

This check is redundant because the
caller(get_local_packet_info_from_fd) checks for NULL.

Move this function before get_local_packet_info_from_fd().

re-arranged code looks like:

int get_local_packet_info_from_file(...) {
=2E...
}

int get_local_packet_info_from_fd(...) {
   ...
   ... get_local_packet_info_from_file(f, ret);
   ....
}


Chetan

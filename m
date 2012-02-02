From: "Erich E. Hoover" <ehoover@mines.edu>
Subject: Re: [PATCH v2] Implement IP_UNICAST_IF socket option.
Date: Thu, 2 Feb 2012 15:29:44 -0700
Message-ID: <CAEU2+vrgxzTmiHWs-kVoKeu2_DcFZQBjCXwQfQ8dms5O6+Larg@mail.gmail.com>
References: <1328218567-3134-1-git-send-email-ehoover@mines.edu>
	<1328219828.2480.32.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from izzard.Mines.EDU ([138.67.132.197]:39148 "EHLO izzard.mines.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933483Ab2BBW3q convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 17:29:46 -0500
Received: from mail-vw0-f46.google.com (mail-vw0-f46.google.com [209.85.212.46])
	(authenticated bits=0)
	by izzard.mines.edu (8.13.8/8.13.8) with ESMTP id q12MTjNY002048
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <netdev@vger.kernel.org>; Thu, 2 Feb 2012 15:29:45 -0700
Received: by vbjk17 with SMTP id k17so2140111vbj.19
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2012 14:29:45 -0800 (PST)
In-Reply-To: <1328219828.2480.32.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 2, 2012 at 2:57 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le jeudi 02 f=E9vrier 2012 =E0 14:36 -0700, Erich E. Hoover a =E9crit=
 :
> > ...
> > + =A0 =A0 =A0 =A0 =A0 =A0 if (sk->sk_bound_dev_if && ifindex !=3D s=
k->sk_bound_dev_if)
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>
> what happens if later sk_bound_dev_if is changed ? Should we redo the
> above tests ?

Would it be better if ip_default_ifindex performed the same comparison
and prioritized the sk->sk_bound_dev_if value?

> > ...
> > + =A0 =A0 case IP_UNICAST_IF:
> > + =A0 =A0 {
> > + =A0 =A0 =A0 =A0 =A0 =A0 __be32 iface;
> > +
> > + =A0 =A0 =A0 =A0 =A0 =A0 len =3D sizeof(__be32);
> > + =A0 =A0 =A0 =A0 =A0 =A0 iface =3D htonl(inet->outif_index);
> > + =A0 =A0 =A0 =A0 =A0 =A0 release_sock(sk);
> > +
> > + =A0 =A0 =A0 =A0 =A0 =A0 if (put_user(len, optlen))
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EFAULT;
> > + =A0 =A0 =A0 =A0 =A0 =A0 if (copy_to_user(optval, &iface, len))
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EFAULT;
> > + =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>
> wow.... thats not pretty...
>
> =A0 =A0 =A0 =A0what about :
>
> =A0 =A0 =A0 =A0case IP_UNICASE_IF:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0val =3D htonl(inet->outif_index);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
>

The return value needs to be 4 bytes even if sizeof(int) !=3D 4.

> > ...
> IPv6 not supported ?

Nope, at least according to the documentation the option is only for
IPv4 (IPPROTO_IP).

Erich Hoover
ehoover@mines.edu

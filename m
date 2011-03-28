From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: zero copy for relay server
Date: Mon, 28 Mar 2011 20:34:17 +0200
Message-ID: <1301337257.2506.8.camel@edumazet-laptop>
References: <D69C90565D53114396BF743585AF5A09122E61E9E7@VSHINMSMBX01.vshodc.lntinfotech.com>
	 ,<1301331138.3182.43.camel@edumazet-laptop>
	 <D69C90565D53114396BF743585AF5A09122E61E9E9@VSHINMSMBX01.vshodc.lntinfotech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Viral Mehta <Viral.Mehta@lntinfotech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:61982 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754106Ab1C1SeW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2011 14:34:22 -0400
Received: by fxm17 with SMTP id 17so2897633fxm.19
        for <netdev@vger.kernel.org>; Mon, 28 Mar 2011 11:34:21 -0700 (PDT)
In-Reply-To: <D69C90565D53114396BF743585AF5A09122E61E9E9@VSHINMSMBX01.vshodc.lntinfotech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 28 mars 2011 =C3=A0 23:48 +0530, Viral Mehta a =C3=A9crit :

> Still, these are two system calls.

Yes. Is it a problem ? What kind ?

> In addition to this, many things to handle,
> 1. if the incoming_fd is blocking, then it will block till 64K data r=
ead. Why so ?

I dont think so. Try it, like read() of recv().

> 2. I believe underlying PIPE that we are using will also have some si=
ze limit
>     (like in user space 4K or 64K, not sure)

What kind of socket is able to deliver more than 64K frames ?

>=20
> So, all in all
> Why cant we have just one system call which really transfers "length"
> bytes of data form one socket to another ? Recv "length" bytes of dat=
a
> from socket A and send to socket B.
>=20
> I wanted to understand if there are any limitations or concerns that =
we still do
> not have any such system call .... ?
>=20

The answer is : Once you try to implement this, you'll discover it'll b=
e
splice() based, using pipe as a buffer between the sockets.

sendfile() is based on top of splice(), but it's faster to use splice()=
=2E




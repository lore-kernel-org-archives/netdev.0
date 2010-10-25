From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Enhance AF_PACKET implementation to not require high
 order contiguous memory allocation
Date: Tue, 26 Oct 2010 00:30:56 +0200
Message-ID: <1288045856.3296.19.camel@edumazet-laptop>
References: <E1PAVIx-0001qL-EB@smtp.tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, jpirko@redhat.com
To: "nhorman@tuxdriver.com" <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:42133 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932166Ab0JYWbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 18:31:09 -0400
Received: by wyf28 with SMTP id 28so3936558wyf.19
        for <netdev@vger.kernel.org>; Mon, 25 Oct 2010 15:31:08 -0700 (PDT)
In-Reply-To: <E1PAVIx-0001qL-EB@smtp.tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 25 octobre 2010 =C3=A0 18:14 -0400, nhorman@tuxdriver.com a =C3=
=A9crit :
> I think I remember those changes and IIrc yes,  tcpdump will make
> several attempts to get buffers of an appropriate size.  But while it
> tries to do that it bogs the system trying to write out pagecahe,
> swap, etc.  And that activity doesn't guarantee success.  His does
> either, but getting 5 order 0 pages is far easier and less intrusive
> to a loaded system than trying to get 1 order 4 chunk.  That's all I'=
m
> trying to accomplish here.  Just making it easier to use af_packet
> sockets without interfering with system performance
>=20

Actually, using vmalloc() would probably hurt performance, because of
extra TLB pressure.

Of course, on recent x86 hardware you dont notice that much...

If not, why af_packet would use such convoluted double array of
'compound pages' ?

Also, on x86_32, vmalloc()/vmap() space is small (128 MB) so you might
exhaust it pretty fast with several sniffers running.

I would try a two level thing : Try to get high order pages, and
fallback on low order pages, but normally libpcap does this for us ?




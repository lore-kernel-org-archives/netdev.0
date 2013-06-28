From: "Steinar H. Gunderson" <sesse@google.com>
Subject: Re: [PATCH v3] iwl3945: better skb management in rx path
Date: Sat, 29 Jun 2013 01:05:02 +0200
Message-ID: <CAMQErF45ZTdBDuGJ_zOZ=v28=Fj+LSNowKt_Bn6UVi5h14gt5A@mail.gmail.com>
References: <1372421021.3301.263.camel@edumazet-glaptop>
	<CAMcMvshEdsFZ2PVEpaq0e2P4L+cksshjB56x2YvA4wt3T+3__w@mail.gmail.com>
	<1372431024.3301.277.camel@edumazet-glaptop>
	<1372431906.3301.283.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Paul Stewart <pstew@google.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:36246 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750818Ab3F1XFD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jun 2013 19:05:03 -0400
Received: by mail-pd0-f177.google.com with SMTP id p10so1302305pdj.22
        for <netdev@vger.kernel.org>; Fri, 28 Jun 2013 16:05:02 -0700 (PDT)
In-Reply-To: <1372431906.3301.283.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/6/28 Eric Dumazet <eric.dumazet@gmail.com>:
> Steinar reported reallocations of skb->head with IPv6, leading to
> a warning in skb_try_coalesce()
>
> It turns out iwl3945 has several problems :
>
> 1) skb->truesize is underestimated.
>    We really consume PAGE_SIZE bytes for a fragment,
>    not the frame length.
> 2) 128 bytes of initial headroom is a bit low and forces reallocation=
s.
> 3) We can avoid consuming a full page for small enough frames.

I'm running 3.9.8 plus this patch (hand-applied since GMail mangled
it=E2=80=A6), and so far, it seems to work fine. Well, network-manager =
still
doesn't like Cisco's band-select feature, so from time to time I get
network freezes while it's trying to roam from 5 GHz to 2.4 GHz, but
that's hardly iwl3945's fault.

/* Steinar */
--=20
Software Engineer, Google Switzerland

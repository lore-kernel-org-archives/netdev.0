From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [PATCH] ipv6: fix a potential use after free in sit.c
Date: Sat, 18 Oct 2014 10:22:35 -0700
Message-ID: <CAA93jw7qxXCSkWc4YRyiAJ9bwQnk4PwYX8eKfwZyZ2qnhM7QYQ@mail.gmail.com>
References: <1413624818-20804-1-git-send-email-roy.qing.li@gmail.com>
	<1413647540.27176.36.camel@edumazet-glaptop2.roam.corp.google.com>
	<20141018.130720.448065424567018228.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, roy.qing.li@gmail.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	ghorbel@pivasoftware.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:36917 "EHLO
	mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751268AbaJRRWg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Oct 2014 13:22:36 -0400
Received: by mail-oi0-f41.google.com with SMTP id u20so1987837oif.0
        for <netdev@vger.kernel.org>; Sat, 18 Oct 2014 10:22:35 -0700 (PDT)
In-Reply-To: <20141018.130720.448065424567018228.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 18, 2014 at 10:07 AM, David Miller <davem@davemloft.net> wr=
ote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Indeed, I wish we could somehow automate this.
>
> Yes, I'm sure we could construct some sparse et al. rules but
> I mean at run time.  For example, having a special pointer type
> that you can't dereference directly.  At the time of assignment
> the pointer gets some kind of state, and pskb_may_pull() et al.
> calls invalidate that "state".
>
> It probably could just be a 2-bit counter which is incremented
> every time skb->data is reallocated.
>
> The captured 2-bit generation count could be stored in the low
> bits of the pointer.
>
> Anyways, just throwing out ideas...

So far as I know, the one machine linux has never been ported
to was a LISP machine. With its 36 bit words, and tagging, that
would do what you want. I had kind of hoped with 64 bits of
addressing some of those ideas would have been reused.

/me misses truly oddball architectures


--=20
Dave T=C3=A4ht

http://www.bufferbloat.net/projects/bloat/wiki/Upcoming_Talks

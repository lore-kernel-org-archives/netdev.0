From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: FIN_WAIT1 / TCP_CORK / 2.2 -- reproducible bug and test case
Date: Thu, 19 Sep 2002 03:38:37 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200209182338.DAA00778@mops.inr.ac.ru>
References: <20020918020927.GB2285@samba.org>
Mime-Version: 1.0
Cc: davem@redhat.com, ak@muc.de, netdev@oss.sgi.com, Alan.Cox@linux.org
Return-path: <netdev-bounce@oss.sgi.com>
To: mbp@samba.org (Martin Pool)
In-Reply-To: <20020918020927.GB2285@samba.org> from "Martin Pool" at Sep 18, 2 12:09:29 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> I can't reproduce it on 2.4.18 or .19.  It looked to me like
> tcp_snd_test() and related stuff had been substantially rewritten.

No, tcp_snd_test() in 2.2 is backport and it is accurate.
Apparently, the problem remained in another place, which was not backported.

I think this is tcp_send_fin(). It is obscure and apparently incorrect
at least on corked sockets. I would kill all the dubious "if" after

/* Special case to avoid Nagle bogosity....

and replaced it with straight tcp_push_pending_frames() like it was
made in 2.4. Please, try.

Alexey


BTW your tcpdump contains less than 25% of packets. And all the interesting
piece is absent completely. :-)

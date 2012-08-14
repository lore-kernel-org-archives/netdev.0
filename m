From: Bruce Curtis <brutus@google.com>
Subject: Re: [PATCH v2] net-tcp: TCP/IP stack bypass for loopback connections
Date: Tue, 14 Aug 2012 14:45:09 -0700
Message-ID: <CAEkNxbETGxFAHoNDK5qEmGo+PfLxmhCniLnOTkWxpK8Ycj_r0A@mail.gmail.com>
References: <1344559958-29162-1-git-send-email-brutus@google.com>
	<20120814.142228.85041202742435369.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: edumazet@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:43722 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753395Ab2HNVpL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2012 17:45:11 -0400
Received: by ggdk6 with SMTP id k6so1036748ggd.19
        for <netdev@vger.kernel.org>; Tue, 14 Aug 2012 14:45:10 -0700 (PDT)
In-Reply-To: <20120814.142228.85041202742435369.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 14, 2012 at 2:22 PM, David Miller <davem@davemloft.net> wro=
te:
>
> Bruce, could you integrate (and unlike your submission, actually buil=
d
> and run test) Weiping's bug fixes?
>
> Actually, I'm actually a little bit alarmed at Weiping's fixes,
> because it makes it look as if you didn't test things at all under
> net-next, as it appears that without his fixes any loopback TCP
> connection would OOPS the kernel.
>
??? rebase, build, boot a dev machine, run several hours of testing,
take numbers from test and updated commit message (commit message test
results changed from patch to patch submit because of this) so ???

> In fact, it wouldn't even build without the sysctl_tcp_friends typo.
> Indeed:
>
> net/ipv4/tcp.c: In function =91tcp_recvmsg=92:
> net/ipv4/tcp.c:1935:35: error: =91friends=92 undeclared (first use in=
 this function)
> net/ipv4/tcp.c:1935:35: note: each undeclared identifier is reported =
only once for each function it appears in
>
Didn't build with CONFIG_NET_DMA and wasn't caught as part of
rebase/local var name change.

> I hope I don't need to tell you how unacceptable this is.
>
> That also means that all of your measurements in the commit message
> weren't even made in the context where this patch will be applied.
>
> Also unacceptable.
>
I stand by my numbers!!!

> All of this makes for an extremely poor quality submission, please
> correct these issues.

Looking into Weiping's bug, can't simple use
lock_sock()/release_sock() due to A<>B locking issues (i.e.
bi-directional socket I/O).

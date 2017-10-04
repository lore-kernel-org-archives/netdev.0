From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: Fw: [Bug 197099] New: Kernel panic in interrupt [l2tp_ppp]
Date: Wed, 4 Oct 2017 12:33:53 +0200
Message-ID: <20171004103353.pdzwhp6c2kd34lgm@alphalink.fr>
References: <20171001102110.24184f1b@xeon-e3>
 <CAEwTi7QkF73cc1hShzOoM9bzb5mBzyFW8t68OCn+XECrJ9d61Q@mail.gmail.com>
 <1506952566.8061.3.camel@edumazet-glaptop3.roam.corp.google.com>
 <CA++DawY6CPh5S8A7pPE+-nwwGxJ4=pKL_MkXT_Q5TZb8xFnCjA@mail.gmail.com>
 <CAEwTi7S3-B81bNxyWq8j4hUpXyqNnTADReYoKoGF-V4wC5OBkQ@mail.gmail.com>
 <CAEwTi7SS7qsbV19NsPGwdiwTcejxygUEqQi-_MJ07uMec0CY9A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: SviMik <svimik@gmail.com>, netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:54088 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751335AbdJDKeA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 06:34:00 -0400
Content-Disposition: inline
In-Reply-To: <CAEwTi7SS7qsbV19NsPGwdiwTcejxygUEqQi-_MJ07uMec0CY9A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 04, 2017 at 08:49:51AM +0100, James Chapman wrote:
> On 3 October 2017 at 08:27, James Chapman <jchapman@katalix.com> wrote:
> > On 2 October 2017 at 19:35, SviMik <svimik@gmail.com> wrote:
> >> Hi, James!
> >>
> >> No, I'm suffering from kernel panics since I started using 4.x
> >> kernels.
> > It's interesting that you are seeing l2tp issues since switching to
> > 4.x kernels. Are you able to try earlier kernels to find the latest
> > version that works? I'm curious whether things broke at v3.15.
> 
> It's possible that this may be fixed by a patch that is already
> upstream and merged for v4.14. The fix is from Guillaume Nault:
> 
> f3c66d4 l2tp: prevent creation of sessions on terminated tunnels
> 
> If it's possible that the L2TP server may try to create a session in a
> tunnel that is being closed, this bug would be exposed.
>
Yes, I think this patch is worth a try. In the case of sessions created
on a dead tunnel, I wouldn't have expected the xmit path to even reach
l2tp_xmit_skb() though (that's certainly possible, but the timing
constraints look a bit hard to reach).


BTW, I started working on this issue a few days ago and came to the
same conclusions as the ones you posted in your previous replies. Given
that we were in line with the analysis, I've switched to the PPP bug
reported by Beniamino (https://www.spinics.net/lists/netdev/msg458002.html).
I'll move back to L2TP as soon as possible.

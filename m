From: Kaiwen Xu <kaiwen.xu@hulu.com>
Subject: Re: [PATCH net v2] net: Do not hold the reference for the same
 sk_rx_dst
Date: Mon, 20 Mar 2017 14:23:47 -0700
Message-ID: <20170320212347.GA80810@kevinmbp.test.hulu.com>
References: <20170316.111647.1545474188593011995.davem@davemloft.net>
 <1489888121-1051-1-git-send-email-kaiwen.xu@hulu.com>
 <CAM_iQpXFY+isbSR71GWyf_=-o-LEB6Ftj6P0_5c3zf9echsGnA@mail.gmail.com>
 <20170319040354.GA59612@kevinmbp.test.hulu.com>
 <CAM_iQpWzx8j9ZXZquQn_Jj7-w=Cts-bZxL7UdA39_Vu+=SzuAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0105.outbound.protection.outlook.com ([104.47.40.105]:50880
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754325AbdCTV6v (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Mar 2017 17:58:51 -0400
Content-Disposition: inline
In-Reply-To: <CAM_iQpWzx8j9ZXZquQn_Jj7-w=Cts-bZxL7UdA39_Vu+=SzuAg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 19, 2017 at 09:09:38PM -0700, Cong Wang wrote:
> On Sat, Mar 18, 2017 at 9:03 PM, Kaiwen Xu <kaiwen.xu@hulu.com> wrote:
> > On Sat, Mar 18, 2017 at 08:49:43PM -0700, Cong Wang wrote:
> >> On Sat, Mar 18, 2017 at 6:48 PM, Kevin Xu <kaiwen.xu@hulu.com> wrote:
> >> > In some rare cases, inet_sk_rx_dst_set() may be called multiple times
> >> > on the same dst, causing double refcounting. Eventually, it
> >> > prevents net_device to be destroyed. The bug manifested as
> >> >
> >> > unregister_netdevice: waiting for lo to become free. Usage count = 1
> >> >
> >> > in the kernel log, preventing new network namespace creation.
> >> >
> >> > Signed-off-by: Kevin Xu <kaiwen.xu@hulu.com>
> >>
> >> Don't know why you don't follow the discussion on your v1...
> >>
> >> It is protected by bh_lock_sock(), so your patch is not needed
> >> at all.
> >>
> >> Read net/ipv4/udp.c:
> >>
> >> 1762 /* For TCP sockets, sk_rx_dst is protected by socket lock
> >> 1763  * For UDP, we use xchg() to guard against concurrent changes.
> >> 1764  */
> >
> > I probably misunderstood. Do you mean v2 patch is actually not needed or
> > the whole workaround is not necessary?
> 
> Your patch, no matter v1 or v2, is not needed because we use
> bh_lock_sock() to serialize inet_sk_rx_dst_set(), unless you find
> a case where we miss the bh_lock_sock(), but you don't say it in
> your changelog. "some rare cases" is not enough to justify this bug.

I see, thanks for your explanation! I will try to dig in more to see if
I can find the root cause.

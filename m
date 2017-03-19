From: Kaiwen Xu <kaiwen.xu@hulu.com>
Subject: Re: [PATCH net v2] net: Do not hold the reference for the same
 sk_rx_dst
Date: Sat, 18 Mar 2017 21:03:54 -0700
Message-ID: <20170319040354.GA59612@kevinmbp.test.hulu.com>
References: <20170316.111647.1545474188593011995.davem@davemloft.net>
 <1489888121-1051-1-git-send-email-kaiwen.xu@hulu.com>
 <CAM_iQpXFY+isbSR71GWyf_=-o-LEB6Ftj6P0_5c3zf9echsGnA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0137.outbound.protection.outlook.com ([104.47.32.137]:35995
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750725AbdCSEEE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 19 Mar 2017 00:04:04 -0400
Content-Disposition: inline
In-Reply-To: <CAM_iQpXFY+isbSR71GWyf_=-o-LEB6Ftj6P0_5c3zf9echsGnA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 18, 2017 at 08:49:43PM -0700, Cong Wang wrote:
> On Sat, Mar 18, 2017 at 6:48 PM, Kevin Xu <kaiwen.xu@hulu.com> wrote:
> > In some rare cases, inet_sk_rx_dst_set() may be called multiple times
> > on the same dst, causing double refcounting. Eventually, it
> > prevents net_device to be destroyed. The bug manifested as
> >
> > unregister_netdevice: waiting for lo to become free. Usage count = 1
> >
> > in the kernel log, preventing new network namespace creation.
> >
> > Signed-off-by: Kevin Xu <kaiwen.xu@hulu.com>
> 
> Don't know why you don't follow the discussion on your v1...
> 
> It is protected by bh_lock_sock(), so your patch is not needed
> at all.
> 
> Read net/ipv4/udp.c:
> 
> 1762 /* For TCP sockets, sk_rx_dst is protected by socket lock
> 1763  * For UDP, we use xchg() to guard against concurrent changes.
> 1764  */

I probably misunderstood. Do you mean v2 patch is actually not needed or
the whole workaround is not necessary?

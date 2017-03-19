From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net v2] net: Do not hold the reference for the same sk_rx_dst
Date: Sat, 18 Mar 2017 20:49:43 -0700
Message-ID: <CAM_iQpXFY+isbSR71GWyf_=-o-LEB6Ftj6P0_5c3zf9echsGnA@mail.gmail.com>
References: <20170316.111647.1545474188593011995.davem@davemloft.net> <1489888121-1051-1-git-send-email-kaiwen.xu@hulu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Kevin Xu <kaiwen.xu@hulu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36198 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751327AbdCSDuF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 18 Mar 2017 23:50:05 -0400
Received: by mail-wm0-f67.google.com with SMTP id x124so9091555wmf.3
        for <netdev@vger.kernel.org>; Sat, 18 Mar 2017 20:50:04 -0700 (PDT)
In-Reply-To: <1489888121-1051-1-git-send-email-kaiwen.xu@hulu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 18, 2017 at 6:48 PM, Kevin Xu <kaiwen.xu@hulu.com> wrote:
> In some rare cases, inet_sk_rx_dst_set() may be called multiple times
> on the same dst, causing double refcounting. Eventually, it
> prevents net_device to be destroyed. The bug manifested as
>
> unregister_netdevice: waiting for lo to become free. Usage count = 1
>
> in the kernel log, preventing new network namespace creation.
>
> Signed-off-by: Kevin Xu <kaiwen.xu@hulu.com>

Don't know why you don't follow the discussion on your v1...

It is protected by bh_lock_sock(), so your patch is not needed
at all.

Read net/ipv4/udp.c:

1762 /* For TCP sockets, sk_rx_dst is protected by socket lock
1763  * For UDP, we use xchg() to guard against concurrent changes.
1764  */

From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net v2] net: Do not hold the reference for the same sk_rx_dst
Date: Sun, 19 Mar 2017 21:09:38 -0700
Message-ID: <CAM_iQpWzx8j9ZXZquQn_Jj7-w=Cts-bZxL7UdA39_Vu+=SzuAg@mail.gmail.com>
References: <20170316.111647.1545474188593011995.davem@davemloft.net>
 <1489888121-1051-1-git-send-email-kaiwen.xu@hulu.com> <CAM_iQpXFY+isbSR71GWyf_=-o-LEB6Ftj6P0_5c3zf9echsGnA@mail.gmail.com>
 <20170319040354.GA59612@kevinmbp.test.hulu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Kaiwen Xu <kaiwen.xu@hulu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:33403 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750779AbdCTEQm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 00:16:42 -0400
Received: by mail-wr0-f193.google.com with SMTP id g10so16420051wrg.0
        for <netdev@vger.kernel.org>; Sun, 19 Mar 2017 21:16:41 -0700 (PDT)
In-Reply-To: <20170319040354.GA59612@kevinmbp.test.hulu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 18, 2017 at 9:03 PM, Kaiwen Xu <kaiwen.xu@hulu.com> wrote:
> On Sat, Mar 18, 2017 at 08:49:43PM -0700, Cong Wang wrote:
>> On Sat, Mar 18, 2017 at 6:48 PM, Kevin Xu <kaiwen.xu@hulu.com> wrote:
>> > In some rare cases, inet_sk_rx_dst_set() may be called multiple times
>> > on the same dst, causing double refcounting. Eventually, it
>> > prevents net_device to be destroyed. The bug manifested as
>> >
>> > unregister_netdevice: waiting for lo to become free. Usage count = 1
>> >
>> > in the kernel log, preventing new network namespace creation.
>> >
>> > Signed-off-by: Kevin Xu <kaiwen.xu@hulu.com>
>>
>> Don't know why you don't follow the discussion on your v1...
>>
>> It is protected by bh_lock_sock(), so your patch is not needed
>> at all.
>>
>> Read net/ipv4/udp.c:
>>
>> 1762 /* For TCP sockets, sk_rx_dst is protected by socket lock
>> 1763  * For UDP, we use xchg() to guard against concurrent changes.
>> 1764  */
>
> I probably misunderstood. Do you mean v2 patch is actually not needed or
> the whole workaround is not necessary?

Your patch, no matter v1 or v2, is not needed because we use
bh_lock_sock() to serialize inet_sk_rx_dst_set(), unless you find
a case where we miss the bh_lock_sock(), but you don't say it in
your changelog. "some rare cases" is not enough to justify this bug.

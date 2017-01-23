From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Question about veth_xmit()
Date: Mon, 23 Jan 2017 12:56:05 -0800
Message-ID: <CAM_iQpVXOsPZrAhBN10JYrVjOOK2_q7=gsFbsi_=s5XZLj1S+g@mail.gmail.com>
References: <CAOwmpL3vg56ZqHaYVBy+9dJJ1=GCbgy-m8NY0JrNCV-Z42R_eg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Xiangning Yu <yuxiangning@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:37629 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750714AbdAWU4n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 15:56:43 -0500
Received: by mail-wm0-f43.google.com with SMTP id c206so176576803wme.0
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 12:56:26 -0800 (PST)
In-Reply-To: <CAOwmpL3vg56ZqHaYVBy+9dJJ1=GCbgy-m8NY0JrNCV-Z42R_eg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 23, 2017 at 10:46 AM, Xiangning Yu <yuxiangning@gmail.com> wrote:
> Hi netdev folks,
>
> It looks like we call dev_forward_skb() in veth_xmit(), which calls
> netif_rx() eventually.
>
> While netif_rx() will enqueue the skb to the CPU RX backlog before the
> actual processing takes place. So, this actually means a TX skb has to
> wait some un-related RX skbs to finish. And this will happen twice for
> a single ping, because the veth device always works as a pair?

For me it is more like for the completeness of network stack of each
netns. The /proc net.core.netdev_max_backlog etc. are per netns, which
means each netns, as an independent network stack, should respect it
too.

Since you care about latency, why not tune net.core.dev_weight for your
own netns?

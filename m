From: Xiangning Yu <yuxiangning@gmail.com>
Subject: Re: Question about veth_xmit()
Date: Mon, 23 Jan 2017 13:46:56 -0800
Message-ID: <CAOwmpL3fiGcXHmUouzRf8vneSF1SQ5SWVqYLXGVecLTepZTNOw@mail.gmail.com>
References: <CAOwmpL3vg56ZqHaYVBy+9dJJ1=GCbgy-m8NY0JrNCV-Z42R_eg@mail.gmail.com>
 <CAM_iQpVXOsPZrAhBN10JYrVjOOK2_q7=gsFbsi_=s5XZLj1S+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:34324 "EHLO
        mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751082AbdAWVq5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 16:46:57 -0500
Received: by mail-io0-f181.google.com with SMTP id l66so121010672ioi.1
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 13:46:57 -0800 (PST)
In-Reply-To: <CAM_iQpVXOsPZrAhBN10JYrVjOOK2_q7=gsFbsi_=s5XZLj1S+g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 23, 2017 at 12:56 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Mon, Jan 23, 2017 at 10:46 AM, Xiangning Yu <yuxiangning@gmail.com> wrote:
>> Hi netdev folks,
>>
>> It looks like we call dev_forward_skb() in veth_xmit(), which calls
>> netif_rx() eventually.
>>
>> While netif_rx() will enqueue the skb to the CPU RX backlog before the
>> actual processing takes place. So, this actually means a TX skb has to
>> wait some un-related RX skbs to finish. And this will happen twice for
>> a single ping, because the veth device always works as a pair?
>
> For me it is more like for the completeness of network stack of each
> netns. The /proc net.core.netdev_max_backlog etc. are per netns, which
> means each netns, as an independent network stack, should respect it
> too.
>
> Since you care about latency, why not tune net.core.dev_weight for your
> own netns?

I haven't tried that yet, thank you for the hint! Though normally one
of the veth device will be in the global namespace.

Thanks,
- Xiangning

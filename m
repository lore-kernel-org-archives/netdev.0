From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Question about veth_xmit()
Date: Mon, 23 Jan 2017 14:42:21 -0800
Message-ID: <CAM_iQpWXL1VKOHAsxX9a-Rr-oqWKX-bSFr=7uO1Jd4XtkpW+Zw@mail.gmail.com>
References: <CAOwmpL3vg56ZqHaYVBy+9dJJ1=GCbgy-m8NY0JrNCV-Z42R_eg@mail.gmail.com>
 <CAM_iQpVXOsPZrAhBN10JYrVjOOK2_q7=gsFbsi_=s5XZLj1S+g@mail.gmail.com>
 <CAOwmpL3fiGcXHmUouzRf8vneSF1SQ5SWVqYLXGVecLTepZTNOw@mail.gmail.com> <1485209145.16328.214.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Xiangning Yu <yuxiangning@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:35042 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751355AbdAWWmn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 17:42:43 -0500
Received: by mail-wm0-f53.google.com with SMTP id r126so155701209wmr.0
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 14:42:42 -0800 (PST)
In-Reply-To: <1485209145.16328.214.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 23, 2017 at 2:05 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2017-01-23 at 13:46 -0800, Xiangning Yu wrote:
>> On Mon, Jan 23, 2017 at 12:56 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> > On Mon, Jan 23, 2017 at 10:46 AM, Xiangning Yu <yuxiangning@gmail.com> wrote:
>> >> Hi netdev folks,
>> >>
>> >> It looks like we call dev_forward_skb() in veth_xmit(), which calls
>> >> netif_rx() eventually.
>> >>
>> >> While netif_rx() will enqueue the skb to the CPU RX backlog before the
>> >> actual processing takes place. So, this actually means a TX skb has to
>> >> wait some un-related RX skbs to finish. And this will happen twice for
>> >> a single ping, because the veth device always works as a pair?
>> >
>> > For me it is more like for the completeness of network stack of each
>> > netns. The /proc net.core.netdev_max_backlog etc. are per netns, which
>> > means each netns, as an independent network stack, should respect it
>> > too.
>> >
>> > Since you care about latency, why not tune net.core.dev_weight for your
>> > own netns?
>>
>> I haven't tried that yet, thank you for the hint! Though normally one
>> of the veth device will be in the global namespace.
>
> Well, per cpu backlog are not per net ns, but per cpu.

Right, they all point to a same weight_p. But weight_p itself
is not per cpu, softnet_data is. However, if a container uses
cpuset and netns for isolations, per cpu will turn into per netns.

The point of network stack completeness still stands.

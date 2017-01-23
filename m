From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Question about veth_xmit()
Date: Mon, 23 Jan 2017 14:05:45 -0800
Message-ID: <1485209145.16328.214.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAOwmpL3vg56ZqHaYVBy+9dJJ1=GCbgy-m8NY0JrNCV-Z42R_eg@mail.gmail.com>
         <CAM_iQpVXOsPZrAhBN10JYrVjOOK2_q7=gsFbsi_=s5XZLj1S+g@mail.gmail.com>
         <CAOwmpL3fiGcXHmUouzRf8vneSF1SQ5SWVqYLXGVecLTepZTNOw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Xiangning Yu <yuxiangning@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33111 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751337AbdAWWFr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 17:05:47 -0500
Received: by mail-pg0-f65.google.com with SMTP id 194so14722089pgd.0
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 14:05:47 -0800 (PST)
In-Reply-To: <CAOwmpL3fiGcXHmUouzRf8vneSF1SQ5SWVqYLXGVecLTepZTNOw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-01-23 at 13:46 -0800, Xiangning Yu wrote:
> On Mon, Jan 23, 2017 at 12:56 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> > On Mon, Jan 23, 2017 at 10:46 AM, Xiangning Yu <yuxiangning@gmail.com> wrote:
> >> Hi netdev folks,
> >>
> >> It looks like we call dev_forward_skb() in veth_xmit(), which calls
> >> netif_rx() eventually.
> >>
> >> While netif_rx() will enqueue the skb to the CPU RX backlog before the
> >> actual processing takes place. So, this actually means a TX skb has to
> >> wait some un-related RX skbs to finish. And this will happen twice for
> >> a single ping, because the veth device always works as a pair?
> >
> > For me it is more like for the completeness of network stack of each
> > netns. The /proc net.core.netdev_max_backlog etc. are per netns, which
> > means each netns, as an independent network stack, should respect it
> > too.
> >
> > Since you care about latency, why not tune net.core.dev_weight for your
> > own netns?
> 
> I haven't tried that yet, thank you for the hint! Though normally one
> of the veth device will be in the global namespace.

Well, per cpu backlog are not per net ns, but per cpu.

So Cong suggestion is not going to work.

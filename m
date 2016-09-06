From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next 1/1] net_sched: Introduce skbmod action
Date: Tue, 06 Sep 2016 07:25:19 -0700
Message-ID: <1473171919.10725.3.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1472386756-23085-1-git-send-email-jhs@emojatatu.com>
         <1472400467.14381.252.camel@edumazet-glaptop3.roam.corp.google.com>
         <b075631d-92cc-d016-3786-aaacb3d5c13a@mojatatu.com>
         <b117fac2-c73f-2d42-3843-52f9717224d9@mojatatu.com>
         <1472494817.14381.267.camel@edumazet-glaptop3.roam.corp.google.com>
         <2a6e36a6-f128-ba9d-4d69-90ff5383fb75@mojatatu.com>
         <68852282-b009-7b5b-6887-1630935b1913@mojatatu.com>
         <1472561089.14381.296.camel@edumazet-glaptop3.roam.corp.google.com>
         <a90c3d11-e1e9-3f58-5400-8b910d707351@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, daniel@iogearbox.net,
        xiyou.wangcong@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:33849 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751221AbcIFOZW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 10:25:22 -0400
Received: by mail-pf0-f180.google.com with SMTP id p64so75069026pfb.1
        for <netdev@vger.kernel.org>; Tue, 06 Sep 2016 07:25:21 -0700 (PDT)
In-Reply-To: <a90c3d11-e1e9-3f58-5400-8b910d707351@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-09-06 at 08:08 -0400, Jamal Hadi Salim wrote:
> ng
> On 16-08-30 08:44 AM, Eric Dumazet wrote:
> > On Tue, 2016-08-30 at 07:57 -0400, Jamal Hadi Salim wrote:
> >>         if (flags & SKBMOD_F_SWAPMAC) {
> >>                 u8 tmpaddr[ETH_ALEN];
> >>                 /*XXX: I am sure we can come up with something more efficient */
> >>                 ether_addr_copy(tmpaddr, eth_hdr(skb)->h_dest);
> >>                 ether_addr_copy(eth_hdr(skb)->h_dest, eth_hdr(skb)->h_source);
> >>                 ether_addr_copy(eth_hdr(skb)->h_source, tmpaddr);
> >>         }
> >
> > While ether_addr_copy() is accepting u8 pointers, data must be aligned to u16 at least.
> >
> > (See comments in include/linux/etherdevice.h)
> >
> > Some arches/compilers might do things here that would generate a trap
> > if tmpaddr is not aligned.
> >
> 
> Hrm. How do you suggest dealing with this?

Just use u16 in the array ?

u16 tmpaddr[ETH_ALEN / 2]; /* ether_addr_copy() requirement */

ether_addr_copy((u8 *)tmpaddr, eth_hdr(skb)->h_dest);
...

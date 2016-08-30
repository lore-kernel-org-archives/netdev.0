From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next 1/1] net_sched: Introduce skbmod action
Date: Tue, 30 Aug 2016 05:44:49 -0700
Message-ID: <1472561089.14381.296.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1472386756-23085-1-git-send-email-jhs@emojatatu.com>
         <1472400467.14381.252.camel@edumazet-glaptop3.roam.corp.google.com>
         <b075631d-92cc-d016-3786-aaacb3d5c13a@mojatatu.com>
         <b117fac2-c73f-2d42-3843-52f9717224d9@mojatatu.com>
         <1472494817.14381.267.camel@edumazet-glaptop3.roam.corp.google.com>
         <2a6e36a6-f128-ba9d-4d69-90ff5383fb75@mojatatu.com>
         <68852282-b009-7b5b-6887-1630935b1913@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, daniel@iogearbox.net,
        xiyou.wangcong@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33186 "EHLO
        mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757333AbcH3Mow (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 08:44:52 -0400
Received: by mail-pa0-f49.google.com with SMTP id cy9so7467442pac.0
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2016 05:44:51 -0700 (PDT)
In-Reply-To: <68852282-b009-7b5b-6887-1630935b1913@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-08-30 at 07:57 -0400, Jamal Hadi Salim wrote:
>         if (flags & SKBMOD_F_SWAPMAC) {
>                 u8 tmpaddr[ETH_ALEN];
>                 /*XXX: I am sure we can come up with something more efficient */
>                 ether_addr_copy(tmpaddr, eth_hdr(skb)->h_dest);
>                 ether_addr_copy(eth_hdr(skb)->h_dest, eth_hdr(skb)->h_source);
>                 ether_addr_copy(eth_hdr(skb)->h_source, tmpaddr);
>         }

While ether_addr_copy() is accepting u8 pointers, data must be aligned to u16 at least.

(See comments in include/linux/etherdevice.h)

Some arches/compilers might do things here that would generate a trap
if tmpaddr is not aligned.

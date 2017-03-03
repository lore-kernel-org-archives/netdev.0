From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: net: heap out-of-bounds in
 fib6_clean_node/rt6_fill_node/fib6_age/fib6_prune_clone
Date: Fri, 3 Mar 2017 11:12:39 -0800
Message-ID: <f707c195-251f-6058-5f4c-d55710533b11@cumulusnetworks.com>
References: <CACT4Y+YrA45diWz_8f4St8oX6aTC1kuGXMUvniGRbqXSGwawZQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: syzkaller <syzkaller@googlegroups.com>
To: Dmitry Vyukov <dvyukov@google.com>,
        Mahesh Bandewar <maheshb@google.com>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:36399 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751641AbdCCTTv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Mar 2017 14:19:51 -0500
Received: by mail-pg0-f46.google.com with SMTP id s67so46863504pgb.3
        for <netdev@vger.kernel.org>; Fri, 03 Mar 2017 11:18:56 -0800 (PST)
In-Reply-To: <CACT4Y+YrA45diWz_8f4St8oX6aTC1kuGXMUvniGRbqXSGwawZQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/3/17 6:39 AM, Dmitry Vyukov wrote:
> I am getting heap out-of-bounds reports in
> fib6_clean_node/rt6_fill_node/fib6_age/fib6_prune_clone while running
> syzkaller fuzzer on 86292b33d4b79ee03e2f43ea0381ef85f077c760. They all
> follow the same pattern: an object of size 216 is allocated from
> ip_dst_cache slab, and then accessed at offset 272/276 withing
> fib6_walk. Looks like type confusion. Unfortunately this is not
> reproducible.

I'll take a look this weekend or Monday at the latest.

From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: use an RB tree for ooo receive queue
Date: Wed, 07 Sep 2016 15:32:49 -0700
Message-ID: <1473287569.15733.10.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1473284968.15733.8.camel@edumazet-glaptop3.roam.corp.google.com>
         <20160907152637.7df3f9d9@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Yaogong Wang <wygivan@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:35026 "EHLO
        mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750859AbcIGWcv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 18:32:51 -0400
Received: by mail-pa0-f49.google.com with SMTP id b2so10380143pat.2
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2016 15:32:51 -0700 (PDT)
In-Reply-To: <20160907152637.7df3f9d9@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-09-07 at 15:26 -0700, Stephen Hemminger wrote:

> How much does this grow the size of tcp socket structure?

This actually shrinks it by 8 bytes, or more on debug kernels where
sizeof(spinlock_t) > 4

Before :

struct sk_buff_head out_of_order_queue;  // At least 24 bytes on 64bit 


After :

2 pointers ( 16 bytes on 64bit )

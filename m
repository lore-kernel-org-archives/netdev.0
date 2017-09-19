From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: avoid bogus warning in tcp_clean_rtx_queue
Date: Tue, 19 Sep 2017 15:01:46 -0700 (PDT)
Message-ID: <20170919.150146.960352165896854483.davem@davemloft.net>
References: <20170918204855.170920-1-arnd@arndb.de>
        <20170919.140250.1393293793761020505.davem@davemloft.net>
        <CAK8P3a3G78pqFsoimeNrKnPLOUYR+X1qzhbKyabn_tN4oZMLyQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, edumazet@google.com,
        ncardwell@google.com, ycheng@google.com, soheil@google.com,
        fw@strlen.de, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAK8P3a3G78pqFsoimeNrKnPLOUYR+X1qzhbKyabn_tN4oZMLyQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 19 Sep 2017 23:32:33 +0200

> On Tue, Sep 19, 2017 at 11:02 PM, David Miller <davem@davemloft.net> wrote:
>> What cpu did you test the object code generation upon and does that
>> cpu have branch prediction hints in the target you are building for?
> 
> This was a randconfig build targetting ARMv5. I'm pretty sure that has
> no such hint instructions.

I just tested on sparc64 and it changed the branch prediction:

 .L2157:
-       brz,pn  %i3, .L1898     ! first_ackt,
+       brz,pt  %i2, .L1898     ! first_ackt,
         mov    -1, %o2 !, seq_rtt_us

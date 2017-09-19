From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: avoid bogus warning in tcp_clean_rtx_queue
Date: Tue, 19 Sep 2017 14:02:50 -0700 (PDT)
Message-ID: <20170919.140250.1393293793761020505.davem@davemloft.net>
References: <20170918204855.170920-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, edumazet@google.com,
        ncardwell@google.com, ycheng@google.com, soheil@google.com,
        fw@strlen.de, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170918204855.170920-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 18 Sep 2017 22:48:47 +0200

> gcc-4.9 warns that it cannot trace the state of the 'last_ackt'
> variable since the change to the TCP timestamping code, when
> CONFIG_PROFILE_ANNOTATED_BRANCHES is set:
> 
> net/ipv4/tcp_input.c: In function 'tcp_clean_rtx_queue':
> include/net/tcp.h:757:23: error: 'last_ackt' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> 
> Other gcc versions, both older and newer do now show this
> warning. Removing the 'likely' annotation makes it go away,
> and has no effect on the object code without
> CONFIG_PROFILE_ANNOTATED_BRANCHES, as tested with gcc-4.9
> and gcc-7.1.1, so this seems to be a safe workaround.
> 
> Fixes: 9a568de4818d ("tcp: switch TCP TS option (RFC 7323) to 1ms clock")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

This reaches the limits at which I am willing to work around compiler
stuff.

What cpu did you test the object code generation upon and does that
cpu have branch prediction hints in the target you are building for?

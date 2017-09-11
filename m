From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: WARNING in skb_warn_bad_offload
Date: Mon, 11 Sep 2017 08:04:53 +0200
Message-ID: <20170911060453.6rpx5z3vj25qpcwn@unicorn.suse.cz>
References: <CAJsXRPE+k=S6Ax92hLjzFNr1JsG7kA_6JT0xuJqZ87VOriUphg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, edumazet@google.com, daniel@iogearbox.net,
        alexander.h.duyck@intel.com, dsa@cumulusnetworks.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>, me@tobin.cc,
        stephen@networkplumber.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, security@kernel.org,
        syzkaller@googlegroups.com
To: Dison River <pwn2river@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:43118 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750742AbdIKGE6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 11 Sep 2017 02:04:58 -0400
Content-Disposition: inline
In-Reply-To: <CAJsXRPE+k=S6Ax92hLjzFNr1JsG7kA_6JT0xuJqZ87VOriUphg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 11, 2017 at 12:20:32PM +0800, Dison River wrote:
> I found a warning while fuzzing with Syzkaller on linux 4.13-rc6 on
> x86_64. The full stack trace is below:
> 
> ------------[ cut here ]------------
> WARNING: CPU: 3 PID: 32413 at net/core/dev.c:2592
> skb_warn_bad_offload+0x2a9/0x380 net/core/dev.c:2587
> Kernel panic - not syncing: panic_on_warn set ...
> 
> CPU: 3 PID: 32413 Comm: syz-executor3 Not tainted 4.13.0-rc6+ #1
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> Call Trace:

Are you sure you didn't omit something? This WARN() check should write
some useful information but I can't see it in your mail:

        WARN(1, "%s: caps=(%pNF, %pNF) len=%d data_len=%d gso_size=%d "
             "gso_type=%d ip_summed=%d\n",
             name, dev ? &dev->features : &null_features,
             skb->sk ? &skb->sk->sk_route_caps : &null_features,
             skb->len, skb->data_len, skb_shinfo(skb)->gso_size,
             skb_shinfo(skb)->gso_type, skb->ip_summed);

Michal Kubecek

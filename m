From: Brenden Blanco <bblanco@plumgrid.com>
Subject: Re: [PATCH] net/mlx4_en: protect ring->xdp_prog with rcu_read_lock
Date: Fri, 2 Sep 2016 11:13:53 -0700
Message-ID: <20160902181352.GC14176@gmail.com>
References: <20160826203808.23664-1-bblanco@plumgrid.com>
 <c03157a0-b7d0-bde7-0fe9-4f3b19a68d08@mellanox.com>
 <20160829155558.GA13971@gmail.com>
 <CALx6S34nt0iLEse45y4UrJFbfBFNoZ6oYzu+3Hdq3A=6Rn9hrg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tariq Toukan <tariqt@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Tariq Toukan <ttoukan.linux@gmail.com>,
        Or Gerlitz <gerlitz.or@gmail.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:33264 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753772AbcIBSN4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 14:13:56 -0400
Received: by mail-pf0-f174.google.com with SMTP id g202so21524633pfb.0
        for <netdev@vger.kernel.org>; Fri, 02 Sep 2016 11:13:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALx6S34nt0iLEse45y4UrJFbfBFNoZ6oYzu+3Hdq3A=6Rn9hrg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 29, 2016 at 10:46:38AM -0700, Tom Herbert wrote:
[...]
> Brenden, tracking down how the structure is freed needed a few steps,
> please make sure the RCU requirements are well documented. Also, I'm
Really? It's just bpf_prog_put->call_rcu(__bpf_prog_put_rcu). I suppose
what's missing is a general guideline for which functions new consumers
of bpf should use, but I wouldn't trust myself to write such holistic
documentation accurately (e.g. interacting with nmi probes and such).
> still not a fan of using xchg to set the program, seems that a lock
> could be used in that path.
Where would such a lock go? Everything in mlx4/en_netdev.c relies on
rtnl, which seems sufficient and obvious...adding some new field
specific lock would be distracting and unneeded.
> 
> Thanks,
> Tom

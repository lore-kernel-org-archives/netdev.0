From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 7/8] net/mlx5e: XDP TX forwarding support
Date: Tue, 20 Sep 2016 10:39:20 -0700
Message-ID: <1474393160.23058.39.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1474293539-2595-8-git-send-email-tariqt@mellanox.com>
         <20160920102943.24732097@brouer.com> <20160920133300.144037fd@redhat.com>
         <96b40925-0e8e-0230-0701-96c11d6921a1@gmail.com>
         <20160920154036.GA98644@ast-mbp.thefacebook.com>
         <CALx6S34YBsmSJr7z2wGsu1VvLkjoqTN+Q8JJ0j-H_DehMJzQ5g@mail.gmail.com>
         <1474387110.23058.24.camel@edumazet-glaptop3.roam.corp.google.com>
         <20160920180609.148874b5@redhat.com>
         <1474388036.23058.26.camel@edumazet-glaptop3.roam.corp.google.com>
         <20160920182717.2de9541e@redhat.com>
         <20160920164526.GB99429@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
        Tom Herbert <tom@herbertland.com>,
        Tariq Toukan <ttoukan.linux@gmail.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eran Ben Elisha <eranbe@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Rana Shahout <ranas@mellanox.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:36045 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755674AbcITRjW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 13:39:22 -0400
Received: by mail-pf0-f178.google.com with SMTP id q2so9545069pfj.3
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 10:39:22 -0700 (PDT)
In-Reply-To: <20160920164526.GB99429@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-09-20 at 09:45 -0700, Alexei Starovoitov wrote:

> because 'div by zero' is an abnormal situation that shouldn't be exploited.
> Meaning if xdp program is doing DoS prevention and it has a bug that
> attacker can now exploit by sending a crafted packet that causes
> 'div by zero' and kernel will warn then attack got successful.
> Therefore it has to be silent drop.

A silent drop means a genuine error in a BPF program might be never
caught, since a tracepoint might never be enabled.

> tracpoint in such case is great, since the user can do debugging with it
> and even monitoring 24/7 and if suddenly the control plan sees a lot
> of such trace_xdp_abotred events, it can disable that tracepoint to avoid
> spam and adjust the program or act on attack some other way.
> Hardcoded warnings and counters are not generic enough for all
> the use cases people want to throw at XDP.
> The tracepoints idea is awesome, in a sense that it's optional.


Note that tracepoints are optional in a kernel.

Many existing supervision infrastructures collect device snmp counters,
and run as unprivileged programs. 

tracepoints might not fit the need here, compared to a mere
tx_ring->tx_drops++

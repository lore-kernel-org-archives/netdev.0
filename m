From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next 7/8] net/mlx5e: XDP TX forwarding support
Date: Tue, 20 Sep 2016 20:59:39 +0200
Message-ID: <20160920205939.6a4522df@redhat.com>
References: <1474293539-2595-8-git-send-email-tariqt@mellanox.com>
        <20160920102943.24732097@brouer.com>
        <20160920133300.144037fd@redhat.com>
        <96b40925-0e8e-0230-0701-96c11d6921a1@gmail.com>
        <20160920154036.GA98644@ast-mbp.thefacebook.com>
        <CALx6S34YBsmSJr7z2wGsu1VvLkjoqTN+Q8JJ0j-H_DehMJzQ5g@mail.gmail.com>
        <1474387110.23058.24.camel@edumazet-glaptop3.roam.corp.google.com>
        <20160920180609.148874b5@redhat.com>
        <1474388036.23058.26.camel@edumazet-glaptop3.roam.corp.google.com>
        <20160920182717.2de9541e@redhat.com>
        <20160920164526.GB99429@ast-mbp.thefacebook.com>
        <1474393160.23058.39.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Tariq Toukan <ttoukan.linux@gmail.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eran Ben Elisha <eranbe@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Rana Shahout <ranas@mellanox.com>, brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56804 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932189AbcITS7q (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Sep 2016 14:59:46 -0400
In-Reply-To: <1474393160.23058.39.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 20 Sep 2016 10:39:20 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Tue, 2016-09-20 at 09:45 -0700, Alexei Starovoitov wrote:
> 
> > because 'div by zero' is an abnormal situation that shouldn't be exploited.
> > Meaning if xdp program is doing DoS prevention and it has a bug that
> > attacker can now exploit by sending a crafted packet that causes
> > 'div by zero' and kernel will warn then attack got successful.
> > Therefore it has to be silent drop.  
> 
> A silent drop means a genuine error in a BPF program might be never
> caught, since a tracepoint might never be enabled.

I do see your point. But we can document our way out of it.
 
> > tracpoint in such case is great, since the user can do debugging with it
> > and even monitoring 24/7 and if suddenly the control plan sees a lot
> > of such trace_xdp_abotred events, it can disable that tracepoint to avoid
> > spam and adjust the program or act on attack some other way.
> > Hardcoded warnings and counters are not generic enough for all
> > the use cases people want to throw at XDP.
> > The tracepoints idea is awesome, in a sense that it's optional.  
> 
> 
> Note that tracepoints are optional in a kernel.

Well, that is a good thing, as it can be compiled out (as that provides
an option for zero cost).


> Many existing supervision infrastructures collect device snmp
> counters, and run as unprivileged programs. 

A supervision infrastructures is a valid use-case. It again indicate
that such XDP stats need to structured, not just a random driver
specific ethtool counter, to make it easy for such collection daemons.


> tracepoints might not fit the need here, compared to a mere
> tx_ring->tx_drops++

I do see your point.  I really liked the tracepoint idea, but now I'm
uncertain again...


I do have a use-case where I want to use the NIC HW-RX-ingress-overflow
and TX-overflow drop indicators, but I don't want to tie it into this
discussion.  The abort and error indicators a not relevant for that
use-case.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next 7/8] net/mlx5e: XDP TX forwarding support
Date: Tue, 20 Sep 2016 23:04:30 +0200
Message-ID: <20160920230430.4756bfc6@redhat.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Tariq Toukan <ttoukan.linux@gmail.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eran Ben Elisha <eranbe@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Rana Shahout <ranas@mellanox.com>, brouer@redhat.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40290 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751124AbcITVEg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Sep 2016 17:04:36 -0400
In-Reply-To: <20160920164526.GB99429@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 20 Sep 2016 09:45:28 -0700
Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:

> To your other question:
> > Please explain why a eBPF program error (div by zero) must be a silent drop?  
> 
> because 'div by zero' is an abnormal situation that shouldn't be exploited.
> Meaning if xdp program is doing DoS prevention and it has a bug that
> attacker can now exploit by sending a crafted packet that causes
> 'div by zero' and kernel will warn then attack got successful.
> Therefore it has to be silent drop.

Understood and documented:
 https://github.com/netoptimizer/prototype-kernel/commit/a4e60e2d7a894

Our current solution is not very optimal, it only result in onetime
WARN_ONCE() see bpf_warn_invalid_xdp_action().  But is should not be
affected by the DoS attack scenario you described.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 7/8] net/mlx5e: XDP TX forwarding support
Date: Tue, 20 Sep 2016 08:40:37 -0700
Message-ID: <20160920154036.GA98644@ast-mbp.thefacebook.com>
References: <1474293539-2595-1-git-send-email-tariqt@mellanox.com>
 <1474293539-2595-8-git-send-email-tariqt@mellanox.com>
 <20160920102943.24732097@brouer.com>
 <20160920133300.144037fd@redhat.com>
 <96b40925-0e8e-0230-0701-96c11d6921a1@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Eran Ben Elisha <eranbe@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Rana Shahout <ranas@mellanox.com>
To: Tariq Toukan <ttoukan.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35627 "EHLO
        mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751643AbcITPkk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 11:40:40 -0400
Received: by mail-pa0-f47.google.com with SMTP id oz2so8237665pac.2
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 08:40:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <96b40925-0e8e-0230-0701-96c11d6921a1@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 20, 2016 at 03:53:10PM +0300, Tariq Toukan wrote:
> >>>+	case XDP_ABORTED:
> >>It is not clearly defined, but I believe XDP_ABORTED should also result
> >>in a warning (calling bpf_warn_invalid_xdp_action(act)).
> I'll add this.

Certainly NOT.
XDP_ABORTED is an exception case when program does divide by zero.
It should NOT do bpf_warn. It must drop the packet.
We discussed it several months ago.
See mlx4/en_rx.c for canonical implementation.

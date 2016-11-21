From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next v3 1/4] bpf, mlx5: fix mlx5e_create_rq taking
 reference on prog
Date: Mon, 21 Nov 2016 11:27:16 +0200
Message-ID: <CALzJLG9mZ1PvZNGrUYEWzbM1seQY7aBa=pi35L5sC5UdujFoeQ@mail.gmail.com>
References: <cover.1479514784.git.daniel@iogearbox.net> <cb3c229b56d24f6650472bc333d0a72de80327de.1479514784.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Zhiyi Sun <zhiyisun@gmail.com>,
        Rana Shahout <ranas@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Linux Netdev List <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:38507 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751437AbcKUJ1h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 04:27:37 -0500
Received: by mail-wm0-f54.google.com with SMTP id f82so133325268wmf.1
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2016 01:27:37 -0800 (PST)
In-Reply-To: <cb3c229b56d24f6650472bc333d0a72de80327de.1479514784.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 19, 2016 at 2:45 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> In mlx5e_create_rq(), when creating a new queue, we call bpf_prog_add() but
> without checking the return value. bpf_prog_add() can fail since 92117d8443bc
> ("bpf: fix refcnt overflow"), so we really must check it. Take the reference
> right when we assign it to the rq from priv->xdp_prog, and just drop the
> reference on error path. Destruction in mlx5e_destroy_rq() looks good, though.
>
> Fixes: 86994156c736 ("net/mlx5e: XDP fast RX drop bpf programs support")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Acked-by: Saeed Mahameed <saeedm@mellanox.com>

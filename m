From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next v3 2/4] bpf, mlx5: fix various refcount issues in mlx5e_xdp_set
Date: Mon, 21 Nov 2016 11:30:54 +0200
Message-ID: <CALzJLG9tSORy8nTC9Xv6ByEeCCUeK567wRw5HTYh0n7xWzYtBw@mail.gmail.com>
References: <cover.1479514784.git.daniel@iogearbox.net> <6030d6a2d31ce68280138ac7ed33c3fc6ba585b2.1479514784.git.daniel@iogearbox.net>
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
Received: from mail-qk0-f196.google.com ([209.85.220.196]:34432 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751264AbcKUJbQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 04:31:16 -0500
Received: by mail-qk0-f196.google.com with SMTP id y205so11945348qkb.1
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2016 01:31:15 -0800 (PST)
In-Reply-To: <6030d6a2d31ce68280138ac7ed33c3fc6ba585b2.1479514784.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 19, 2016 at 2:45 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> There are multiple issues in mlx5e_xdp_set():
>
> 1) The batched bpf_prog_add() is currently not checked for errors. When
>    doing so, it should be done at an earlier point in time to makes sure
>    that we cannot fail anymore at the time we want to set the program for
>    each channel. The batched refs short-cut can only be performed when we
>    don't need to perform a reset for changing the rq type and the device
>    was in opened state. In case the device was not in opened state, then
>    the next mlx5e_open_locked() will aquire the refs from the control prog
>    via mlx5e_create_rq(), same when we need to perform a reset.
>
> 2) When swapping the priv->xdp_prog, then no extra reference count must be
>    taken since we got that from call path via dev_change_xdp_fd() already.
>    Otherwise, we'd never be able to release the program. Also, bpf_prog_add()
>    without checking the return code could fail.
>
> Fixes: 86994156c736 ("net/mlx5e: XDP fast RX drop bpf programs support")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Acked-by: Saeed Mahameed <saeedm@mellanox.com>

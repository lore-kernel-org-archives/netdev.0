From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net 0/3] Couple of BPF refcount fixes for mlx5
Date: Mon, 14 Nov 2016 01:43:39 +0100
Message-ID: <cover.1479080215.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, bblanco@plumgrid.com,
        tariqt@mellanox.com, zhiyisun@gmail.com, ranas@mellanox.com,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33174 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751638AbcKNAoF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2016 19:44:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Various mlx5 bugs on eBPF program and refcount handling I found during review.
Since these kind of bugs happened multiple times here, I'll add a __must_check
to the bpf_prog_inc()/bpf_prog_add()/etc functions for net-next, so these things
will let the compiler (and thus kbuild bot) bark early enough. Note, turned out,
I had to take the hunk from c540594f864b ("bpf, mlx4: fix prog refcount in
mlx4_en_try_alloc_resources error path") to get bpf_prog_sub() function for net
as well, but the merge into net-next should add no conflicts.

Rana, please review.

Thanks a lot!

Daniel Borkmann (3):
  bpf, mlx5: fix mlx5e_create_rq taking reference on prog
  bpf, mlx5: fix various refcount/prog issues in mlx5e_xdp_set
  bpf, mlx5: drop priv->xdp_prog reference on netdev cleanup

 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 42 ++++++++++++++++++-----
 include/linux/bpf.h                               |  5 +++
 kernel/bpf/syscall.c                              | 12 +++++++
 3 files changed, 51 insertions(+), 8 deletions(-)

-- 
1.9.3

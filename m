From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next v3 0/4] Couple of BPF refcount fixes for mlx5
Date: Sat, 19 Nov 2016 01:44:59 +0100
Message-ID: <cover.1479514784.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, bblanco@plumgrid.com,
        zhiyisun@gmail.com, ranas@mellanox.com, saeedm@mellanox.com,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:58642 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752621AbcKSApZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 19:45:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Various mlx5 bugs on eBPF refcount handling found during review.
Last patch in series adds a __must_check to BPF helpers to make
sure we won't run into it again w/o compiler complaining first.

v2 -> v3:

 - Just reworked patch 2/4 so we don't need bpf_prog_sub().
 - Rebased, rest as is.

v1 -> v2:

 - After discussion with Alexei, we agreed upon rebasing the
   patches against net-next.
 - Since net-next, I've also added the __must_check to enforce
   future users to check for errors.
 - Fixed up commit message #2.
 - Simplify assignment from patch #1 based on Saeed's feedback
   on previous set.

Thanks a lot!

Daniel Borkmann (4):
  bpf, mlx5: fix mlx5e_create_rq taking reference on prog
  bpf, mlx5: fix various refcount issues in mlx5e_xdp_set
  bpf, mlx5: drop priv->xdp_prog reference on netdev cleanup
  bpf: add __must_check attributes to refcount manipulating helpers

 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 33 +++++++++++++++++------
 include/linux/bpf.h                               | 12 +++++----
 kernel/bpf/syscall.c                              |  1 +
 3 files changed, 33 insertions(+), 13 deletions(-)

-- 
1.9.3

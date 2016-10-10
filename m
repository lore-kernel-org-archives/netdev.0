From: Tom Herbert <tom@herbertland.com>
Subject: BUILD_BUG_ON error in mlx5/core/pagealloc.c
Date: Mon, 10 Oct 2016 16:41:21 -0700
Message-ID: <CALx6S348UQF_oSqVSJ5h=K74_Q6cesR8g1Wf3rn14XRnRRBwgQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
To: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f171.google.com ([209.85.216.171]:33012 "EHLO
        mail-qt0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752279AbcJJXlX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2016 19:41:23 -0400
Received: by mail-qt0-f171.google.com with SMTP id s49so2623868qta.0
        for <netdev@vger.kernel.org>; Mon, 10 Oct 2016 16:41:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am hitting this in mlx5

drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c: In function
=E2=80=98reclaim_pages_cmd.clone.0=E2=80=99:
drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c:346: error: call
to =E2=80=98__compiletime_assert_346=E2=80=99 declared with attribute error=
:
BUILD_BUG_ON failed: __mlx5_bit_off(manage_pages_out, pas[i]) % 64
drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c: In function =E2=80=98g=
ive_pages=E2=80=99:
drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c:291: error: call
to =E2=80=98__compiletime_assert_291=E2=80=99 declared with attribute error=
:
BUILD_BUG_ON failed: __mlx5_bit_off(manage_pages_in, pas[i]) % 64

Bisecting points to:

commit a533ed5e179cd15512d40282617909d3482a771c
Author: Saeed Mahameed <saeedm@mellanox.com>
Date:   Sun Jul 17 13:27:25 2016 +0300

    net/mlx5: Pages management commands via mlx5 ifc

Thanks,
Tom

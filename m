From: Tom Herbert <tom@herbertland.com>
Subject: Re: BUILD_BUG_ON error in mlx5/core/pagealloc.c
Date: Mon, 10 Oct 2016 17:10:15 -0700
Message-ID: <CALx6S37sZFv2kEVmhAZru5H=rLqgW2nR7iSFUaPaJqV=eXNMMg@mail.gmail.com>
References: <CALx6S348UQF_oSqVSJ5h=K74_Q6cesR8g1Wf3rn14XRnRRBwgQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
To: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:36040 "EHLO
        mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752418AbcJKAKR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2016 20:10:17 -0400
Received: by mail-qk0-f172.google.com with SMTP id o68so8157779qkf.3
        for <netdev@vger.kernel.org>; Mon, 10 Oct 2016 17:10:17 -0700 (PDT)
In-Reply-To: <CALx6S348UQF_oSqVSJ5h=K74_Q6cesR8g1Wf3rn14XRnRRBwgQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 10, 2016 at 4:41 PM, Tom Herbert <tom@herbertland.com> wrote:
> I am hitting this in mlx5
>
> drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c: In function
> =E2=80=98reclaim_pages_cmd.clone.0=E2=80=99:
> drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c:346: error: call
> to =E2=80=98__compiletime_assert_346=E2=80=99 declared with attribute err=
or:
> BUILD_BUG_ON failed: __mlx5_bit_off(manage_pages_out, pas[i]) % 64
> drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c: In function =E2=80=
=98give_pages=E2=80=99:
> drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c:291: error: call
> to =E2=80=98__compiletime_assert_291=E2=80=99 declared with attribute err=
or:
> BUILD_BUG_ON failed: __mlx5_bit_off(manage_pages_in, pas[i]) % 64
>

The expression in BUILD_BUG_ON expands to "((unsigned)(unsigned
long)(&(((struct mlx5_ifc_manage_pages_in_bits *)0)->pas[i]))) % 64".
The variable array index to pas makes this expression non-constant, I
imagine that is where the problem lies.

> Bisecting points to:
>
> commit a533ed5e179cd15512d40282617909d3482a771c
> Author: Saeed Mahameed <saeedm@mellanox.com>
> Date:   Sun Jul 17 13:27:25 2016 +0300
>
>     net/mlx5: Pages management commands via mlx5 ifc
>
> Thanks,
> Tom

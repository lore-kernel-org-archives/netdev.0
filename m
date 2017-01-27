From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next 0/4] mlx5: Create build configuration options
Date: Fri, 27 Jan 2017 19:58:32 +0200
Message-ID: <CALzJLG9QpKfA3eDgQkz5MF0FFgkL91BditedDRZkOxx-ayGQSQ@mail.gmail.com>
References: <20170126233241.2268449-1-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:34692 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753227AbdA0SHA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 13:07:00 -0500
Received: by mail-qt0-f193.google.com with SMTP id w20so14078290qtb.1
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 10:06:26 -0800 (PST)
In-Reply-To: <20170126233241.2268449-1-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 27, 2017 at 1:32 AM, Tom Herbert <tom@herbertland.com> wrote:
> This patchset creates configuration options for sriov, vxlan, eswitch,
> and tc features in the mlx5 driver. The purpose of this is to allow not
> building these features. These features are optional advanced features
> that are not required for a core Ethernet driver. A user can disable
> these features which resuces the amount of code in the driver. Disabling
> these features (and DCB) reduces the size of mlx5_core.o by about 16%.
> This is also can reduce the complexity of backport and rebases since
> user would no longer need to worry about dependencies with the rest of
> the kernel that features which might not be of any interest to a user
> may bring in.
>
> Tested: Build and ran the driver with all features enabled (the default)
> and with none enabled (including DCB). Did not see any issues. I did
> not explicity test operation of ayy of features in the list.
>

Basically I am not against this kind of change, infact i am with it,
although I would have done some restructuring in the driver before i
did such change ;), filling the code with ifdefs is not a neat thing.

I agree this will simplify backporting and provide some kind of
feature separation inside the driver.
But this will also increase the testing matrix we need to cover and
increase the likelihood of kbuild breaks by an order of magnitude.

One more thing, do we really need a device specific flag per feature
per vendor per device?  can't we just use the same kconfig flag for
all drivers and if there is a more generic system wide flag that
covers the same feature
can't we just use it, for instance instead of
CONFIG_<DRIVER_NAME>_SRIOV why not use already existing CONFIG_PCI_IOV
for all drivers ?

Saeed.

>
>
> Tom Herbert (4):
>   mlx5: Make building eswitch configurable
>   mlx5: Make building SR-IOV configurable
>   mlx5: Make building tc hardware offload configurable
>   mlx5: Make building vxlan hardware offload configurable
>
>  drivers/net/ethernet/mellanox/mlx5/core/Kconfig   |  35 ++++++
>  drivers/net/ethernet/mellanox/mlx5/core/Makefile  |  16 ++-
>  drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 129 ++++++++++++++++------
>  drivers/net/ethernet/mellanox/mlx5/core/en_tc.c   |  39 +++++--
>  drivers/net/ethernet/mellanox/mlx5/core/eq.c      |   4 +-
>  drivers/net/ethernet/mellanox/mlx5/core/lag.c     |   2 +
>  drivers/net/ethernet/mellanox/mlx5/core/main.c    |  32 ++++--
>  drivers/net/ethernet/mellanox/mlx5/core/sriov.c   |   6 +-
>  8 files changed, 205 insertions(+), 58 deletions(-)
>
> --
> 2.9.3
>

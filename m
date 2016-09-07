From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next V2 0/6] Mellanox 100G mlx5 DCBX CEE and firmware support
Date: Wed, 7 Sep 2016 23:16:13 +0300
Message-ID: <CALzJLG89HjLC9hOR3g2g-SLYyV1K=wM=rHcwv7C=dex1VCOUFQ@mail.gmail.com>
References: <1473177852-10711-1-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Huy Nguyen <huyn@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f53.google.com ([209.85.215.53]:34060 "EHLO
        mail-lf0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750877AbcIGUQg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 16:16:36 -0400
Received: by mail-lf0-f53.google.com with SMTP id u14so6626596lfd.1
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2016 13:16:35 -0700 (PDT)
In-Reply-To: <1473177852-10711-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 6, 2016 at 7:04 PM, Saeed Mahameed <saeedm@mellanox.com> wrote:
> Hi Dave,
>

Hi Dave, Sorry to bother, but i would like to drop this series for now
Huy is working to define and come up with a better mechanism to
enable/disable the new DCBX hybrid mode he is adding.

Thanks for understanding,
Saeed.

> This series from Huy provides mlx5 DCBX updates to support DCBX CEE
> API and DCBX firmware/host modes support.
>
> 1st patch ensures the dcbnl_rtnl_ops is published only when the qos capability bits is on.
>
> 2nd patch adds the support for CEE interfaces into mlx5 dcbnl_rtnl_ops.
>
> 3rd patch refactors ETS query to read ETS configuration directly from firmware rather
> than having a software shadow to it. The existing IEEE interfaces stays the same.
>
> 4th patch adds the support for MLX5_REG_DCBX_PARAM and MLX5_REG_DCBX_APP firmware
> commands to manipulate mlx5 DCBX mode.
>
> 5th patch adds the driver support for the new DCBX firmware.
> This ensures the backward compatibility versus the old and new firmware.
> With the new DCBX firmware, qos settings can be controlled by either firmware
> or software depending on the DCBX mode.
>
> 6th patch adds support for module events log.
>
> Changes since V1:
> 1. Add qos capability check
> 2. In port module events eqe structure, change rsvd_n to reserved_at_n to be consistent with mlx5_ifc.h
> 3. Improve commit messages
> 4. Drop DCBX private flags patch
> 5. Add patch to check for qos capability bit check before exposing dcb interfaces
> 6. Replace memset with static array initialization
>
> Thanks,
> Saeed.
>
> Huy Nguyen (6):
>   net/mlx5e: Add qos capability check
>   net/mlx5e: Support DCBX CEE API
>   net/mlx5e: Read ETS settings directly from firmware
>   net/mlx5: Add DCBX firmware commands support
>   net/mlx5e: ConnectX-4 firmware support for DCBX
>   net/mlx5: Add handling for port module event
>
>  drivers/net/ethernet/mellanox/mlx5/core/en.h       |  36 +-
>  drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c | 483 ++++++++++++++++++++-
>  drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  27 +-
>  drivers/net/ethernet/mellanox/mlx5/core/eq.c       |  12 +
>  .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |   1 +
>  drivers/net/ethernet/mellanox/mlx5/core/port.c     | 148 +++++++
>  include/linux/mlx5/device.h                        |  11 +
>  include/linux/mlx5/driver.h                        |   7 +
>  include/linux/mlx5/mlx5_ifc.h                      |   3 +-
>  include/linux/mlx5/port.h                          |   6 +
>  10 files changed, 698 insertions(+), 36 deletions(-)
>
> --
> 2.7.4
>

From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: mlx5 "syndrome" errors in kernel log
Date: Tue, 22 Nov 2016 14:04:52 +0200
Message-ID: <CALzJLG9fcvy1vy7US4fTE4DOHaPDNRnnWmH18TYctmCt-twk6w@mail.gmail.com>
References: <20161122105944.0c64e77b@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jesper Dangaard Brouer <jbrouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:33326 "EHLO
        mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932422AbcKVMFO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 07:05:14 -0500
Received: by mail-qk0-f181.google.com with SMTP id x190so20121524qkb.0
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2016 04:05:13 -0800 (PST)
In-Reply-To: <20161122105944.0c64e77b@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 22, 2016 at 11:59 AM, Jesper Dangaard Brouer
<jbrouer@redhat.com> wrote:
>
> Hi Saeed,
>
> I'm seeing below dmesg errors, after pulling net-next at commit
> e796f49d826aad, before I was not seeing these errors, where my tree was
> based on top of commit 319b0534b95.
>
> mlx5_core 0000:02:00.1: mlx5_cmd_check:698:(pid 8788): ACCESS_REG(0x805) op_mod(0x1) failed, status bad parameter(0x3), syndrome (0x6c4d48)
> mlx5_core 0000:02:00.1: mlx5_cmd_check:698:(pid 8788): ACCESS_REG(0x805) op_mod(0x1) failed, status bad parameter(0x3), syndrome (0x6c4d48)
> mlx5_core 0000:02:00.0: mlx5_cmd_check:698:(pid 8788): ACCESS_REG(0x805) op_mod(0x1) failed, status bad parameter(0x3), syndrome (0x6c4d48)
> mlx5_core 0000:02:00.0: mlx5_cmd_check:698:(pid 8788): ACCESS_REG(0x805) op_mod(0x1) failed, status bad parameter(0x3), syndrome (0x6c4d48)
> mlx5_core 0000:02:00.1: mlx5_cmd_check:698:(pid 8788): ACCESS_REG(0x805) op_mod(0x1) failed, status bad parameter(0x3), syndrome (0x6c4d48)
> mlx5_core 0000:02:00.1: mlx5_cmd_check:698:(pid 8788): ACCESS_REG(0x805) op_mod(0x1) failed, status bad parameter(0x3), syndrome (0x6c4d48)
> mlx5_core 0000:02:00.0: mlx5_cmd_check:698:(pid 8788): ACCESS_REG(0x805) op_mod(0x1) failed, status bad parameter(0x3), syndrome (0x6c4d48)
> mlx5_core 0000:02:00.0: mlx5_cmd_check:698:(pid 8788): ACCESS_REG(0x805) op_mod(0x1) failed, status bad parameter(0x3), syndrome (0x6c4d48)
>
>
> Listing my firmware version:
>
>  $ ethtool -i mlx5p2
>  driver: mlx5_core
>  version: 3.0-1 (January 2015)
>  firmware-version: 12.12.1240

Hi Jesper,

Seems like this FW version doesn't support a new FW command introduced
by "net/mlx5e: Expose PCIe statistics to ethtool"

I suggest to upgrade FW, but if you don't know how to do it or in a
hurry, please go ahead and revert "
   net/mlx5e: Expose PCIe statistics to ethtool"

I will need to introduce a new capability bit as a permanent solution
and a fix for the above patch.

Thanks for the report,
We will handle this.

From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 3/3] net/mlx5e: don't build RFS without ethernet
Date: Wed, 04 May 2016 16:23:19 +0200
Message-ID: <6481938.m1ihicFdKr@wuerfel>
References: <1462364774-3792510-1-git-send-email-arnd@arndb.de> <1462365155-3861405-1-git-send-email-arnd@arndb.de> <CALzJLG9j6ZodwDToX8iuvNVKLoMoaM8V9w8cFR6jM-ktU0ynHg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Matan Barak <matanb@mellanox.com>,
	Leon Romanovsky <leonro@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Matthew Finlay <matt@mellanox.com>,
	Richard Cochran <richardcochran@gmail.com>,
	Amir Vadai <amirv@mellanox.com>,
	Haggai Abramonvsky <hagaya@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([217.72.192.73]:58755 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750846AbcEDOXb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 10:23:31 -0400
In-Reply-To: <CALzJLG9j6ZodwDToX8iuvNVKLoMoaM8V9w8cFR6jM-ktU0ynHg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 04 May 2016 16:09:16 Saeed Mahameed wrote:
> On Wed, May 4, 2016 at 3:32 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> > The RFS acceleration support in mlx5 is enabled whenever CONFIG_RFS_ACCEL
> > is in use. However, this fails if a user turns off CONFIG_MLX5_CORE_EN,
> > because the rfs code now calls into the ethernet portion of the
> > driver:
> >
> > ERROR: "mlx5e_destroy_flow_table" [drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.ko] undefined!
> >
> 
> Hi Arnd,
> 
> We already posted a fix for this, please see "[PATCH net-next V1
> 01/12] net/mlx5e: Fix aRFS compilation dependency", and give us your
> feedback.

That version looks fine as well. I think it's better to be a little
more explicit as I was, but either way seems fine.

You can also achieve the same thing in yet another way using Makefile
syntax instead of cpp or Kconfig:

ifdef CONFIG_MLX5_CORE_EN
mlx5_core-y += wq.o eswitch.o \
               en_main.o en_fs.o en_ethtool.o en_tx.o en_rx.o \
               en_txrx.o en_clock.o vxlan.o en_tc.o
               en_txrx.o en_clock.o vxlan.o en_tc.o en_arfs.o

mlx5_core-$(CONFIG_RFS_ACCEL) += en_arfs.o
endif

If you prefer Maor's version, feel free to add

Acked-by: Arnd Bergmann <arnd@arndb.de>

	Arnd

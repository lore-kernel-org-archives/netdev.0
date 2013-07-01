From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH for-next 0/8] Add Mellanox mlx5 driver for Connect-IB
 devices
Date: Mon, 01 Jul 2013 13:19:02 -0700
Message-ID: <1372709942.2481.13.camel@joe-AO722>
References: <1371384149-24558-1-git-send-email-eli@dev.mellanox.co.il>
	 <CAJZOPZ+NQa3CWnw3rZQh2UuwdrNhiwtVSyuk9D9YtwfQQ9e1XA@mail.gmail.com>
	 <CAJZOPZKLb9k1xXkTnrtzYKpwrSJDQgBpONUVCp3et36JeaEi-Q@mail.gmail.com>
	 <CAL1RGDX5mHj5oVqFhQ4Ssr25jpL4rV2Tv=zXvLOZfwupJ0gqJw@mail.gmail.com>
	 <1372701839.2481.3.camel@joe-AO722>
	 <CAL1RGDW_Z06ZqpOhz3tAkKn=rpLEZE6hWZkLNd9OQgCbrX6YAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <or.gerlitz@gmail.com>,
	Eli Cohen <eli@dev.mellanox.co.il>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	Eli Cohen <eli@mellanox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Roland Dreier <roland@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:60767 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755201Ab3GAUTD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Jul 2013 16:19:03 -0400
In-Reply-To: <CAL1RGDW_Z06ZqpOhz3tAkKn=rpLEZE6hWZkLNd9OQgCbrX6YAg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-07-01 at 11:11 -0700, Roland Dreier wrote:
> On Mon, Jul 1, 2013 at 11:03 AM, Joe Perches <joe@perches.com> wrote:
> > There's some value in block enabling/disabling messages
> > that dynamic_debug doesn't currently offer.
> 
> As far as I can see, the mlx5 stuff ends up being per-file.  Which
> dynamic debug already does offer.

I didn't look too closely.

I do think that all __func__, __LINE__ and pid bits are
useless as it's all duplicated dynamic_debug functionality.

+#define mlx5_core_dbg(dev, format, arg...)                                    \
+do {                                                                          \
+       if (debug_mask & mlx5_core_debug_mask)                                 \
+               pr_debug("%s:%s:%d:(pid %d): " format, (dev)->priv.name,       \
+                        __func__, __LINE__, current->pid, ##arg);             \
+} while (0)
+
+#define mlx5_core_dbg_mask(dev, mask, format, arg...)                         \
+do {                                                                          \
+       if ((mask) & mlx5_core_debug_mask)                                     \
+               pr_debug("%s:%s:%d:(pid %d): " format, (dev)->priv.name,       \
+                        __func__, __LINE__, current->pid, ##arg);             \
+} while (0)

btw:

mlx5_core_dbg should just be

#define mlx5_core_dbg(dev, fmt, ...)				\
	mlx5_core_dbg_mask(dev, debug_mask, fmt, ##__VA_ARGS__)

[]

I think these are the groupings.

+enum {
+       MLX5_MOD_MAIN,
+       MLX5_MOD_CMDIF,
+       MLX5_MOD_EQ,
+       MLX5_MOD_QP,
+       MLX5_MOD_PGALLOC,
+       MLX5_MOD_FW,
+       MLX5_MOD_UAR,
+       MLX5_MOD_ALLOC,
+       MLX5_MOD_DEBUG,
+       MLX5_MOD_HEALTH,
+       MLX5_MOD_MAD,
+       MLX5_MOD_MCG,
+       MLX5_MOD_MR,
+       MLX5_MOD_PD,
+       MLX5_MOD_PORT,
+       MLX5_MOD_SRQ,
+       MLX5_MOD_CQ,
+       MLX5_MOD_CMD_DATA, /* print command payload only */
+       MLX5_CMD_DATA_TIME,
+};
+

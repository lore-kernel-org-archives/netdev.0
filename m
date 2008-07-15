From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH RFC 01/10] mlx4_en: Include file
Date: Tue, 15 Jul 2008 12:14:21 -0700
Message-ID: <ada8ww3ez8y.fsf@cisco.com>
References: <487B6569.5000806@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	Liran Liss <liranl@mellanox.co.il>, tziporet@mellanox.co.il
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:54829 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754706AbYGOTTv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 15:19:51 -0400
In-Reply-To: <487B6569.5000806@mellanox.co.il> (Yevgeny Petrilin's message of
	"Mon, 14 Jul 2008 17:40:41 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > +struct mlx4_en_ctrl_seg {
 > +	__be32 op_own;
 > +#define MLX4_EN_BIT_DESC_OWN	0x80000000
 > +#define MLX4_EN_OPCODE_SEND	0xa
 > +#define MLX4_EN_OPCODE_LSO	0xe
 > +	__be32 size_vlan;
 > +#define MLX4_EN_BIT_INS_VLAN	0x4000
 > +	__be32 flags;
 > +#define MLX4_EN_BIT_NO_ICRC	0x2
 > +#define MLX4_EN_BIT_TX_COMP	0xc
 > +#define MLX4_EN_BIT_TX_IP_CS	0x10
 > +#define MLX4_EN_BIT_TX_TCP_CS	0x20
 > +	__be32 reserved;
 > +};
 > +#define CTRL_SIZE	sizeof(struct mlx4_en_ctrl_seg)
 > +
 > +struct mlx4_en_data_seg {
 > +	__be32 count;
 > +#define MLX4_EN_INLINE		0x80000000
 > +	__be32 mem_type;
 > +#define MLX4_EN_MEMTYPE_PAD	0x100
 > +	__be64 addr;
 > +};
 > +#define DS_SIZE		sizeof(struct mlx4_en_data_seg)
 > +
 > +struct mlx4_en_lso_seg {
 > +	__be16 mss;
 > +	__be16 header_size;
 > +#define LSO_PREFIX_SIZE		4
 > +	u8 header_data[0]; /* copy of L2/IP/TCP headers */
 > +#define MLX4_EN_MAX_LSO_HEADER	(MAX_DESC_SIZE - CTRL_SIZE - DS_SIZE)
 > +};

I think it would be better to reuse the mlx4_wqe_ctrl_seg,
mlx4_wqe_data_seg and mlx4_wqe_lso_seg already defined in
<linux/mlx4/qp.h>.  That was the whole point in putting those structures
in a common location.

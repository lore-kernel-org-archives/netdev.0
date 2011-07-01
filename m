From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next af-packet 1/2] Enhance af-packet to provide
 (near zero)lossless packet capture functionality.
Date: Fri, 01 Jul 2011 15:36:33 -0700 (PDT)
Message-ID: <20110701.153633.267893668051099806.davem@davemloft.net>
References: <1308708650-25509-1-git-send-email-loke.chetan@gmail.com>
	<1308708650-25509-2-git-send-email-loke.chetan@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, joe@perches.com,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	linux-kernel@vger.kernel.org
To: loke.chetan@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1308708650-25509-2-git-send-email-loke.chetan@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chetan Loke <loke.chetan@gmail.com>
Date: Tue, 21 Jun 2011 22:10:49 -0400

> +struct bd_v1 {
 -
> +	__u32	block_status;
> +	__u32	num_pkts;
> +	__u32	offset_to_first_pkt;
 -
> +	__u32	blk_len;
 -
> +	__u64	seq_num;
 ...
> +	union {
> +		struct {
> +			__u32	words[4];
> +			__u64	dword;
> +		} __attribute__ ((__packed__));
> +		struct bd_v1 bd1;
 ...
> +#define BLOCK_STATUS(x)	((x)->words[0])
> +#define BLOCK_NUM_PKTS(x)	((x)->words[1])
> +#define BLOCK_O2FP(x)		((x)->words[2])
> +#define BLOCK_LEN(x)		((x)->words[3])
> +#define BLOCK_SNUM(x)		((x)->dword)

This BLOCK_SNUM definition is buggy.  It modifies the
first 64-bit word in the block descriptor.

But the sequence number lives 16 bytes into the descriptor.

This value is only written to once and never used by anything.
I would just remove it entirely.

Next, having this overlay thing is entirely pointless.  Just refer to
the block descriptor members directly!  You certainly wouldn't have
had this sequence number bug if you had done that.

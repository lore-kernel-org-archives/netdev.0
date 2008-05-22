From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 3/3] bnx2i: Add bnx2i iSCSI driver.
Date: Thu, 22 May 2008 17:15:59 -0400
Message-ID: <20080522211559.GA29851@infradead.org>
References: <1211418386-18203-1-git-send-email-mchan@broadcom.com> <1211418386-18203-4-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, michaelc@cs.wisc.edu, anilgv@broadcom.com,
	netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	open-iscsi@googlegroups.com
To: Michael Chan <mchan@broadcom.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1211418386-18203-4-git-send-email-mchan@broadcom.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +struct bnx2i_async_msg {
> +#if defined(__BIG_ENDIAN)
> +	u8 op_code;
> +	u8 reserved1;
> +	u16 reserved0;
> +#elif defined(__LITTLE_ENDIAN)
> +	u16 reserved0;
> +	u8 reserved1;
> +	u8 op_code;
> +#endif
> +	u32 reserved2;
> +	u32 exp_cmd_sn;
> +	u32 max_cmd_sn;
> +	u32 reserved3[2];

Please don't do the ifdef big endian mess.  Just read the whole
32bit word and do mask and shift operations to extract the actual value.


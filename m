From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 4/5] drivers: net: APM X-Gene SoC Ethernet driver error
 handling
Date: Sun, 22 Dec 2013 10:34:56 +0100
Message-ID: <201312221034.56313.arnd@arndb.de>
References: <1387597376-29303-1-git-send-email-isubramanian@apm.com>
 <1387597376-29303-5-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, gregkh@linuxfoundation.org, patches@apm.com,
 linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
 Iyappan Subramanian <isubramanian@apm.com>, Keyur Chudgar <kchudgar@apm.com>,
 davem@davemloft.net, jcm@redhat.com, Ravi Patel <rapatel@apm.com>
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1387597376-29303-5-git-send-email-isubramanian@apm.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Saturday 21 December 2013, Iyappan Subramanian wrote:

> +#define CFG_RSIF_FPBUFF_TIMEOUT_EN_WR(src) \
> +	(((u32)(src)<<31) & 0x80000000)
> +#define RSIF_LCL_RXBUF_FIFO_OVERFL_INTR_RXPRT10_MASK                 0x20000000
> +#define RSIF_LCL_RXBUF_FIFO_OVERFL_INTR_RXPRT10_RD(src) \
> +	(((src) & 0x20000000)>>29)
> +#define RSIF_LCL_RXBUF_FIFO_UNDERFL_INTR_RXPRT10_MASK                0x10000000
> +#define RSIF_LCL_RXBUF_FIFO_UNDERFL_INTR_RXPRT10_RD(src) \
> +	(((src) & 0x10000000)>>28)
> +#define RSIF_CHKSUM_BUFF_FIFO_OVERFL_INTR_RXPRT10_MASK               0x08000000
> +#define RSIF_CHKSUM_BUFF_FIFO_OVERFL_INTR_RXPRT10_RD(src) \
> +	(((src) & 0x08000000)>>27)
> +#define RSIF_CHKSUM_BUFF_FIFO_UNDERFL_INTR_RXPRT10_MASK              0x04000000
> +#define RSIF_CHKSUM_BUFF_FIFO_UNDERFL_INTR_RXPRT10_RD(src) \
> +	(((src) & 0x04000000)>>26)
> +#define RSIF_TIMESTAMP_BUFF_FIFO_OVERFL_INTR_RXPRT10_MASK            0x02000000
> +#define RSIF_TIMESTAMP_BUFF_FIFO_OVERFL_INTR_RXPRT10_RD(src) \
> +	(((src) & 0x02000000)>>25)
> +#define RSIF_TIMESTAMP_BUFF_FIFO_UNDERFL_INTR_RXPRT10_MASK           0x01000000
> +#define RSIF_TIMESTAMP_BUFF_FIFO_UNDERFL_INTR_RXPRT10_RD(src) \
> +	(((src) & 0x01000000)>>24)
> +#define RSIF_ERR_BUFF_FIFO_OVERFL_INTR_RXPRT10_MASK                  0x00800000
> +#define RSIF_ERR_BUFF_FIFO_OVERFL_INTR_RXPRT10_RD(src) \
> +	(((src) & 0x00800000)>>23)
> +#define RSIF_ERR_BUFF_FIFO_UNDERFL_INTR_RXPRT10_MASK                 0x00400000
> +#define RSIF_ERR_BUFF_FIFO_UNDERFL_INTR_RXPRT10_RD(src) \
> +	(((src) & 0x00400000)>>22)
> +#define RSIF_CLEBUFF_FIFO_OVERFL_INTR_RXPRT10_MASK                   0x00200000
> +#define RSIF_CLEBUFF_FIFO_OVERFL_INTR_RXPRT10_RD(src) \
> +	(((src) & 0x00200000)>>21)

I think you can just remove all the above obfuscation, since all you ever
do is this:

> +	rc = xgene_enet_rd(priv, BLOCK_MCX_MAC_CSR, MAC_INT_REG0_ADDR, &data);
> +	if (data) {
> +		pr_err("Received MAC Error Interrupt\n");
> +
> +		if (ICM_DATA_FIFO_UNDERFL_INTR_PRT10_RD(data)) {
> +			pr_err("RxPort1 ICM Data fifo underflow intr\n");
> +			int_mask |= ICM_DATA_FIFO_UNDERFL_INTR_PRT10_MASK;
> +		}
> +		if (ICM_DATA_FIFO_OVERFL_INTR_PRT10_RD(data)) {
> +			pr_err("RxPort1 ICM Data fifo overflow intr\n");
> +			int_mask |= ICM_DATA_FIFO_OVERFL_INTR_PRT10_MASK;
> +		}
> +		if (ICM_CTRL_FIFO_UNDERFL_INTR_PRT10_RD(data)) {
> +			pr_err("RxPort1 ICM Ctrl fifo underflow intr\n");
> +			int_mask |= ICM_CTRL_FIFO_UNDERFL_INTR_PRT10_MASK;
> +		}
> +		if (ICM_CTRL_FIFO_OVERFL_INTR_PRT10_RD(data)) {
> +			pr_err("RxPort1 ICM Ctrl fifo overflow intr\n");
> +			int_mask |= ICM_CTRL_FIFO_OVERFL_INTR_PRT10_MASK;
> +		}
> +		if (ECM_DATA_FIFO_UNDERN_INTR_PRT10_RD(data)) {
> +			pr_err("RxPort1 ECM Data fifo underrun intr\n");
> +			int_mask |= ECM_DATA_FIFO_UNDERN_INTR_PRT10_MASK;
> +		}

So there is one string you print per bit. Just use an array of strings
and for_each_set_bit() loop.

	Arnd

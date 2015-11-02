From: Joe Perches <joe@perches.com>
Subject: Re: [net-next v4 3/8] dpaa_eth: add support for S/G frames
Date: Mon, 02 Nov 2015 12:07:09 -0800
Message-ID: <1446494829.24485.63.camel@perches.com>
References: <1446485500-9782-1-git-send-email-madalin.bucur@freescale.com>
	 <1446485500-9782-4-git-send-email-madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	scottwood@freescale.com, igal.liberman@freescale.com,
	roy.pledge@freescale.com, ppc@mindchasers.com, pebolle@tiscali.nl,
	joakim.tjernlund@transmode.se, gregkh@linuxfoundation.org
To: madalin.bucur@freescale.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446485500-9782-4-git-send-email-madalin.bucur@freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-11-02 at 19:31 +0200, Madalin Bucur wrote:
> Add support for Scater/Gather (S/G) frames. The FMan can place
> the frame content into multiple buffers and provide a S/G Table
> (SGT) into one first buffer with references to the others.

trivia: scatter

> diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.c b/drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.c
[]
> @@ -1177,10 +1177,42 @@ void dpaa_eth_init_ports(struct mac_device *mac_dev,
>  			      port_fqs->rx_defq, &buf_layout[RX]);
>  }
>  
> +void dpa_release_sgt(struct qm_sg_entry *sgt)
> +{
> +	struct dpa_bp *dpa_bp;
> +	struct bm_buffer bmb[DPA_BUFF_RELEASE_MAX];

Where is "struct bm_buffer" defined?

From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] netdev: octeon_mgmt: ISO C90 forbids mixed declarations
 and code
Date: Sat, 13 Sep 2014 12:11:12 -0700
Message-ID: <1410635472.917.1.camel@joe-AO725>
References: <1410635108-3589-1-git-send-email-xypron.glpk@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Daney <david.daney@cavium.com>,
	"David S. Miller" <davem@davemloft.net>,
	Luka Perkov <luka@openwrt.org>,
	Willem de Bruijn <willemb@google.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Heinrich Schuchardt <xypron.glpk@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1410635108-3589-1-git-send-email-xypron.glpk@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2014-09-13 at 21:05 +0200, Heinrich Schuchardt wrote:
> Compiling with OCTEON_MGMT_ETHERNET gives a warning
> drivers/net/ethernet/octeon/octeon_mgmt.c:295:4:
> warning: ISO C90 forbids mixed declarations and code
> [-Wdeclaration-after-statement]

Maybe better to move the memset after the declaration.

> diff --git a/drivers/net/ethernet/octeon/octeon_mgmt.c b/drivers/net/ethernet/octeon/octeon_mgmt.c
[]
> @@ -254,6 +254,7 @@ static void octeon_mgmt_clean_tx_buffers(struct octeon_mgmt *p)
>  	struct sk_buff *skb;
>  	int cleaned = 0;
>  	unsigned long flags;
> +	u64 ns;
>  
>  	mix_orcnt.u64 = cvmx_read_csr(p->mix + MIX_ORCNT);
>  	while (mix_orcnt.s.orcnt) {
> @@ -292,7 +293,7 @@ static void octeon_mgmt_clean_tx_buffers(struct octeon_mgmt *p)
>  			struct skb_shared_hwtstamps ts;
>  			memset(&ts, 0, sizeof(ts));
>  			/* Read the timestamp */
> -			u64 ns = cvmx_read_csr(CVMX_MIXX_TSTAMP(p->port));
> +			ns = cvmx_read_csr(CVMX_MIXX_TSTAMP(p->port));
>  			/* Remove the timestamp from the FIFO */
>  			cvmx_write_csr(CVMX_MIXX_TSCTL(p->port), 0);
>  			/* Tell the kernel about the timestamp */

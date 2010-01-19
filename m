From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH 01/11] fs_enet: Add support for MPC512x to fs_enet driver
Date: Tue, 19 Jan 2010 14:48:35 -0600
Message-ID: <4B561AA3.7040506@freescale.com>
References: <1263932653-3634-1-git-send-email-agust@denx.de>
	<1263932653-3634-2-git-send-email-agust@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: Piotr Ziecik <kosmo@semihalf.com>, dzu@denx.de, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, John Rigby <jrigby@freescale.com>, wd@denx.de
To: Anatolij Gustschin <agust@denx.de>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1263932653-3634-2-git-send-email-agust@denx.de>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

Anatolij Gustschin wrote:
> +struct reg_tbl {
> +	void __iomem *fec_ievent;
> +	void __iomem *fec_imask;
> +	void __iomem *fec_r_des_active;
> +	void __iomem *fec_x_des_active;
> +	void __iomem *fec_r_des_start;
> +	void __iomem *fec_x_des_start;
> +	void __iomem *fec_r_cntrl;
> +	void __iomem *fec_ecntrl;
> +	void __iomem *fec_ivec;
> +	void __iomem *fec_mii_speed;
> +	void __iomem *fec_addr_low;
> +	void __iomem *fec_addr_high;
> +	void __iomem *fec_hash_table_high;
> +	void __iomem *fec_hash_table_low;
> +	void __iomem *fec_r_buff_size;
> +	void __iomem *fec_r_bound;
> +	void __iomem *fec_r_fstart;
> +	void __iomem *fec_x_fstart;
> +	void __iomem *fec_fun_code;
> +	void __iomem *fec_r_hash;
> +	void __iomem *fec_x_cntrl;
> +	void __iomem *fec_dma_control;
> +};

Why void and not the specific type?

>  static void set_promiscuous_mode(struct net_device *dev)
>  {
>  	struct fs_enet_private *fep = netdev_priv(dev);
> -	fec_t __iomem *fecp = fep->fec.fecp;
> +	struct reg_tbl *fecp = fep->fec.rtbl;

Hmm, having something called "fecp" that is a different type than other 
"fecp"s could be confusing.

> @@ -134,6 +143,20 @@ static int __devinit fs_enet_mdio_probe(struct of_device *ofdev,
>  	if (!fec->fecp)
>  		goto out_fec;
>  
> +	if (of_device_is_compatible(ofdev->node, "fsl,mpc5121-fec-mdio")) {

You can put a data pointer in the of_platform match struct, instead of 
re-checking the compatible.

-Scott

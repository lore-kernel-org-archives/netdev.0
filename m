From: Baruch Siach <baruch@tkos.co.il>
Subject: Re: [PATCH 1/2] net: fec: refactor dt probing
Date: Mon, 21 Jan 2013 19:48:26 +0200
Message-ID: <20130121174824.GA27956@sapphire.tkos.co.il>
References: <1358757475-21035-1-git-send-email-s.hauer@pengutronix.de>
 <1358757475-21035-2-git-send-email-s.hauer@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shawn.guo@linaro.org, davem@davemloft.net,
 linux-arm-kernel@lists.infradead.org
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <1358757475-21035-2-git-send-email-s.hauer@pengutronix.de>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hi Sascha,

On Mon, Jan 21, 2013 at 09:37:54AM +0100, Sascha Hauer wrote:
> For devicetree parsing only the fec_get_phy_mode_dt() is
> available. Rename it to fec_probe_dt() to be able to add more devicetree
> parsing to it.
> 
> Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
> ---

[...]

> -static int fec_get_phy_mode_dt(struct platform_device *pdev)
> +static int fec_probe_dt(struct fec_enet_private *fep)
>  {
> -	struct device_node *np = pdev->dev.of_node;
> +	struct device_node *np = fep->pdev->dev.of_node;
>  
> -	if (np)
> -		return of_get_phy_mode(np);
> +	if (!np)
> +		return -ENODEV;
> +
> +	fep->phy_interface = of_get_phy_mode(np);
>  
>  	return -ENODEV;

Maybe return fep->phy_interface?

baruch

-- 
     http://baruch.siach.name/blog/                  ~. .~   Tk Open Systems
=}------------------------------------------------ooO--U--Ooo------------{=
   - baruch@tkos.co.il - tel: +972.2.679.5364, http://www.tkos.co.il -

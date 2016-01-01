From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RESEND PATCH v1 3/4] net: ethernet: arc: Add support emac for
 RK3036
Date: Fri, 01 Jan 2016 13:55:42 +0100
Message-ID: <3169681.aSJgN2TRic@wuerfel>
References: <1451287341-16453-1-git-send-email-zhengxing@rock-chips.com>
 <1451287341-16453-4-git-send-email-zhengxing@rock-chips.com>
 <FFCE9129-357E-4643-A350-9927A5AD5720@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, heiko@sntech.de,
 Xing Zheng <zhengxing@rock-chips.com>,
 Paul Gortmaker <paul.gortmaker@windriver.com>, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-rockchip@lists.infradead.org,
 Geert Uytterhoeven <geert@linux-m68k.org>, keescook@google.com,
 davem@davemloft.net, leozwang@google.com
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <FFCE9129-357E-4643-A350-9927A5AD5720@gmail.com>
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

On Tuesday 29 December 2015 14:59:59 Florian Fainelli wrote:
> On December 27, 2015 11:22:20 PM PST, Xing Zheng <zhengxing@rock-chips.com> wrote:
> >The RK3036's GRFs offset are different with RK3066/RK3188, and need to
> >set
> >mac TX/RX clock before probe emac.
> >
> >Signed-off-by: Xing Zheng <zhengxing@rock-chips.com>
> >---
> <snip>
> > };
> > 
> > static const struct of_device_id emac_rockchip_dt_ids[] = {
> >-      { .compatible = "rockchip,rk3066-emac", .data =
> >&emac_rockchip_dt_data[0] },
> >-      { .compatible = "rockchip,rk3188-emac", .data =
> >&emac_rockchip_dt_data[1] },
> >+      { .compatible = "rockchip,rk3036-emac", .data =
> >&emac_rockchip_dt_data[0] },
> >+      { .compatible = "rockchip,rk3066-emac", .data =
> >&emac_rockchip_dt_data[1] },
> >+      { .compatible = "rockchip,rk3188-emac", .data =
> >&emac_rockchip_dt_data[2] },
> >       { /* Sentinel */ }
> 
> Food for thought, you might want to use an enum here to index emac_rockchip_dt_data which would be less error prone if you add/remove entries in this structure.
> 

I would use named structures instead:

static const struct emac_rockchip_soc_data emac_rk3066_emac_data = {
	.grf_offset = 0x154,
};

static const struct of_device_id emac_rockchip_dt_ids[] = {
	{ .compatible = "rockchip,rk3066-emac", .data = &emac_rk3066_emac_data,
	...
};

	Armd

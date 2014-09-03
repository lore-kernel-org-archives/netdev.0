From: Heiko =?ISO-8859-1?Q?St=FCbner?= <heiko@sntech.de>
Subject: Re: [PATCH v4 1/4] ethernet: arc: Add support for Rockchip SoC layer device tree bindings
Date: Wed, 03 Sep 2014 14:20:50 +0200
Message-ID: <12261801.xhz3LcucGs@diego>
References: <1409740036-8117-1-git-send-email-romain.perier@gmail.com> <3774938.44qiV4hEoE@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-arm-kernel@lists.infradead.org,
	Romain Perier <romain.perier@gmail.com>,
	linux-rockchip@lists.infradead.org, devicetree@vger.kernel.org,
	netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gloria.sntech.de ([95.129.55.99]:60147 "EHLO gloria.sntech.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756092AbaICMSp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2014 08:18:45 -0400
In-Reply-To: <3774938.44qiV4hEoE@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Mittwoch, 3. September 2014, 13:14:54 schrieb Arnd Bergmann:
> On Wednesday 03 September 2014 10:27:13 Romain Perier wrote:
> > +static const struct emac_rockchip_soc_data emac_rockchip_dt_data[] = {
> > +       { .grf_offset = 0x154 }, /* rk3066 */
> > +       { .grf_offset = 0x0a4 }, /* rk3188 */
> > +};
> > +
> > +static const struct of_device_id emac_rockchip_dt_ids[] = {
> > +       { .compatible = "rockchip,rk3066-emac", .data =
> > &emac_rockchip_dt_data[0] }, +       { .compatible =
> > "rockchip,rk3188-emac", .data = &emac_rockchip_dt_data[1] }, +       { /*
> > Sentinel */ }
> > +};
> > +
> 
> One last question: is this the location given as .grf_offset the
> only thing in grf that is potentially of concern to this driver?
> 
> If it is, you can change the binding to include the register number
> in the syscon reference, like
> 
> 	rockchip,grf = <&grf 0x154>;
> 
> and then read it from there, to simplify the code needed to get the
> number from the device id.

I would disagree here :-)

Specific to the emac, there also exists a second register in the grf (0xa8 for 
the rk3188) that contains a field 

----
emac_newrcv_en - the selection of RMII receive selection
0: don't support the data package without header
1: support the data package without header
----

which we don't handle currently but somebody might want to in the future.
[There also is no documentation of this at all]


The dt maintainers also generally suggest to define compatibles for the 
individual socs anyway, even if only one is matched, so I don't see the 
necessity to encode this 2 times
	compatible = "rockchip,rk3188-emac", "rockchip,rk3066-emac";
	rockchip,grf = <&grf 0xa4>;

instead of the more flexible
	compatible = "rockchip,rk3188-emac";
	rockchip,grf = <&grf>;

which other rockchip drivers already use in this form.


Heiko

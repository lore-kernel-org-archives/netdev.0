From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH] remove vlan tags in CPSW dual emac mode
Date: Sat, 13 Jul 2013 00:05:53 +0530
Message-ID: <51E04C89.8030202@ti.com>
References: <4699400.vD3TdgH1nR@localhost> <5176C4FE.4080305@ti.com> <51E00B2F.6050406@newflow.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Markus Brunner <systemprogrammierung.brunner@gmail.com>,
	<netdev@vger.kernel.org>, <davem@davemloft.net>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>
To: Mark Jackson <mpfj-list@newflow.co.uk>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <51E00B2F.6050406@newflow.co.uk>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/12/2013 7:27 PM, Mark Jackson wrote:
> On 23/04/13 18:29, Mugunthan V N wrote:
>> On 4/23/2013 9:48 PM, Markus Brunner wrote:
>>> If operating in dual emac mode all packets sent by the CPSW contain vlan headers with the reserved VID 0,
>>> which gets stripped away by all somewhat recent Linux versions. Operating systems without that behaviour will fail to communicate.
>>> This patch fixes that behaviour by disabling the VLAN_AWARE mode as already described by the comment above.
>>>
>>> Signed-off-by: Markus Brunner <systemprogrammierung.brunner@gmail.com>
>>> Tested-by: Mark Jackson <mpfj@newflow.co.uk>
>>>
>>> ---
>>> --- linux-3.9-rc8.orig/drivers/net/ethernet/ti/cpsw.c    2013-04-23 17:26:11.000000000 +0200
>>> +++ linux-3.9-rc8/drivers/net/ethernet/ti/cpsw.c    2013-04-23 17:36:25.000000000 +0200
>>> @@ -751,9 +751,9 @@ static void cpsw_init_host_port(struct c
>>>       /* switch to vlan unaware mode */
>>>       cpsw_ale_control_set(priv->ale, priv->host_port, ALE_VLAN_AWARE,
>>>                    CPSW_ALE_VLAN_AWARE);
>>>       control_reg = readl(&priv->regs->control);
>>> -    control_reg |= CPSW_VLAN_AWARE;
>>> +    control_reg &= ~CPSW_VLAN_AWARE;
>>>       writel(control_reg, &priv->regs->control);
>>>       fifo_mode = (priv->data.dual_emac) ? CPSW_FIFO_DUAL_MAC_MODE :
>>>                CPSW_FIFO_NORMAL_MODE;
>>>       writel(fifo_mode, &priv->host_port_regs->tx_in_ctl);
>> Disabling VLAN aware mode will enable switching mode and the feature of
>> separating the two down stream port is lost with this patch
>> Please check TRM for more info in *14.3.2.10.2 Dual Mac Mode* chapter
> Just to update this (old) thread ...
>
> I can still confirm that *without* the above patch, I am *unable* to use both network
> ports on our AM335x board.
>
> My .dts file contains:-
>
> mac: ethernet@4a100000 {
> 	dual_emac = <1>;
>
> 	cpsw_emac0: slave@4a100200 {
> 		dual_emac_res_vlan = <1>;
> 	};
>
> 	cpsw_emac1: slave@4a100300 {
> 		dual_emac_res_vlan = <2>;
> 	};
> };
>
> &cpsw_emac0 {
> 	phy_id = <&davinci_mdio>, <0>;
> };
>
> &cpsw_emac1 {
> 	phy_id = <&davinci_mdio>, <1>;
> };
>
> My /etc/network/interfaces file is:-
>
> auto lo eth0 eth1
> iface lo inet loopback
> iface eth0 inet static
> address 10.0.101.3
> netmask 255.255.0.0
> gateway 10.0.0.1
> iface eth1 inet static
> address 10.1.101.3
> netmask 255.255.0.0
>
> So I'm not sure what's wrong, but it's *definitely* not correct.
>
>
I am sure that current code in mainline works for Dual EMAC. I can test it
again and share the images with you if are interested. But had tested with DHCP
on both the interfaces.

Regards
Mugunthan V N

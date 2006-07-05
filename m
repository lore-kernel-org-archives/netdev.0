From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.17 5/9] NetXen: hardware access header file
Date: Wed, 05 Jul 2006 12:04:04 -0400
Message-ID: <44ABE2F4.2080606@garzik.org>
References: <Pine.LNX.4.64.0607050602310.27969@dut46> <Pine.LNX.4.64.0607050634360.27969@dut46>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sanjeev@netxen.com, unmproj@linsyssoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45454 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S964843AbWGEQEG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2006 12:04:06 -0400
To: "Linsys Contractor Amit S. Kale" <amitkale@unminc.com>
In-Reply-To: <Pine.LNX.4.64.0607050634360.27969@dut46>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linsys Contractor Amit S. Kale wrote:
> +#ifndef readq

this test fails where readq is not a macro


> +static inline u64 readq(void __iomem * addr)
> +{
> +    return readl(addr) | (((u64) readl(addr + 4)) << 32LL);
> +}
> +#endif
> +
> +#ifndef writeq
> +static inline void writeq(u64 val, void __iomem * addr)
> +{
> +    writel(((u32) (val)), (addr));
> +    writel(((u32) (val >> 32)), (addr + 4));
> +}
> +#endif

overall, don't define these.

If you have a platform that doesn't support readq(), add it there...



> +/*
> + * NIU GB MAC Config Register 0 (applies to GB0, GB1, GB2, GB3)
> + */
> +struct netxen_niu_gb_mac_config_0_t {
> +    netxen_crbword_t tx_enable:1,    /* 1:enable frame xmit, 0:disable */
> +     tx_synched:1,        /* R/O: xmit enable synched to xmit stream */
> +     rx_enable:1,        /* 1:enable frame recv, 0:disable */
> +     rx_synched:1,        /* R/O: recv enable synched to recv stream */
> +     tx_flowctl:1,        /* 1:enable pause frame generation, 0:disable*/
> +     rx_flowctl:1,        /* 1:act on recv'd pause frames, 0:ignore */
> +     rsvd1:2,
> +     loopback:1,        /* 1:loop MAC xmits to MAC recvs, 0:normal */
> +     rsvd2:7,
> +     tx_reset_pb:1,        /* 1:reset frame xmit protocol blk, 0:no-op */
> +     rx_reset_pb:1,        /* 1:reset frame recv protocol blk, 0:no-op */
> +     tx_reset_mac:1,    /* 1:reset data/ctl multiplexer blk, 0:no-op */
> +     rx_reset_mac:1,    /* 1:reset ctl frames & timers blk, 0:no-op */
> +     rsvd3:11,
> +     soft_reset:1;    /* 1:reset the MAC and the SERDES, 0:no-op */
> +};

More bitfields to kill


> +/*
> + * NIU GB MAC Config Register 1 (applies to GB0, GB1, GB2, GB3)
> + */
> +struct netxen_niu_gb_mac_config_1_t {
> +    netxen_crbword_t duplex:1,    /* 1:full duplex mode, 0:half duplex */
> +     crc_enable:1,    /* 1:append CRC to xmit frames, 0:dont append */
> +     padshort:1,    /* 1:pad short frames and add CRC, 0:dont pad */
> +     rsvd1:1,
> +     checklength:1,    /* 1:check framelen with actual, 0:dont check */
> +     hugeframes:1,    /* 1:allow oversize xmit frames, 0:dont allow */
> +     rsvd2:2,
> +     intfmode:2,    /* 01:nibble (10/100), 10:byte (1000) */
> +     rsvd3:2,
> +     preamblelen:4,    /* preamble field length in bytes, default 7 */
> +     rsvd4:16;
> +};

ditto


> +/*
> + * NIU GB Station Address High Register
> + * NOTE: this value is in network byte order.
> + */
> +struct netxen_niu_gb_station_address_high {
> +    netxen_crbword_t address:32;    /* station address [47:16] */
> +};
> +
> +/*
> + * NIU GB Station Address Low Register
> + * NOTE: this value is in network byte order.
> + */
> +struct netxen_niu_gb_station_address_low {
> +    netxen_crbword_t rsvd:16, address:16;    /* station address [15:0] */
> +};

ditto


  +/*
> + * NIU GB MII Mgmt Config Register (applies to GB0, GB1, GB2, GB3)
> + */
> +struct netxen_niu_gb_mii_mgmt_config {
> +    netxen_crbword_t clockselect:3,
> +        /* 0:clk/4,  1:clk/4,  2:clk/6,  3:clk/8 */
> +        /* 4:clk/10, 5:clk/14, 6:clk/20, 7:clk/28 */
> +     rsvd1:1, nopreamble:1,    /* 1:suppress preamble generation, 
> 0:normal */
> +     scanauto:1, rsvd2:25, reset:1;    /* 1:reset MII mgmt, 0:no-op */
> +};
> +
> +/*
> + * NIU GB MII Mgmt Command Register (applies to GB0, GB1, GB2, GB3)
> + */
> +struct netxen_niu_gb_mii_mgmt_command {
> +    /* 1:perform single read cycle, 0:no-op */
> +    netxen_crbword_t read_cycle:1,
> +     scan_cycle:1,        /* 1:perform continuous read cycles, 0:no-op */
> +     rsvd:30;
> +};
> +
> +/*
> + * NIU GB MII Mgmt Address Register (applies to GB0, GB1, GB2, GB3)
> + */
> +struct netxen_niu_gb_mii_mgmt_address {
> +    /* which mgmt register we want to talk to */
> +    netxen_crbword_t reg_addr:5,
> +     rsvd1:3, phy_addr:5,    /* which PHY to talk to (0 is reserved) */
> +     rsvd:19;
> +};
> +
> +/*
> + * NIU GB MII Mgmt Indicators Register (applies to GB0, GB1, GB2, GB3)
> + * Read-only register.
> + */
> +struct netxen_niu_gb_mii_mgmt_indicators {
> +    /* 1:performing an MII mgmt cycle, 0:idle */
> +    netxen_crbword_t busy:1,
> +     scanning:1,        /* 1:scan operation in progress, 0:idle */
> +     notvalid:1,        /* 1:mgmt result data not yet valid, 0:idle */
> +     rsvd:29;
> +};

ditto x 4


> +typedef enum {
> +    NETXEN_NIU_GB_MII_MGMT_ADDR_CONTROL = 0,
> +    NETXEN_NIU_GB_MII_MGMT_ADDR_STATUS = 1,
> +    NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_ID_0 = 2,
> +    NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_ID_1 = 3,
> +    NETXEN_NIU_GB_MII_MGMT_ADDR_AUTONEG = 4,
> +    NETXEN_NIU_GB_MII_MGMT_ADDR_LNKPART = 5,
> +    NETXEN_NIU_GB_MII_MGMT_ADDR_AUTONEG_MORE = 6,
> +    NETXEN_NIU_GB_MII_MGMT_ADDR_NEXTPAGE_XMIT = 7,
> +    NETXEN_NIU_GB_MII_MGMT_ADDR_LNKPART_NEXTPAGE = 8,
> +    NETXEN_NIU_GB_MII_MGMT_ADDR_1000BT_CONTROL = 9,
> +    NETXEN_NIU_GB_MII_MGMT_ADDR_1000BT_STATUS = 10,
> +    NETXEN_NIU_GB_MII_MGMT_ADDR_EXTENDED_STATUS = 15,
> +    NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_CONTROL = 16,
> +    NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS = 17,
> +    NETXEN_NIU_GB_MII_MGMT_ADDR_INT_ENABLE = 18,
> +    NETXEN_NIU_GB_MII_MGMT_ADDR_INT_STATUS = 19,
> +    NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_CONTROL_MORE = 20,
> +    NETXEN_NIU_GB_MII_MGMT_ADDR_RECV_ERROR_COUNT = 21,
> +    NETXEN_NIU_GB_MII_MGMT_ADDR_LED_CONTROL = 24,
> +    NETXEN_NIU_GB_MII_MGMT_ADDR_LED_OVERRIDE = 25,
> +    NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_CONTROL_MORE_YET = 26,
> +    NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS_MORE = 27
> +} netxen_niu_phy_register_t;
> +
> +/*
> + * PHY-Specific Status Register (reg 17).
> + */
> +struct netxen_niu_phy_status {
> +    netxen_crbword_t jabber:1,    /* 1:jabber detected, 0:not */
> +     polarity:1,        /* 1:polarity reversed, 0:normal */
> +     recvpause:1,        /* 1:receive pause enabled, 0:disabled */
> +     xmitpause:1,        /* 1:transmit pause enabled, 0:disabled */
> +     energydetect:1,    /* 1:sleep, 0:active */
> +     downshift:1,        /* 1:downshift, 0:no downshift */
> +     crossover:1,        /* 1:MDIX (crossover), 0:MDI (no crossover) */
> +     cablelen:3,        /* not valid in 10Mb/s mode */
> +        /* 0:<50m, 1:50-80m, 2:80-110m, 3:110-140m, 4:>140m */
> +     link:1,        /* 1:link up, 0:link down */
> +     resolved:1,        /* 1:speed and duplex resolved, 0:not yet */
> +     pagercvd:1,        /* 1:page received, 0:page not received */
> +     duplex:1,        /* 1:full duplex, 0:half duplex */
> +     speed:2,        /* 0:10Mb/s, 1:100Mb/s, 2:1000Mb/s, 3:rsvd */
> +     rsvd:16;
> +};
> +
> +/*
> + * Interrupt Register definition
> + * This definition applies to registers 18 and 19 (int enable and int 
> status).
> + */
> +struct netxen_niu_phy_interrupt {
> +    netxen_crbword_t
> +        jabber:1,
> +        polarity_changed:1,
> +        reserved:2,
> +        energy_detect:1,
> +        downshift:1,
> +        mdi_xover_changed:1,
> +        fifo_over_underflow:1,
> +        false_carrier:1,
> +        symbol_error:1,
> +        link_status_changed:1,
> +        autoneg_completed:1,
> +        page_received:1,
> +        duplex_changed:1, speed_changed:1, autoneg_error:1, rsvd:16;
> +};
> +
> +/*
> + * NIU Mode Register.
> + */
> +struct netxen_niu_control {
> +    netxen_crbword_t enable_fc:1,    /* enable FibreChannel */
> +     enable_ge:1,        /* enable 10/100/1000 Ethernet */
> +     enable_xgb:1,        /* enable 10Gb Ethernet */
> +     rsvd:29;
> +};
> +
> +/* Promiscous mode options (GbE mode only) */
> +typedef enum {
> +    NETXEN_NIU_PROMISCOUS_MODE = 0,
> +    NETXEN_NIU_NON_PROMISCOUS_MODE
> +} netxen_niu_prom_mode_t;
> +
> +/*
> + * NIU GB Drop CRC Register
> + */
> +struct netxen_niu_gb_drop_crc {
> +    /* 1:drop pkts with bad CRCs, 0:pass them on */
> +    netxen_crbword_t drop_gb0:1,
> +     drop_gb1:1,        /* 1:drop pkts with bad CRCs, 0:pass them on */
> +     drop_gb2:1,        /* 1:drop pkts with bad CRCs, 0:pass them on */
> +     drop_gb3:1,        /* 1:drop pkts with bad CRCs, 0:pass them on */
> +     rsvd:28;
> +};
> +
> +/*
> + * NIU XG MAC Config Register
> + */
> +struct netxen_niu_xg_mac_config_0_t {
> +    netxen_crbword_t tx_enable:1,    /* 1:enable frame xmit, 0:disable */
> +     rsvd1:1, rx_enable:1,    /* 1:enable frame recv, 0:disable */
> +     rsvd2:1, soft_reset:1,    /* 1:reset the MAC , 0:no-op */
> +     rsvd3:22,
> +        xaui_framer_reset:1,
> +        xaui_rx_reset:1,
> +        xaui_tx_reset:1, xg_ingress_afifo_reset:1, 
> xg_egress_afifo_reset:1;
> +};

many more structs with bitfields




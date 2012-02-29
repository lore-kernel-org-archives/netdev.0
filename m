From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [PATCH v4 2/2] netdev: driver: ethernet: Add TI CPSW driver
Date: Wed, 29 Feb 2012 14:15:10 +0100
Message-ID: <87pqcxdbmp.fsf@macbook.be.48ers.dk>
References: <1330490737-28973-1-git-send-email-mugunthanvnm@ti.com>
	<1330490737-28973-3-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:44012 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754620Ab2B2NPU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Feb 2012 08:15:20 -0500
Received: by wibhm11 with SMTP id hm11so2677715wib.19
        for <netdev@vger.kernel.org>; Wed, 29 Feb 2012 05:15:19 -0800 (PST)
In-Reply-To: <1330490737-28973-3-git-send-email-mugunthanvnm@ti.com>
	(Mugunthan V. N.'s message of "Wed, 29 Feb 2012 10:15:37 +0530")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "M" == Mugunthan V N <mugunthanvnm@ti.com> writes:

Hi,

 M> This patch adds support for TI's CPSW driver.
 M> The three port switch gigabit ethernet subsystem provides ethernet packet
 M> communication and can be configured as an ethernet switch. Supports
 M> 10/100/1000 Mbps.

 M> Signed-off-by: Cyril Chemparathy <cyril@ti.com>
 M> Signed-off-by: Sriramakrishnan A G <srk@ti.com>
 M> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>

 M> +++ b/include/linux/platform_data/cpsw.h
 M> @@ -0,0 +1,55 @@
 M> +/*
 M> + * Texas Instruments Ethernet Switch Driver
 M> + *
 M> + * Copyright (C) 2012 Texas Instruments
 M> + *
 M> + * This program is free software; you can redistribute it and/or
 M> + * modify it under the terms of the GNU General Public License as
 M> + * published by the Free Software Foundation version 2.
 M> + *
 M> + * This program is distributed "as is" WITHOUT ANY WARRANTY of any
 M> + * kind, whether express or implied; without even the implied warranty
 M> + * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 M> + * GNU General Public License for more details.
 M> + */
 M> +#ifndef __CPSW_H__
 M> +#define __CPSW_H__
 M> +
 M> +#include <linux/if_ether.h>
 M> +
 M> +struct cpsw_slave_data {
 M> +	u32		slave_reg_ofs;
 M> +	u32		sliver_reg_ofs;
 M> +	const char	*phy_id;
 M> +	int		phy_if;
 M> +	u8		mac_addr[ETH_ALEN];
 M> +};
 M> +
 M> +struct cpsw_platform_data {
 M> +	u32	ss_reg_ofs;	/* Subsystem control register offset */
 M> +	u32	channels;	/* number of cpdma channels (symmetric) */
 M> +	u32	cpdma_reg_ofs;	/* cpdma register offset */
 M> +	u32	cpdma_sram_ofs;	/* cpdma sram offset */
 M> +
 M> +	u32	slaves;		/* number of slave cpgmac ports */
 M> +	struct cpsw_slave_data	*slave_data;
 M> +
 M> +	u32	ale_reg_ofs;	/* address lookup engine reg offset */
 M> +	u32	ale_entries;	/* ale table size */
 M> +
 M> +	u32	host_port_reg_ofs; /* cpsw cpdma host port registers */
 M> +	u32     host_port_num; /* The port number for the host port */
 M> +
 M> +	u32	hw_stats_reg_ofs;  /* cpsw hardware statistics counters */
 M> +
 M> +	u32	bd_ram_ofs;   /* embedded buffer descriptor RAM offset*/
 M> +	u32	bd_ram_size;  /*buffer descriptor ram size */
 M> +	u32	hw_ram_addr; /*if the HW address for BD RAM is different */
 M> +	bool	no_bd_ram; /* no embedded BD ram*/
 M> +
 M> +	u32	rx_descs;	/* Number of Rx Descriptios */
 M> +
 M> +	u32	mac_control;	/* Mac control register */
 M> +};

Is this really platform specific data (rather than SoC specific)? If
it's purely a difference between 335x and 814x just use an id_table with
different platform device names instead.

-- 
Bye, Peter Korsgaard

From: "N, Mugunthan V" <mugunthanvnm@ti.com>
Subject: RE: [PATCH 1/6] drivers: net: ethernet: cpsw: add support for CPSW
 register offset changes in different IP version
Date: Mon, 22 Oct 2012 10:39:51 +0000
Message-ID: <EB1619762EAF8B4E97A227FB77B7E0293E9FD69E@DBDE01.ent.ti.com>
References: <1350427518-7230-1-git-send-email-mugunthanvnm@ti.com>
 <1350427518-7230-2-git-send-email-mugunthanvnm@ti.com>
 <20121018024523.GA2867@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:39112 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751245Ab2JVKjz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2012 06:39:55 -0400
In-Reply-To: <20121018024523.GA2867@netboy.at.omicron.at>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: Thursday, October 18, 2012 8:15 AM
> To: N, Mugunthan V
> Cc: netdev@vger.kernel.org; davem@davemloft.net
> Subject: Re: [PATCH 1/6] drivers: net: ethernet: cpsw: add support for
> CPSW register offset changes in different IP version
> 
> On Wed, Oct 17, 2012 at 04:15:13AM +0530, Mugunthan V N wrote:
> >

> > +
> > +static const u32 slave_reg_map_ip_v2[] = {
> > +	[PORT_CONTROL]	= 0x00,
> > +	[TS_CONTROL]	= 0x04,
> 
> You don't make use of this register in your driver, so what is the
> point?

This register is used in next version of CPSW. Since I don't use it in
current version I will remove the same in next version patch series.

> 
> > +	[MAX_BLKS]	= 0x08,
> > +	[BLK_CNT]	= 0x0c,
> > +	[FLOW_THRESH]	= 0x10,
> > +	[PORT_VLAN]	= 0x14,
> > +	[TX_PRI_MAP]	= 0x18,
> > +	[TS_SEQ_MTYPE]	= 0x1c,
> > +	[SA_LO]		= 0x20,
> > +	[SA_HI]		= 0x24,
> > +};
> > +
> 
> This is wasting memory with unused static stables. There is a better
> way to handle this issue.

I have taken the code reference from the following driver.
drivers/i2c/busses/i2c-omap.c

Can you refer other better solution to handle this?

> 
> >  static int debug_level;
> >  module_param(debug_level, int, 0);
> >  MODULE_PARM_DESC(debug_level, "cpsw debug level (NETIF_MSG bits)");

>  	pm_runtime_get_sync(&priv->pdev->dev);
> >
> > -	reg = __raw_readl(&priv->regs->id_ver);
> > +	reg = readl(&priv->regs->id_ver);
> > +	priv->cpsw_version = reg;
> > +	if (reg == CPSW_VERSION_1)
> > +		priv->slave_reg_ofs = (u32 *)slave_reg_map_ip_v1;
> > +	else
> > +		priv->slave_reg_ofs = (u32 *)slave_reg_map_ip_v2;
> 
> You didn't provide a way to even use this code, like a dts for a
> non-am335x board with the older version.
> 
> I think it would be better to start off supporting one version and
> have that fully working, and then add the older version, but *really*
> add it so that it is actually working.
> 

Since version info from hardware registers can be used to differentiate between
the CPSW versions so I don't think there is a need to provide the same through DT.

Regards
Mugunthan V N

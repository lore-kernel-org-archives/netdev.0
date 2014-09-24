From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v1 4/5] drivers: net: xgene: Add 10GbE support
Date: Wed, 24 Sep 2014 15:10:07 +0200
Message-ID: <7752137.3u6F6qDtIo@wuerfel>
References: <1411530688-2939-1-git-send-email-isubramanian@apm.com> <1411530688-2939-5-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, kchudgar@apm.com, patches@apm.com
To: Iyappan Subramanian <isubramanian@apm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.24]:54708 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751209AbaIXNKR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 09:10:17 -0400
In-Reply-To: <1411530688-2939-5-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 23 September 2014 20:51:27 Iyappan Subramanian wrote:
> -static void xgene_enet_wr_mcx_mac(struct xgene_enet_pdata *pdata,
> -                                 u32 wr_addr, u32 wr_data)
> +void xgene_enet_wr_mac(struct xgene_enet_pdata *pdata, u32 wr_addr, u32 wr_data)
>  {
>         void __iomem *addr, *wr, *cmd, *cmd_done;
>  
> -       addr = pdata->mcx_mac_addr + MAC_ADDR_REG_OFFSET;
> -       wr = pdata->mcx_mac_addr + MAC_WRITE_REG_OFFSET;
> -       cmd = pdata->mcx_mac_addr + MAC_COMMAND_REG_OFFSET;
> -       cmd_done = pdata->mcx_mac_addr + MAC_COMMAND_DONE_REG_OFFSET;
> +       addr = pdata->mac_addr + MAC_ADDR_REG_OFFSET;
> +       wr = pdata->mac_addr + MAC_WRITE_REG_OFFSET;
> +       cmd = pdata->mac_addr + MAC_COMMAND_REG_OFFSET;
> +       cmd_done = pdata->mac_addr + MAC_COMMAND_DONE_REG_OFFSET;
>  
>         if (!xgene_enet_wr_indirect(addr, wr, cmd, cmd_done, wr_addr, wr_data))
>                 netdev_err(pdata->ndev, "MCX mac write failed, addr: %04x\n",
>                            wr_addr);
>  }
>  
> -static void xgene_enet_rd_csr(struct xgene_enet_pdata *pdata,
> -                             u32 offset, u32 *val)
> +void xgene_enet_rd_csr(struct xgene_enet_pdata *pdata, u32 offset, u32 *val)
>  {
>         void __iomem *addr = pdata->eth_csr_addr + offset;
>  
> 

A lot of the changes in this patch seem to just rename existing interfaces.
Please split those out into a preparatory patch, to make it easier to
review the actual functional changes.

	Arnd

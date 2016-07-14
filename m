From: walter harms <wharms@bfs.de>
Subject: Re: [patch -next] wan/fsl_ucc_hdlc: info leak in uhdlc_ioctl()
Date: Thu, 14 Jul 2016 12:52:16 +0200
Message-ID: <57876EE0.10603@bfs.de>
References: <20160714103415.GE18175@mwanda>
Reply-To: wharms@bfs.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Zhao Qiang <qiang.zhao@nxp.com>, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx01-fr.bfs.de ([193.174.231.67]:23429 "EHLO mx01-fr.bfs.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751059AbcGNKw3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jul 2016 06:52:29 -0400
In-Reply-To: <20160714103415.GE18175@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Am 14.07.2016 12:34, schrieb Dan Carpenter:
> There is a 2 byte struct whole after line.loopback so we need to clear
> that out to avoid disclosing stack information.
> 
> Fixes: c19b6d246a35 ('drivers/net: support hdlc function for QE-UCC')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/drivers/net/wan/fsl_ucc_hdlc.c b/drivers/net/wan/fsl_ucc_hdlc.c
> index 19174ac..7608561 100644
> --- a/drivers/net/wan/fsl_ucc_hdlc.c
> +++ b/drivers/net/wan/fsl_ucc_hdlc.c
> @@ -635,6 +635,7 @@ static int uhdlc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
>  			ifr->ifr_settings.size = size; /* data size wanted */
>  			return -ENOBUFS;
>  		}
> +		memset(&line, 0, sizeof(line));
>  		line.clock_type = priv->clocking;
>  		line.clock_rate = 0;
>  		line.loopback = 0;


In this case
  		line.clock_rate = 0;
 		line.loopback = 0;

are not need any more and can be removed
except like them to have for documentation or so.

re,
 wh

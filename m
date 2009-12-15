From: stefano babic <stefano.babic@babic.homelinux.org>
Subject: Re: [RFC PATCH v3  3/8] CAIF Protocol Stack
Date: Tue, 15 Dec 2009 17:00:04 +0100
Message-ID: <4B27B284.5010009@babic.homelinux.org>
References: <1259593252-2493-1-git-send-email-sjur.brandeland@stericsson.com> <1259593252-2493-2-git-send-email-sjur.brandeland@stericsson.com> <1259593252-2493-3-git-send-email-sjur.brandeland@stericsson.com> <1259593252-2493-4-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, randy.dunlap@oracle.com,
	kim.xx.lilliestierna@stericsson.com,
	christian.bejram@stericsson.com, daniel.martensson@stericsson.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpout09.attiva.biz ([85.37.16.7]:23836 "EHLO
	smtpout09.attiva.biz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754389AbZLOQAN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2009 11:00:13 -0500
In-Reply-To: <1259593252-2493-4-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sjur.brandeland@stericsson.com wrote:
> diff --git a/include/net/caif/caif_chr.h b/include/net/caif/caif_chr.h
> new file mode 100644
> index 0000000..ebd89f8
> --- /dev/null
> +++ b/include/net/caif/caif_chr.h

Only a question of taste, but there is no chr device anymore, maybe
another name for the file should be more appropriate.

> +struct caif_service_config;
> +
> +enum cf_chr_dev_type {
> +	CFDEVTYPE_CHR,
> +	CFDEVTYPE_TTY,
> +	CFDEVTYPE_NET
> +};
> +
> +extern int serial_use_stx;
> +extern int (*netdev_mgmt_func) (int action, union caif_action *param);
> +int caifdev_phy_reg(struct layer *phyif, struct cfcnfg_phy_mgmt *mgmt);
> +int caifdev_phy_instanciate(struct cfcnfg_phy_config *phy_config);
> +int caifdev_phy_register(struct layer *phyif,
> +			 enum cfcnfg_phy_type phy_type,
> +			 enum cfcnfg_phy_preference phy_pref);
> +int caifdev_phy_unregister(struct layer *phyif);
> +int caifdev_phy_loop_register(struct layer *phyif,
> +			      enum cfcnfg_phy_type phy_type);
> +int caifdev_phy_spi_xmitlen(struct cfspil *layr);
> +struct cfpkt *caifdev_phy_spi_getxmitpkt(struct cfspil *layr);

All these functions seem obsolete.

> +int caif_register_chrdev(int (*chrdev_mgmt)
> +			(int action, union caif_action *param));
> +void caif_unregister_chrdev(void);

Obsolete, too.

> diff --git a/include/net/caif/caif_config_util.h b/include/net/caif/caif_config_util.h
> new file mode 100644
> index 0000000..cdc1443
> --- /dev/null
> +++ b/include/net/caif/caif_config_util.h
> @@ -0,0 +1,20 @@
> +/*
> + * Copyright (C) ST-Ericsson AB 2009
> + * Author:	Daniel Martensson / Daniel.Martensson@stericsson.com
> + * License terms: GNU General Public License (GPL) version 2
> + */
> +
> +#ifndef CAIF_CONFIG_UTIL_H_
> +#define CAIF_CONFIG_UTIL_H_
> +
> +#include <linux/caif/caif_config.h>
> +#include <linux/caif/caif_ioctl.h>
> +#include <net/caif/generic/cfcnfg.h>
> +#include <net/caif/generic/cfctrl.h>
> +#include <net/caif/caif_actions.h>
> +
> +int channel_config_2_link_param(struct cfcnfg *cnfg,
> +				struct caif_channel_config *s,
> +				struct cfctrl_link_param *l);
> +
> +#endif

Do we need an extra-header only to set the prototype of a single
function ? Probably can we move it into another header file.

Stefano

-- 
stefano <stefano.babic@babic.homelinux.org>
GPG Key: 0x55814DDE
Fingerprint 4E85 2A66 4CBA 497A 2A7B D3BF 5973 F216 5581 4DDE

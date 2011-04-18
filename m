From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2 01/27] HFI: skeleton driver
Date: Mon, 18 Apr 2011 13:23:19 +0100
Message-ID: <1303129399.5282.1033.camel@localhost>
References: <1303096919-7367-1-git-send-email-dykmanj@linux.vnet.ibm.com>
	 <1303096919-7367-2-git-send-email-dykmanj@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Piyush Chaudhary <piyushc@linux.vnet.ibm.com>,
	Fu-Chung Chang <fcchang@linux.vnet.ibm.com>,
	"William S. Cadden" <wscadden@linux.vnet.ibm.com>,
	"Wen C. Chen" <winstonc@linux.vnet.ibm.com>,
	Scot Sakolish <sakolish@linux.vnet.ibm.com>,
	Jian Xiao <jian@linux.vnet.ibm.com>,
	"Carol L. Soto" <clsoto@linux.vnet.ibm.com>,
	"Sarah J. Sheppard" <sjsheppa@linux.vnet.ibm.com>
To: dykmanj@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:14381 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751822Ab1DRMXX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2011 08:23:23 -0400
In-Reply-To: <1303096919-7367-2-git-send-email-dykmanj@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-04-17 at 23:21 -0400, dykmanj@linux.vnet.ibm.com wrote:
> From: Jim Dykman <dykmanj@linux.vnet.ibm.com>
> 
> Device driver Makefile & Kconfig plumbing plus simple mod_init and mod_exit
[...]
> --- /dev/null
> +++ b/drivers/net/hfi/core/hfidd_init.c
[...]
> +#include <linux/version.h>

Never include <linux/version.h> in an in-tree driver.

[...]
> +static int __init hfidd_mod_init(void)
> +{
> +	int			rc = 0;
> +
> +	rc = hfidd_create_class();
> +	if (rc < 0) {
> +		printk(KERN_ERR "%s: hfidd_mod_init: hfidd_create_class failed"
> +			" rc=%d\n", HFIDD_DEV_NAME, rc);
> +		return -1;

Should be 'return rc'.

[...]
> --- /dev/null
> +++ b/include/linux/hfi/hfidd_client.h
[...]
> +#ifndef _HFIDD_CLIENT_H_
> +#define _HFIDD_CLIENT_H_
> +
> +#define MAX_TORRENTS            1
> +#define MAX_HFI_PER_TORRENT     2
> +#define MAX_HFIS                (MAX_TORRENTS * MAX_HFI_PER_TORRENT)
[...]

Are you sure you want to expose these values to userland?  You can never
change them later.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


From: Stefano Babic <stefano.babic@babic.homelinux.org>
Subject: Re: [PATCH] [CAIF-RFC 2/8-v2] CAIF Protocol Stack
Date: Mon, 12 Oct 2009 11:28:29 +0200
Message-ID: <4AD2F6BD.1020608@babic.homelinux.org>
References: <1255095571-6501-1-git-send-email-sjur.brandeland@stericsson.com> <1255095571-6501-2-git-send-email-sjur.brandeland@stericsson.com> <1255095571-6501-3-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kim.xx.lilliestierna@stericsson.com,
	christian.bejram@stericsson.com, daniel.martensson@stericsson.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpout27.attiva.biz ([85.37.16.28]:46946 "EHLO
	smtpout27.attiva.biz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755305AbZJLJ3N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 05:29:13 -0400
In-Reply-To: <1255095571-6501-3-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sjur.brandeland@stericsson.com wrote:
> From: Sjur Braendeland <sjur.brandeland@stericsson.com>
> 

Hi Sjur,

> diff --git a/include/net/caif/generic/cfcnfg.h b/include/net/caif/generic/cfcnfg.h

> +/** Types of Physical Layers defined in CAIF Stack */
> +typedef enum _cfcnfg_phy_type_t {
> +	CFPHYTYPE_UNKNOWN = 0,
> +	CFPHYTYPE_SERIAL = 1,	/*!< Serial Physical Interface */
> +	CFPHYTYPE_SPI = 2,	/*!< SPI Physical Interface */
> +	CFPHYTYPE_MSL = 3,	/*!< MSL Physical Interface */
> +	CFPHYTYPE_SHM = 4,	/*!< Shared Memory Physical Interface */

You actually removed the shared memory driver. Do you plan to insert it
again ?


> +/**
> + * Adds a Adaptation Layer to the CAIF Stack.
> + * The Adaptation Layer is where the interface to application or higher-level
> + * driver functionality is implemented.
> + * \image html AddVeiCaifConfig.jpg "Add an Adaptation layer to CAIF Stack."

There are references to pictures that are not provided.

> diff --git a/include/net/caif/generic/cfglue.h b/include/net/caif/generic/cfglue.h

[snip]

> +/* ASSERT */
> +#define cfglu_assert(exp) BUG_ON(!(exp))

I do not why, but even GENERIC_BUG is not defined for all architectures.
This means that BUG_ON is simply removed by the compiler and we get no
track if the assert fails.
It should be better to add at least an internal trace (adding for
example a CFLOG_FATAL call).

> diff --git a/include/net/caif/generic/cfshml.h b/include/net/caif/generic/cfshml.h

Is thif file probably obsolete ?

> diff --git a/include/net/caif/generic/cfspil.h b/include/net/caif/generic/cfspil.h
> +/** @page SPI PHY Layer description.
> + *
> + *  SPI Physical layer is not implemented in GenCaif. The SPI PHY Layer
> + *  is HW dependent. But the CFSPIL (Caif SPI Layer) provides support for
> + *  implementing the SPI Layer Protocol.

Not sure I have understood. There is an abstraction layer for SPI in
kernel and some generic purpose functions are provided (spy_sync,
spi_async, etc.) that are HW independent. I know they provide only the
methods for the data transfer, but I have imagined that we need at this
point some kind of "caif_spi_device" that is able to talk with the caif
stack on one side and uses the functions in the SPI framework. In any
case, HW independent. Have I missed something ?

Stefano

-- 
stefano <stefano.babic@babic.homelinux.org>
GPG Key: 0x55814DDE
Fingerprint 4E85 2A66 4CBA 497A 2A7B D3BF 5973 F216 5581 4DDE

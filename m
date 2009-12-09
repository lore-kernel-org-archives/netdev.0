From: stefano babic <stefano.babic@babic.homelinux.org>
Subject: Re: [RFC PATCH v3  2/8] CAIF Protocol Stack
Date: Wed, 09 Dec 2009 01:18:52 +0100
Message-ID: <4B1EECEC.5080903@babic.homelinux.org>
References: <1259593252-2493-1-git-send-email-sjur.brandeland@stericsson.com> <1259593252-2493-2-git-send-email-sjur.brandeland@stericsson.com> <1259593252-2493-3-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, randy.dunlap@oracle.com,
	kim.xx.lilliestierna@stericsson.com,
	christian.bejram@stericsson.com, daniel.martensson@stericsson.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpout23.attiva.biz ([85.37.16.24]:45698 "EHLO
	smtpout23.attiva.biz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966710AbZLIASv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 19:18:51 -0500
In-Reply-To: <1259593252-2493-3-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sjur.brandeland@stericsson.com wrote:
> diff --git a/include/net/caif/generic/caif_layer.h b/include/net/caif/generic/caif_layer.h

> +enum caif_ctrlcmd {
> +	/** Flow Control is OFF, transmit function should stop sending data */
> +	CAIF_CTRLCMD_FLOW_OFF_IND = 0,
> +	/** Flow Control is ON, transmit function can start sending data */
> +	CAIF_CTRLCMD_FLOW_ON_IND = 1,
> +	/** Remote end modem has decided to close down channel */
> +	CAIF_CTRLCMD_REMOTE_SHUTDOWN_IND = 5,

Not really important, but is there some reason to not put them in order ?


> diff --git a/include/net/caif/generic/cfcnfg.h b/include/net/caif/generic/cfcnfg.h
> +/** Physical preference - HW Abstraction */
> +enum cfcnfg_phy_preference {
> +	/** Default physical interface */
> +	CFPHYPREF_UNSPECIFIED = 0xa0,
> +	/** Default physical interface for low-latency traffic */
> +	CFPHYPREF_LOW_LAT = 0xd0,
> +	/** Default physical interface for high-bandwidth traffic */
> +	CFPHYPREF_HIGH_BW = 0xe0,
> +	/** \b TEST \b ONLY Loopback interface simulating modem responses */
> +	CFPHYPREF_LOOP = 0x70,
> +	/** \b TEST \b ONLY Raw loopback interface */
> +	CFPHYPREF_RAW_LOOP = 0x80
> +};

Different context, but preferences have always the same values. Could we
remove the duplicates ?

> +/** Configuration parameters for a physical layer (e.g. serial) */
> +struct cfcnfg_phy_param {
> +	int foo;
> +};

This structure is obsolete and can be safely dropped.

> +/**
> + * These variable is used as a global flag, in order to configure padding on SPI communication.
> + * NOTE: This is not a fully future-proof solution.
> + */

I understand that the padding is due to the fact that a lot of spi
controller can send only words and not bytes. However, this is very
processor specific. Probably when you will add the SPI layer you will
need to add a way to set up this issue.

Stefano

-- 
stefano <stefano.babic@babic.homelinux.org>
GPG Key: 0x55814DDE
Fingerprint 4E85 2A66 4CBA 497A 2A7B D3BF 5973 F216 5581 4DDE

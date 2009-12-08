From: stefano babic <stefano.babic@babic.homelinux.org>
Subject: Re: [RFC PATCH v3  1/8] CAIF Protocol Stack
Date: Wed, 09 Dec 2009 00:42:44 +0100
Message-ID: <4B1EE474.5000508@babic.homelinux.org>
References: <1259593252-2493-1-git-send-email-sjur.brandeland@stericsson.com> <1259593252-2493-2-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, randy.dunlap@oracle.com,
	kim.xx.lilliestierna@stericsson.com,
	christian.bejram@stericsson.com, daniel.martensson@stericsson.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpout27.attiva.biz ([85.37.16.28]:47773 "EHLO
	smtpout27.attiva.biz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966900AbZLHXmn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 18:42:43 -0500
In-Reply-To: <1259593252-2493-2-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sjur.brandeland@stericsson.com wrote:

> +#define CAIF_PRIO_UNSPCEIFIED  0x0

The define is not used in code, but probably you would prefer to set
CAIF_PRIO_UNSPECIFIED


> diff --git a/include/linux/caif/caif_ioctl.h b/include/linux/caif/caif_ioctl.h
> +/*!\page  caif_ioctl.h
> + * This file defines the management interface to CAIF.
> + * It defines how CAIF channels are configured and become visible in the
> + * Linux file system, typically under "/dev".

This is not updated, you have already removed the char devices.

> + *
> + *\b Example - creating a new AT character device:
> + * \code
> +   fd = open("/dev/caifconfig",..);
> +   struct caif_channel_create_action at_config = {
> +	 .name = "cnhl2",
> +	 .config = {
> +	    .channel = CAIF_CHTY_AT,
> +	    .phy_ref = CAIF_PHY_LOW_LAT,
> +	    .priority = CAIF_PRIO_HIGH
> +	 }};
> +   ioctl(fd, CAIF_IOC_CONFIG_DEVICE,&at_config);
> +   close(fd);
> + * \endcode
> + * This will cause a new AT channel to be available in at "/dev/chnl2".
> + * This CAIF channel can then be connected by using \ref open.
> + */

This is obsolete,too.

> +/* Specifies the type of device to create: NET device or CHAR device*/
> +enum caif_dev_type {
> +	CAIF_DEV_CHR = 1,
> +	CAIF_DEV_NET = 2
> +};

You can remove this enum, it is not used anymore in your code.

> +
> +/** Used for identifying devices, PHY interfaces, etc.*/
> +struct caif_device_name {
> +	char name[DEVICE_NAME_LEN];	/*!< Device name */
> +	enum caif_dev_type devtype;	/*!< Device type */
> +};

I think this one is obsolete, too.

> +/* TODO: Move these defs to /usr/include/linux/socket.h */
> +#define AF_CAIF    37 		/* CAIF Socket Address Family */
> +#define PF_CAIF    37           /* CAIF Socket Protocol Family */
> +#define SOL_CAIF   278		/* CAIF Socket Option Level */

You sent already a patch for socket.h, I think you can safely remove
these duplicates.

> +
> +#define CAIF_DEFAULT_PRI       0xf

You have already defined CAIF_PRIO_NORMAL with the same value. Do you
need both ?

> +enum caif_link_selector {
> +	CAIF_LINK_UNSPECIFIED	= 0x00,
> +	CAIF_LINK_LOW_LATENCY	= 0xd0,
> +	CAIF_LINK_HIGH_BANDW	= 0xe0

caif_phy_preference and caif_link_selector have the same values for
priority. Should we have a single enum for both ?

Stefano

-- 
stefano <stefano.babic@babic.homelinux.org>
GPG Key: 0x55814DDE
Fingerprint 4E85 2A66 4CBA 497A 2A7B D3BF 5973 F216 5581 4DDE

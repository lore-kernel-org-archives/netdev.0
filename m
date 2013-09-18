From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 002/007] WAN Drivers: Update farsync driver and
 introduce fsflex driver
Date: Wed, 18 Sep 2013 16:30:32 +0100
Message-ID: <1379518232.1522.15.camel@bwh-desktop.uk.level5networks.com>
References: <E603DC592C92B54A89CEF6B0919A0B1CAAAA787DA1@SOLO.hq.farsitecommunications.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
	"Dermot Smith" <dermot.smith@farsite.com>
To: Kevin Curtis <Kevin.Curtis@farsite.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <E603DC592C92B54A89CEF6B0919A0B1CAAAA787DA1@SOLO.hq.farsitecommunications.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-09-18 at 11:11 +0100, Kevin Curtis wrote:
> Farsite Communications FarSync driver update
> 
> Patch 2 of 7
> 
> Introduce a new include file required by the fsflex driver.
> 
> Signed-off-by: Kevin Curtis <kevin.curtis@farsite.com>
> 
> ---
> 
> diff -uprN -X linux-3.10.1/Documentation/dontdiff linux-3.10.1/drivers/net/wan/uss_cmn.h linux-3.10.1_new/drivers/net/wan/uss_cmn.h
> --- linux-3.10.1/drivers/net/wan/uss_cmn.h      1970-01-01 01:00:00.000000000 +0100
> +++ linux-3.10.1_new/drivers/net/wan/uss_cmn.h  2013-08-30 11:30:36.766167447 +0100
> @@ -0,0 +1,492 @@
> +/*
> + *      FarSync driver for Linux
> + *
> + *      Copyright (C) 2001-2013 FarSite Communications Ltd.
> + *      www.farsite.com
> + *
> + *      This program is free software; you can redistribute it and/or
> + *      modify it under the terms of the GNU General Public License
> + *      as published by the Free Software Foundation; either version
> + *      2 of the License, or (at your option) any later version.
> + *
> + * File        : uss_cmn.h
> + *
> + * Description : FarSync Flex common header file, shared between oncard code
> + *               and Windows and Linux drivers.
> + *
> + *               NOTE: all parameters are in Little Endian format

Then they should be declared as __le32 or similar.

[...]
> +typedef enum _USS_COMMANDS 
[...]
> +} USS_COMMANDS;

Adding typedefs for user-defined types is deprecated.  And please use
lower-case type names.

[...]
> +/*****************************************************************************/
> +/* InterfaceRecord definition                                                */
> +/*                                                                           */
> +/* For use with:                                                             */
> +/*                                                                           */
> +/*   IoctlCodeReadInterfaceRecord,                                           */
> +/*   IoctlCodeFarSyncReadInterfaceRecord                                     */
> +/*                                                                           */
> +/*****************************************************************************/
> +typedef struct _INTERFACE_RECORD {
> +       int rx_frame_count;     /* incremented after each frame rx'd */
> +       int tx_max_fr_size_now; /* max available frame size av. now  */
> +       /* (changes after each Tx DevIoctl   */
> +       /* to DD or after Tx completed)      */
> +       int status_count;       /* How many status events have been  */
> +       /* triggered.                        */
> +       u8 v24_in;              /* Last 'getv24 i/p' value got       */
> +       u8 v24_out;             /* Last 'setv24 o/p' value set       */
[...]

I think explicit padding is needed between v24_out and status_array.
Not all architectures require 32-bit words to be 32-bit aligned.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

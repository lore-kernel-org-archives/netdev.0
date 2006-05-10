From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 3/6] myri10ge - Driver header files
Date: Thu, 11 May 2006 00:02:23 +0200
Message-ID: <20060510220223.GB25334@electric-eye.fr.zoreil.com>
References: <446259A0.8050504@myri.com> <44625CD2.8040100@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@osdl.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"Andrew J. Gallatin" <gallatin@myri.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965033AbWEJWDf@vger.kernel.org>
To: Brice Goglin <brice@myri.com>
Content-Disposition: inline
In-Reply-To: <44625CD2.8040100@myri.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brice Goglin <brice@myri.com> :
> [PATCH 3/6] myri10ge - Driver header files
> 
> myri10ge driver header files.
> myri10ge_mcp.h is the generic header, while myri10ge_mcp_gen_header.h
> is automatically generated from our firmware image.
> 
> Signed-off-by: Brice Goglin <brice@myri.com>
> Signed-off-by: Andrew J. Gallatin <gallatin@myri.com>
> 
>  myri10ge_mcp.h            |  233 ++++++++++++++++++++++++++++++++++++++++++++++
>  myri10ge_mcp_gen_header.h |   73 ++++++++++++++
>  2 files changed, 306 insertions(+)
> 
> --- /dev/null	2006-04-21 00:45:09.064430000 -0700
> +++ linux-mm/drivers/net/myri10ge/myri10ge_mcp.h	2006-04-21 08:20:59.000000000 -0700
> @@ -0,0 +1,233 @@
> +#ifndef _myri10ge_mcp_h
> +#define _myri10ge_mcp_h

Uppercase please.

[...]
> +#ifdef MYRI10GE_MCP
> +typedef signed char          int8_t;
> +typedef signed short        int16_t;
> +typedef signed int          int32_t;
> +typedef signed long long    int64_t;
> +typedef unsigned char       uint8_t;
> +typedef unsigned short     uint16_t;
> +typedef unsigned int       uint32_t;
> +typedef unsigned long long uint64_t;
> +#endif

Bloat. u8/u16/u32 and friends should be used instead.

> +/* 8 Bytes */
> +typedef struct
> +{
> +  uint32_t high;
> +  uint32_t low;
> +} mcp_dma_addr_t;

Typedef are frowned upon.

[...]
> +/* 32 Bytes */

The struct takes 40 bytes. Does it need a 32 bytes alignment or such ?

> +typedef struct
> +{
> +  uint32_t send_done_count;
> +
> +  uint32_t link_up;
> +  uint32_t dropped_link_overflow;
> +  uint32_t dropped_link_error_or_filtered;
> +  uint32_t dropped_runt;
> +  uint32_t dropped_overrun;
> +  uint32_t dropped_no_small_buffer;
> +  uint32_t dropped_no_big_buffer;
> +  uint32_t rdma_tags_available;
> +
> +  uint8_t tx_stopped;
> +  uint8_t link_down;
> +  uint8_t stats_updated;
> +  uint8_t valid;
> +} mcp_irq_data_t;
> +
> +

-- 
Ueimor

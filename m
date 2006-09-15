From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: Re: [PATCH 2.6.18-rc7 6/9] NetXen: Main header file
Date: Fri, 15 Sep 2006 12:41:11 -0700
Message-ID: <20060915124111.3a3680ad.rdunlap@xenotime.net>
References: <Pine.LNX.4.64.0609151124560.7710@dut39>
	<Pine.LNX.4.64.0609151148580.7710@dut39>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Sanjeev Jorapur <sanjeev@netxen.com>,
	Rob Mapes <rob@netxen.com>, unmproj@linsyssoft.com,
	brazilnut@us.ibm.com, wendyx@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:59573 "HELO xenotime.net")
	by vger.kernel.org with SMTP id S1751513AbWIOTj6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Sep 2006 15:39:58 -0400
Received: from midway.site ([71.117.233.155]) by xenotime.net for <netdev@vger.kernel.org>; Fri, 15 Sep 2006 12:39:56 -0700
To: "Amit S. Kale" <amitkale@netxen.com>
In-Reply-To: <Pine.LNX.4.64.0609151148580.7710@dut39>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 15 Sep 2006 11:51:46 -0700 (PDT) Amit S. Kale wrote:

> diff -Narup -X linux-2.6.18-rc7.orig/Documentation/dontdiff linux-2.6.18-rc7.orig/drivers/net/netxen/netxen_nic.h linux-2.6.18-rc7/drivers/net/netxen/netxen_nic.h
> --- linux-2.6.18-rc7.orig/drivers/net/netxen/netxen_nic.h	1969-12-31 16:00:00.000000000 -0800
> +++ linux-2.6.18-rc7/drivers/net/netxen/netxen_nic.h	2006-09-15 10:51:59.000000000 -0700

> +#include <linux/config.h>
> +#include <linux/module.h>
> +#include <linux/kernel.h>
> +#include <linux/types.h>
> +#include <linux/compiler.h>
> +#include <linux/slab.h>
> +#include <linux/delay.h>
> +#include <linux/init.h>
> +#include <linux/ioport.h>
> +#include <linux/pci.h>
> +#include <linux/netdevice.h>
> +#include <linux/etherdevice.h>
> +#include <linux/ip.h>
> +#include <linux/in.h>
> +#include <linux/tcp.h>
> +#include <linux/skbuff.h>
> +#include <linux/version.h>
> +
> +#include <linux/ethtool.h>
> +#include <linux/mii.h>
> +#include <linux/interrupt.h>
> +#include <linux/timer.h>
> +
> +#include <linux/mm.h>
> +#include <linux/mman.h>
> +
> +#include <asm/system.h>
> +#include <asm/io.h>
> +#include <asm/byteorder.h>
> +#include <asm/uaccess.h>
> +#include <asm/pgtable.h>
> +
> +#include <linux/skbuff.h>

This one is already #included above.

> +#include "netxen_nic_hw.h"
> +
> +#define NETXEN_NIC_BUILD_NO     "232"
> +#define _NETXEN_NIC_LINUX_MAJOR 2
> +#define _NETXEN_NIC_LINUX_MINOR 3
> +#define _NETXEN_NIC_LINUX_SUBVERSION 57
> +#define NETXEN_NIC_LINUX_VERSIONID  "2.3.57"
> +#define NETXEN_NIC_FW_VERSIONID "2.3.57"

> +#define MAX_CMD_DESCRIPTORS		1024
> +#define MAX_RCV_DESCRIPTORS		32768
> +#define MAX_JUMBO_RCV_DESCRIPTORS	1024
> +#define MAX_RCVSTATUS_DESCRIPTORS	MAX_RCV_DESCRIPTORS
> +#define MAX_JUMBO_RCV_DESC	MAX_JUMBO_RCV_DESCRIPTORS
> +#define MAX_RCV_DESC		MAX_RCV_DESCRIPTORS
> +#define MAX_RCVSTATUS_DESC	MAX_RCV_DESCRIPTORS
> +#define NUM_RCV_DESC		(MAX_RCV_DESC + MAX_JUMBO_RCV_DESCRIPTORS)
> +#define MAX_EPG_DESCRIPTORS	MAX_CMD_DESCRIPTORS * 8

Parentheses around the expression above, please.

> +/**
> + * Following data structures describe the descriptors that will be used.
> + * Added fileds of tcpHdrSize and ipHdrSize, The driver needs to do it only when
> + * we are doing LSO (above the 1500 size packet) only.
> + **/

Please don't use "/**" for any comments other than kernel-doc
formatted comments.

> +/**
> + * The size of reference handle been changed to 16 bits to pass the MSS fields
> + * for the LSO packet
> + **/

Drop the "_t" on struct names (here and elsewhere).

> +struct cmd_desc_type0_t {
> +	u64 netxen_next;	/* for fragments handled by Phantom */
> +	union {
> +		struct {
> +			u32 addr_low_part2;
> +			u32 addr_high_part2;
> +		};
> +		u64 addr_buffer2;
> +	};

> +/* this structure by all ports on the adapter */

eh?

---
~Randy

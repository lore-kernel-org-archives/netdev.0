From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH 13/14] Move usbnet.h and rndis_host.h to include/linux/usb
Date: Sun, 27 Jan 2008 08:36:15 -0800
Message-ID: <200801270836.16156.david-b@pacbell.net>
References: <20080125225032.11716.77713.stgit@fate.lan> <20080125225145.11716.68993.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	bjd@jooz.net
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp116.sbc.mail.sp1.yahoo.com ([69.147.64.89]:22641 "HELO
	smtp116.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751101AbYA0QgT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jan 2008 11:36:19 -0500
In-Reply-To: <20080125225145.11716.68993.stgit@fate.lan>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 25 January 2008, Jussi Kivilinna wrote:
> Move headers usbnet.h and rndis_host.h to include/linux/usb and fix includes
> for drivers/net/usb modules. Headers are moved because rndis_wlan will be
> outside drivers/net/usb in drivers/net/wireless and yet need these headers.
> 
> Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>

Acked-by: David Brownell <dbrownell@users.sourceforge.net>

> ---
> 
>  drivers/net/usb/asix.c         |    3 
>  drivers/net/usb/cdc_ether.c    |    3 
>  drivers/net/usb/cdc_subset.c   |    3 
>  drivers/net/usb/dm9601.c       |    3 
>  drivers/net/usb/gl620a.c       |    3 
>  drivers/net/usb/mcs7830.c      |    3 
>  drivers/net/usb/net1080.c      |    3 
>  drivers/net/usb/plusb.c        |    3 
>  drivers/net/usb/rndis_host.c   |    5 -
>  drivers/net/usb/rndis_host.h   |  274 ----------------------------------------
>  drivers/net/usb/usbnet.c       |    3 
>  drivers/net/usb/usbnet.h       |  214 -------------------------------
>  drivers/net/usb/zaurus.c       |    3 
>  include/linux/usb/rndis_host.h |  274 ++++++++++++++++++++++++++++++++++++++++
>  include/linux/usb/usbnet.h     |  214 +++++++++++++++++++++++++++++++
>  15 files changed, 500 insertions(+), 511 deletions(-)
> 
> diff --git a/drivers/net/usb/asix.c b/drivers/net/usb/asix.c
> index 569028b..6f245cf 100644
> --- a/drivers/net/usb/asix.c
> +++ b/drivers/net/usb/asix.c
> @@ -33,8 +33,7 @@
>  #include <linux/mii.h>
>  #include <linux/usb.h>
>  #include <linux/crc32.h>
> -
> -#include "usbnet.h"
> +#include <linux/usb/usbnet.h>
>  
>  #define DRIVER_VERSION "14-Jun-2006"
>  static const char driver_name [] = "asix";
> diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
> index 97c17bb..a934428 100644
> --- a/drivers/net/usb/cdc_ether.c
> +++ b/drivers/net/usb/cdc_ether.c
> @@ -31,8 +31,7 @@
>  #include <linux/mii.h>
>  #include <linux/usb.h>
>  #include <linux/usb/cdc.h>
> -
> -#include "usbnet.h"
> +#include <linux/usb/usbnet.h>
>  
>  
>  #if defined(CONFIG_USB_NET_RNDIS_HOST) || defined(CONFIG_USB_NET_RNDIS_HOST_MODULE)
> diff --git a/drivers/net/usb/cdc_subset.c b/drivers/net/usb/cdc_subset.c
> index 943988e..0ec7936 100644
> --- a/drivers/net/usb/cdc_subset.c
> +++ b/drivers/net/usb/cdc_subset.c
> @@ -26,8 +26,7 @@
>  #include <linux/workqueue.h>
>  #include <linux/mii.h>
>  #include <linux/usb.h>
> -
> -#include "usbnet.h"
> +#include <linux/usb/usbnet.h>
>  
>  
>  /*
> diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
> index 1ffdd10..5a4e40c 100644
> --- a/drivers/net/usb/dm9601.c
> +++ b/drivers/net/usb/dm9601.c
> @@ -20,8 +20,7 @@
>  #include <linux/mii.h>
>  #include <linux/usb.h>
>  #include <linux/crc32.h>
> -
> -#include "usbnet.h"
> +#include <linux/usb/usbnet.h>
>  
>  /* datasheet:
>   http://www.davicom.com.tw/big5/download/Data%20Sheet/DM9601-DS-P01-930914.pdf
> diff --git a/drivers/net/usb/gl620a.c b/drivers/net/usb/gl620a.c
> index 031cf5c..f7ccfad 100644
> --- a/drivers/net/usb/gl620a.c
> +++ b/drivers/net/usb/gl620a.c
> @@ -29,8 +29,7 @@
>  #include <linux/workqueue.h>
>  #include <linux/mii.h>
>  #include <linux/usb.h>
> -
> -#include "usbnet.h"
> +#include <linux/usb/usbnet.h>
>  
>  
>  /*
> diff --git a/drivers/net/usb/mcs7830.c b/drivers/net/usb/mcs7830.c
> index 5ea7411..c3d119f 100644
> --- a/drivers/net/usb/mcs7830.c
> +++ b/drivers/net/usb/mcs7830.c
> @@ -31,8 +31,7 @@
>  #include <linux/module.h>
>  #include <linux/netdevice.h>
>  #include <linux/usb.h>
> -
> -#include "usbnet.h"
> +#include <linux/usb/usbnet.h>
>  
>  /* requests */
>  #define MCS7830_RD_BMREQ	(USB_DIR_IN  | USB_TYPE_VENDOR | \
> diff --git a/drivers/net/usb/net1080.c b/drivers/net/usb/net1080.c
> index 19bf8da..034e8a7 100644
> --- a/drivers/net/usb/net1080.c
> +++ b/drivers/net/usb/net1080.c
> @@ -28,11 +28,10 @@
>  #include <linux/workqueue.h>
>  #include <linux/mii.h>
>  #include <linux/usb.h>
> +#include <linux/usb/usbnet.h>
>  
>  #include <asm/unaligned.h>
>  
> -#include "usbnet.h"
> -
>  
>  /*
>   * Netchip 1080 driver ... http://www.netchip.com
> diff --git a/drivers/net/usb/plusb.c b/drivers/net/usb/plusb.c
> index 4530093..08555f8 100644
> --- a/drivers/net/usb/plusb.c
> +++ b/drivers/net/usb/plusb.c
> @@ -28,8 +28,7 @@
>  #include <linux/workqueue.h>
>  #include <linux/mii.h>
>  #include <linux/usb.h>
> -
> -#include "usbnet.h"
> +#include <linux/usb/usbnet.h>
>  
>  
>  /*
> diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
> index 825ff51..411314e 100644
> --- a/drivers/net/usb/rndis_host.c
> +++ b/drivers/net/usb/rndis_host.c
> @@ -29,9 +29,8 @@
>  #include <linux/mii.h>
>  #include <linux/usb.h>
>  #include <linux/usb/cdc.h>
> -
> -#include "usbnet.h"
> -#include "rndis_host.h"
> +#include <linux/usb/usbnet.h>
> +#include <linux/usb/rndis_host.h>
>  
>  
>  /*
> diff --git a/drivers/net/usb/rndis_host.h b/drivers/net/usb/rndis_host.h
> deleted file mode 100644
> index edc1d4a..0000000
> --- a/drivers/net/usb/rndis_host.h
> +++ /dev/null
> @@ -1,274 +0,0 @@
> -/*
> - * Host Side support for RNDIS Networking Links
> - * Copyright (C) 2005 by David Brownell
> - *
> - * This program is free software; you can redistribute it and/or modify
> - * it under the terms of the GNU General Public License as published by
> - * the Free Software Foundation; either version 2 of the License, or
> - * (at your option) any later version.
> - *
> - * This program is distributed in the hope that it will be useful,
> - * but WITHOUT ANY WARRANTY; without even the implied warranty of
> - * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> - * GNU General Public License for more details.
> - *
> - * You should have received a copy of the GNU General Public License
> - * along with this program; if not, write to the Free Software
> - * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
> - */
> -
> -
> -#ifndef	__RNDIS_HOST_H
> -#define	__RNDIS_HOST_H
> -
> -
> -/*
> - * CONTROL uses CDC "encapsulated commands" with funky notifications.
> - *  - control-out:  SEND_ENCAPSULATED
> - *  - interrupt-in:  RESPONSE_AVAILABLE
> - *  - control-in:  GET_ENCAPSULATED
> - *
> - * We'll try to ignore the RESPONSE_AVAILABLE notifications.
> - *
> - * REVISIT some RNDIS implementations seem to have curious issues still
> - * to be resolved.
> - */
> -struct rndis_msg_hdr {
> -	__le32	msg_type;			/* RNDIS_MSG_* */
> -	__le32	msg_len;
> -	// followed by data that varies between messages
> -	__le32	request_id;
> -	__le32	status;
> -	// ... and more
> -} __attribute__ ((packed));
> -
> -/* MS-Windows uses this strange size, but RNDIS spec says 1024 minimum */
> -#define	CONTROL_BUFFER_SIZE		1025
> -
> -/* RNDIS defines an (absurdly huge) 10 second control timeout,
> - * but ActiveSync seems to use a more usual 5 second timeout
> - * (which matches the USB 2.0 spec).
> - */
> -#define	RNDIS_CONTROL_TIMEOUT_MS	(5 * 1000)
> -
> -
> -#define ccpu2 __constant_cpu_to_le32
> -
> -#define RNDIS_MSG_COMPLETION	ccpu2(0x80000000)
> -
> -/* codes for "msg_type" field of rndis messages;
> - * only the data channel uses packet messages (maybe batched);
> - * everything else goes on the control channel.
> - */
> -#define RNDIS_MSG_PACKET	ccpu2(0x00000001)	/* 1-N packets */
> -#define RNDIS_MSG_INIT		ccpu2(0x00000002)
> -#define RNDIS_MSG_INIT_C	(RNDIS_MSG_INIT|RNDIS_MSG_COMPLETION)
> -#define RNDIS_MSG_HALT		ccpu2(0x00000003)
> -#define RNDIS_MSG_QUERY		ccpu2(0x00000004)
> -#define RNDIS_MSG_QUERY_C	(RNDIS_MSG_QUERY|RNDIS_MSG_COMPLETION)
> -#define RNDIS_MSG_SET		ccpu2(0x00000005)
> -#define RNDIS_MSG_SET_C		(RNDIS_MSG_SET|RNDIS_MSG_COMPLETION)
> -#define RNDIS_MSG_RESET		ccpu2(0x00000006)
> -#define RNDIS_MSG_RESET_C	(RNDIS_MSG_RESET|RNDIS_MSG_COMPLETION)
> -#define RNDIS_MSG_INDICATE	ccpu2(0x00000007)
> -#define RNDIS_MSG_KEEPALIVE	ccpu2(0x00000008)
> -#define RNDIS_MSG_KEEPALIVE_C	(RNDIS_MSG_KEEPALIVE|RNDIS_MSG_COMPLETION)
> -
> -/* codes for "status" field of completion messages */
> -#define	RNDIS_STATUS_SUCCESS		ccpu2(0x00000000)
> -#define	RNDIS_STATUS_FAILURE		ccpu2(0xc0000001)
> -#define	RNDIS_STATUS_INVALID_DATA	ccpu2(0xc0010015)
> -#define	RNDIS_STATUS_NOT_SUPPORTED	ccpu2(0xc00000bb)
> -#define	RNDIS_STATUS_MEDIA_CONNECT	ccpu2(0x4001000b)
> -#define	RNDIS_STATUS_MEDIA_DISCONNECT	ccpu2(0x4001000c)
> -
> -/* codes for OID_GEN_PHYSICAL_MEDIUM */
> -#define	RNDIS_PHYSICAL_MEDIUM_UNSPECIFIED	ccpu2(0x00000000)
> -#define	RNDIS_PHYSICAL_MEDIUM_WIRELESS_LAN	ccpu2(0x00000001)
> -#define	RNDIS_PHYSICAL_MEDIUM_CABLE_MODEM	ccpu2(0x00000002)
> -#define	RNDIS_PHYSICAL_MEDIUM_PHONE_LINE	ccpu2(0x00000003)
> -#define	RNDIS_PHYSICAL_MEDIUM_POWER_LINE	ccpu2(0x00000004)
> -#define	RNDIS_PHYSICAL_MEDIUM_DSL		ccpu2(0x00000005)
> -#define	RNDIS_PHYSICAL_MEDIUM_FIBRE_CHANNEL	ccpu2(0x00000006)
> -#define	RNDIS_PHYSICAL_MEDIUM_1394		ccpu2(0x00000007)
> -#define	RNDIS_PHYSICAL_MEDIUM_WIRELESS_WAN	ccpu2(0x00000008)
> -#define	RNDIS_PHYSICAL_MEDIUM_MAX		ccpu2(0x00000009)
> -
> -struct rndis_data_hdr {
> -	__le32	msg_type;		/* RNDIS_MSG_PACKET */
> -	__le32	msg_len;		// rndis_data_hdr + data_len + pad
> -	__le32	data_offset;		// 36 -- right after header
> -	__le32	data_len;		// ... real packet size
> -
> -	__le32	oob_data_offset;	// zero
> -	__le32	oob_data_len;		// zero
> -	__le32	num_oob;		// zero
> -	__le32	packet_data_offset;	// zero
> -
> -	__le32	packet_data_len;	// zero
> -	__le32	vc_handle;		// zero
> -	__le32	reserved;		// zero
> -} __attribute__ ((packed));
> -
> -struct rndis_init {		/* OUT */
> -	// header and:
> -	__le32	msg_type;			/* RNDIS_MSG_INIT */
> -	__le32	msg_len;			// 24
> -	__le32	request_id;
> -	__le32	major_version;			// of rndis (1.0)
> -	__le32	minor_version;
> -	__le32	max_transfer_size;
> -} __attribute__ ((packed));
> -
> -struct rndis_init_c {		/* IN */
> -	// header and:
> -	__le32	msg_type;			/* RNDIS_MSG_INIT_C */
> -	__le32	msg_len;
> -	__le32	request_id;
> -	__le32	status;
> -	__le32	major_version;			// of rndis (1.0)
> -	__le32	minor_version;
> -	__le32	device_flags;
> -	__le32	medium;				// zero == 802.3
> -	__le32	max_packets_per_message;
> -	__le32	max_transfer_size;
> -	__le32	packet_alignment;		// max 7; (1<<n) bytes
> -	__le32	af_list_offset;			// zero
> -	__le32	af_list_size;			// zero
> -} __attribute__ ((packed));
> -
> -struct rndis_halt {		/* OUT (no reply) */
> -	// header and:
> -	__le32	msg_type;			/* RNDIS_MSG_HALT */
> -	__le32	msg_len;
> -	__le32	request_id;
> -} __attribute__ ((packed));
> -
> -struct rndis_query {		/* OUT */
> -	// header and:
> -	__le32	msg_type;			/* RNDIS_MSG_QUERY */
> -	__le32	msg_len;
> -	__le32	request_id;
> -	__le32	oid;
> -	__le32	len;
> -	__le32	offset;
> -/*?*/	__le32	handle;				// zero
> -} __attribute__ ((packed));
> -
> -struct rndis_query_c {		/* IN */
> -	// header and:
> -	__le32	msg_type;			/* RNDIS_MSG_QUERY_C */
> -	__le32	msg_len;
> -	__le32	request_id;
> -	__le32	status;
> -	__le32	len;
> -	__le32	offset;
> -} __attribute__ ((packed));
> -
> -struct rndis_set {		/* OUT */
> -	// header and:
> -	__le32	msg_type;			/* RNDIS_MSG_SET */
> -	__le32	msg_len;
> -	__le32	request_id;
> -	__le32	oid;
> -	__le32	len;
> -	__le32	offset;
> -/*?*/	__le32	handle;				// zero
> -} __attribute__ ((packed));
> -
> -struct rndis_set_c {		/* IN */
> -	// header and:
> -	__le32	msg_type;			/* RNDIS_MSG_SET_C */
> -	__le32	msg_len;
> -	__le32	request_id;
> -	__le32	status;
> -} __attribute__ ((packed));
> -
> -struct rndis_reset {		/* IN */
> -	// header and:
> -	__le32	msg_type;			/* RNDIS_MSG_RESET */
> -	__le32	msg_len;
> -	__le32	reserved;
> -} __attribute__ ((packed));
> -
> -struct rndis_reset_c {		/* OUT */
> -	// header and:
> -	__le32	msg_type;			/* RNDIS_MSG_RESET_C */
> -	__le32	msg_len;
> -	__le32	status;
> -	__le32	addressing_lost;
> -} __attribute__ ((packed));
> -
> -struct rndis_indicate {		/* IN (unrequested) */
> -	// header and:
> -	__le32	msg_type;			/* RNDIS_MSG_INDICATE */
> -	__le32	msg_len;
> -	__le32	status;
> -	__le32	length;
> -	__le32	offset;
> -/**/	__le32	diag_status;
> -	__le32	error_offset;
> -/**/	__le32	message;
> -} __attribute__ ((packed));
> -
> -struct rndis_keepalive {	/* OUT (optionally IN) */
> -	// header and:
> -	__le32	msg_type;			/* RNDIS_MSG_KEEPALIVE */
> -	__le32	msg_len;
> -	__le32	request_id;
> -} __attribute__ ((packed));
> -
> -struct rndis_keepalive_c {	/* IN (optionally OUT) */
> -	// header and:
> -	__le32	msg_type;			/* RNDIS_MSG_KEEPALIVE_C */
> -	__le32	msg_len;
> -	__le32	request_id;
> -	__le32	status;
> -} __attribute__ ((packed));
> -
> -/* NOTE:  about 30 OIDs are "mandatory" for peripherals to support ... and
> - * there are gobs more that may optionally be supported.  We'll avoid as much
> - * of that mess as possible.
> - */
> -#define OID_802_3_PERMANENT_ADDRESS	ccpu2(0x01010101)
> -#define OID_GEN_MAXIMUM_FRAME_SIZE	ccpu2(0x00010106)
> -#define OID_GEN_CURRENT_PACKET_FILTER	ccpu2(0x0001010e)
> -#define OID_GEN_PHYSICAL_MEDIUM		ccpu2(0x00010202)
> -
> -/* packet filter bits used by OID_GEN_CURRENT_PACKET_FILTER */
> -#define RNDIS_PACKET_TYPE_DIRECTED		ccpu2(0x00000001)
> -#define RNDIS_PACKET_TYPE_MULTICAST		ccpu2(0x00000002)
> -#define RNDIS_PACKET_TYPE_ALL_MULTICAST		ccpu2(0x00000004)
> -#define RNDIS_PACKET_TYPE_BROADCAST		ccpu2(0x00000008)
> -#define RNDIS_PACKET_TYPE_SOURCE_ROUTING	ccpu2(0x00000010)
> -#define RNDIS_PACKET_TYPE_PROMISCUOUS		ccpu2(0x00000020)
> -#define RNDIS_PACKET_TYPE_SMT			ccpu2(0x00000040)
> -#define RNDIS_PACKET_TYPE_ALL_LOCAL		ccpu2(0x00000080)
> -#define RNDIS_PACKET_TYPE_GROUP			ccpu2(0x00001000)
> -#define RNDIS_PACKET_TYPE_ALL_FUNCTIONAL	ccpu2(0x00002000)
> -#define RNDIS_PACKET_TYPE_FUNCTIONAL		ccpu2(0x00004000)
> -#define RNDIS_PACKET_TYPE_MAC_FRAME		ccpu2(0x00008000)
> -
> -/* default filter used with RNDIS devices */
> -#define RNDIS_DEFAULT_FILTER ( \
> -	RNDIS_PACKET_TYPE_DIRECTED | \
> -	RNDIS_PACKET_TYPE_BROADCAST | \
> -	RNDIS_PACKET_TYPE_ALL_MULTICAST | \
> -	RNDIS_PACKET_TYPE_PROMISCUOUS)
> -
> -/* Flags to require specific physical medium type for generic_rndis_bind() */
> -#define FLAG_RNDIS_PHYM_NOT_WIRELESS	0x0001
> -#define FLAG_RNDIS_PHYM_WIRELESS	0x0002
> -
> -
> -extern void rndis_status(struct usbnet *dev, struct urb *urb);
> -extern int rndis_command(struct usbnet *dev, struct rndis_msg_hdr *buf);
> -extern int
> -generic_rndis_bind(struct usbnet *dev, struct usb_interface *intf, int flags);
> -extern void rndis_unbind(struct usbnet *dev, struct usb_interface *intf);
> -extern int rndis_rx_fixup(struct usbnet *dev, struct sk_buff *skb);
> -extern struct sk_buff *
> -rndis_tx_fixup(struct usbnet *dev, struct sk_buff *skb, gfp_t flags);
> -
> -#endif	/* __RNDIS_HOST_H */
> -
> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
> index a2a2d5e..8463efb 100644
> --- a/drivers/net/usb/usbnet.c
> +++ b/drivers/net/usb/usbnet.c
> @@ -41,8 +41,7 @@
>  #include <linux/workqueue.h>
>  #include <linux/mii.h>
>  #include <linux/usb.h>
> -
> -#include "usbnet.h"
> +#include <linux/usb/usbnet.h>
>  
>  #define DRIVER_VERSION		"22-Aug-2005"
>  
> diff --git a/drivers/net/usb/usbnet.h b/drivers/net/usb/usbnet.h
> deleted file mode 100644
> index e0501da..0000000
> --- a/drivers/net/usb/usbnet.h
> +++ /dev/null
> @@ -1,214 +0,0 @@
> -/*
> - * USB Networking Link Interface
> - *
> - * Copyright (C) 2000-2005 by David Brownell <dbrownell@users.sourceforge.net>
> - * Copyright (C) 2003-2005 David Hollis <dhollis@davehollis.com>
> - *
> - * This program is free software; you can redistribute it and/or modify
> - * it under the terms of the GNU General Public License as published by
> - * the Free Software Foundation; either version 2 of the License, or
> - * (at your option) any later version.
> - *
> - * This program is distributed in the hope that it will be useful,
> - * but WITHOUT ANY WARRANTY; without even the implied warranty of
> - * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> - * GNU General Public License for more details.
> - *
> - * You should have received a copy of the GNU General Public License
> - * along with this program; if not, write to the Free Software
> - * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
> - */
> -
> -
> -#ifndef	__USBNET_H
> -#define	__USBNET_H
> -
> -
> -/* interface from usbnet core to each USB networking link we handle */
> -struct usbnet {
> -	/* housekeeping */
> -	struct usb_device	*udev;
> -	struct usb_interface	*intf;
> -	struct driver_info	*driver_info;
> -	const char		*driver_name;
> -	void			*driver_priv;
> -	wait_queue_head_t	*wait;
> -	struct mutex		phy_mutex;
> -	unsigned char		suspend_count;
> -
> -	/* i/o info: pipes etc */
> -	unsigned		in, out;
> -	struct usb_host_endpoint *status;
> -	unsigned		maxpacket;
> -	struct timer_list	delay;
> -
> -	/* protocol/interface state */
> -	struct net_device	*net;
> -	struct net_device_stats	stats;
> -	int			msg_enable;
> -	unsigned long		data [5];
> -	u32			xid;
> -	u32			hard_mtu;	/* count any extra framing */
> -	size_t			rx_urb_size;	/* size for rx urbs */
> -	struct mii_if_info	mii;
> -
> -	/* various kinds of pending driver work */
> -	struct sk_buff_head	rxq;
> -	struct sk_buff_head	txq;
> -	struct sk_buff_head	done;
> -	struct urb		*interrupt;
> -	struct tasklet_struct	bh;
> -
> -	struct work_struct	kevent;
> -	unsigned long		flags;
> -#		define EVENT_TX_HALT	0
> -#		define EVENT_RX_HALT	1
> -#		define EVENT_RX_MEMORY	2
> -#		define EVENT_STS_SPLIT	3
> -#		define EVENT_LINK_RESET	4
> -};
> -
> -static inline struct usb_driver *driver_of(struct usb_interface *intf)
> -{
> -	return to_usb_driver(intf->dev.driver);
> -}
> -
> -/* interface from the device/framing level "minidriver" to core */
> -struct driver_info {
> -	char		*description;
> -
> -	int		flags;
> -/* framing is CDC Ethernet, not writing ZLPs (hw issues), or optionally: */
> -#define FLAG_FRAMING_NC	0x0001		/* guard against device dropouts */
> -#define FLAG_FRAMING_GL	0x0002		/* genelink batches packets */
> -#define FLAG_FRAMING_Z	0x0004		/* zaurus adds a trailer */
> -#define FLAG_FRAMING_RN	0x0008		/* RNDIS batches, plus huge header */
> -
> -#define FLAG_NO_SETINT	0x0010		/* device can't set_interface() */
> -#define FLAG_ETHER	0x0020		/* maybe use "eth%d" names */
> -
> -#define FLAG_FRAMING_AX 0x0040		/* AX88772/178 packets */
> -#define FLAG_WLAN	0x0080		/* use "wlan%d" names */
> -
> -
> -	/* init device ... can sleep, or cause probe() failure */
> -	int	(*bind)(struct usbnet *, struct usb_interface *);
> -
> -	/* cleanup device ... can sleep, but can't fail */
> -	void	(*unbind)(struct usbnet *, struct usb_interface *);
> -
> -	/* reset device ... can sleep */
> -	int	(*reset)(struct usbnet *);
> -
> -	/* see if peer is connected ... can sleep */
> -	int	(*check_connect)(struct usbnet *);
> -
> -	/* for status polling */
> -	void	(*status)(struct usbnet *, struct urb *);
> -
> -	/* link reset handling, called from defer_kevent */
> -	int	(*link_reset)(struct usbnet *);
> -
> -	/* fixup rx packet (strip framing) */
> -	int	(*rx_fixup)(struct usbnet *dev, struct sk_buff *skb);
> -
> -	/* fixup tx packet (add framing) */
> -	struct sk_buff	*(*tx_fixup)(struct usbnet *dev,
> -				struct sk_buff *skb, gfp_t flags);
> -
> -	/* early initialization code, can sleep. This is for minidrivers
> -	 * having 'subminidrivers' that need to do extra initialization
> -	 * right after minidriver have initialized hardware. */
> -	int	(*early_init)(struct usbnet *dev);
> -
> -	/* called by minidriver when link state changes, state: 0=disconnect,
> -	 * 1=connect */
> -	void	(*link_change)(struct usbnet *dev, int state);
> -
> -	/* for new devices, use the descriptor-reading code instead */
> -	int		in;		/* rx endpoint */
> -	int		out;		/* tx endpoint */
> -
> -	unsigned long	data;		/* Misc driver specific data */
> -};
> -
> -/* Minidrivers are just drivers using the "usbnet" core as a powerful
> - * network-specific subroutine library ... that happens to do pretty
> - * much everything except custom framing and chip-specific stuff.
> - */
> -extern int usbnet_probe(struct usb_interface *, const struct usb_device_id *);
> -extern int usbnet_suspend (struct usb_interface *, pm_message_t );
> -extern int usbnet_resume (struct usb_interface *);
> -extern void usbnet_disconnect(struct usb_interface *);
> -
> -
> -/* Drivers that reuse some of the standard USB CDC infrastructure
> - * (notably, using multiple interfaces according to the CDC
> - * union descriptor) get some helper code.
> - */
> -struct cdc_state {
> -	struct usb_cdc_header_desc	*header;
> -	struct usb_cdc_union_desc	*u;
> -	struct usb_cdc_ether_desc	*ether;
> -	struct usb_interface		*control;
> -	struct usb_interface		*data;
> -};
> -
> -extern int usbnet_generic_cdc_bind (struct usbnet *, struct usb_interface *);
> -extern void usbnet_cdc_unbind (struct usbnet *, struct usb_interface *);
> -
> -/* CDC and RNDIS support the same host-chosen packet filters for IN transfers */
> -#define	DEFAULT_FILTER	(USB_CDC_PACKET_TYPE_BROADCAST \
> -			|USB_CDC_PACKET_TYPE_ALL_MULTICAST \
> -			|USB_CDC_PACKET_TYPE_PROMISCUOUS \
> -			|USB_CDC_PACKET_TYPE_DIRECTED)
> -
> -
> -/* we record the state for each of our queued skbs */
> -enum skb_state {
> -	illegal = 0,
> -	tx_start, tx_done,
> -	rx_start, rx_done, rx_cleanup
> -};
> -
> -struct skb_data {	/* skb->cb is one of these */
> -	struct urb		*urb;
> -	struct usbnet		*dev;
> -	enum skb_state		state;
> -	size_t			length;
> -};
> -
> -
> -extern int usbnet_get_endpoints(struct usbnet *, struct usb_interface *);
> -extern void usbnet_defer_kevent (struct usbnet *, int);
> -extern void usbnet_skb_return (struct usbnet *, struct sk_buff *);
> -extern void usbnet_unlink_rx_urbs(struct usbnet *);
> -
> -extern int usbnet_get_settings (struct net_device *net, struct ethtool_cmd *cmd);
> -extern int usbnet_set_settings (struct net_device *net, struct ethtool_cmd *cmd);
> -extern u32 usbnet_get_link (struct net_device *net);
> -extern u32 usbnet_get_msglevel (struct net_device *);
> -extern void usbnet_set_msglevel (struct net_device *, u32);
> -extern void usbnet_get_drvinfo (struct net_device *, struct ethtool_drvinfo *);
> -extern int usbnet_nway_reset(struct net_device *net);
> -
> -/* messaging support includes the interface name, so it must not be
> - * used before it has one ... notably, in minidriver bind() calls.
> - */
> -#ifdef DEBUG
> -#define devdbg(usbnet, fmt, arg...) \
> -	printk(KERN_DEBUG "%s: " fmt "\n" , (usbnet)->net->name , ## arg)
> -#else
> -#define devdbg(usbnet, fmt, arg...) do {} while(0)
> -#endif
> -
> -#define deverr(usbnet, fmt, arg...) \
> -	printk(KERN_ERR "%s: " fmt "\n" , (usbnet)->net->name , ## arg)
> -#define devwarn(usbnet, fmt, arg...) \
> -	printk(KERN_WARNING "%s: " fmt "\n" , (usbnet)->net->name , ## arg)
> -
> -#define devinfo(usbnet, fmt, arg...) \
> -	printk(KERN_INFO "%s: " fmt "\n" , (usbnet)->net->name , ## arg); \
> -
> -
> -#endif	/* __USBNET_H */
> diff --git a/drivers/net/usb/zaurus.c b/drivers/net/usb/zaurus.c
> index 9f98e8c..e24f7b3 100644
> --- a/drivers/net/usb/zaurus.c
> +++ b/drivers/net/usb/zaurus.c
> @@ -29,8 +29,7 @@
>  #include <linux/crc32.h>
>  #include <linux/usb.h>
>  #include <linux/usb/cdc.h>
> -
> -#include "usbnet.h"
> +#include <linux/usb/usbnet.h>
>  
>  
>  /*
> diff --git a/include/linux/usb/rndis_host.h b/include/linux/usb/rndis_host.h
> new file mode 100644
> index 0000000..edc1d4a
> --- /dev/null
> +++ b/include/linux/usb/rndis_host.h
> @@ -0,0 +1,274 @@
> +/*
> + * Host Side support for RNDIS Networking Links
> + * Copyright (C) 2005 by David Brownell
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
> + */
> +
> +
> +#ifndef	__RNDIS_HOST_H
> +#define	__RNDIS_HOST_H
> +
> +
> +/*
> + * CONTROL uses CDC "encapsulated commands" with funky notifications.
> + *  - control-out:  SEND_ENCAPSULATED
> + *  - interrupt-in:  RESPONSE_AVAILABLE
> + *  - control-in:  GET_ENCAPSULATED
> + *
> + * We'll try to ignore the RESPONSE_AVAILABLE notifications.
> + *
> + * REVISIT some RNDIS implementations seem to have curious issues still
> + * to be resolved.
> + */
> +struct rndis_msg_hdr {
> +	__le32	msg_type;			/* RNDIS_MSG_* */
> +	__le32	msg_len;
> +	// followed by data that varies between messages
> +	__le32	request_id;
> +	__le32	status;
> +	// ... and more
> +} __attribute__ ((packed));
> +
> +/* MS-Windows uses this strange size, but RNDIS spec says 1024 minimum */
> +#define	CONTROL_BUFFER_SIZE		1025
> +
> +/* RNDIS defines an (absurdly huge) 10 second control timeout,
> + * but ActiveSync seems to use a more usual 5 second timeout
> + * (which matches the USB 2.0 spec).
> + */
> +#define	RNDIS_CONTROL_TIMEOUT_MS	(5 * 1000)
> +
> +
> +#define ccpu2 __constant_cpu_to_le32
> +
> +#define RNDIS_MSG_COMPLETION	ccpu2(0x80000000)
> +
> +/* codes for "msg_type" field of rndis messages;
> + * only the data channel uses packet messages (maybe batched);
> + * everything else goes on the control channel.
> + */
> +#define RNDIS_MSG_PACKET	ccpu2(0x00000001)	/* 1-N packets */
> +#define RNDIS_MSG_INIT		ccpu2(0x00000002)
> +#define RNDIS_MSG_INIT_C	(RNDIS_MSG_INIT|RNDIS_MSG_COMPLETION)
> +#define RNDIS_MSG_HALT		ccpu2(0x00000003)
> +#define RNDIS_MSG_QUERY		ccpu2(0x00000004)
> +#define RNDIS_MSG_QUERY_C	(RNDIS_MSG_QUERY|RNDIS_MSG_COMPLETION)
> +#define RNDIS_MSG_SET		ccpu2(0x00000005)
> +#define RNDIS_MSG_SET_C		(RNDIS_MSG_SET|RNDIS_MSG_COMPLETION)
> +#define RNDIS_MSG_RESET		ccpu2(0x00000006)
> +#define RNDIS_MSG_RESET_C	(RNDIS_MSG_RESET|RNDIS_MSG_COMPLETION)
> +#define RNDIS_MSG_INDICATE	ccpu2(0x00000007)
> +#define RNDIS_MSG_KEEPALIVE	ccpu2(0x00000008)
> +#define RNDIS_MSG_KEEPALIVE_C	(RNDIS_MSG_KEEPALIVE|RNDIS_MSG_COMPLETION)
> +
> +/* codes for "status" field of completion messages */
> +#define	RNDIS_STATUS_SUCCESS		ccpu2(0x00000000)
> +#define	RNDIS_STATUS_FAILURE		ccpu2(0xc0000001)
> +#define	RNDIS_STATUS_INVALID_DATA	ccpu2(0xc0010015)
> +#define	RNDIS_STATUS_NOT_SUPPORTED	ccpu2(0xc00000bb)
> +#define	RNDIS_STATUS_MEDIA_CONNECT	ccpu2(0x4001000b)
> +#define	RNDIS_STATUS_MEDIA_DISCONNECT	ccpu2(0x4001000c)
> +
> +/* codes for OID_GEN_PHYSICAL_MEDIUM */
> +#define	RNDIS_PHYSICAL_MEDIUM_UNSPECIFIED	ccpu2(0x00000000)
> +#define	RNDIS_PHYSICAL_MEDIUM_WIRELESS_LAN	ccpu2(0x00000001)
> +#define	RNDIS_PHYSICAL_MEDIUM_CABLE_MODEM	ccpu2(0x00000002)
> +#define	RNDIS_PHYSICAL_MEDIUM_PHONE_LINE	ccpu2(0x00000003)
> +#define	RNDIS_PHYSICAL_MEDIUM_POWER_LINE	ccpu2(0x00000004)
> +#define	RNDIS_PHYSICAL_MEDIUM_DSL		ccpu2(0x00000005)
> +#define	RNDIS_PHYSICAL_MEDIUM_FIBRE_CHANNEL	ccpu2(0x00000006)
> +#define	RNDIS_PHYSICAL_MEDIUM_1394		ccpu2(0x00000007)
> +#define	RNDIS_PHYSICAL_MEDIUM_WIRELESS_WAN	ccpu2(0x00000008)
> +#define	RNDIS_PHYSICAL_MEDIUM_MAX		ccpu2(0x00000009)
> +
> +struct rndis_data_hdr {
> +	__le32	msg_type;		/* RNDIS_MSG_PACKET */
> +	__le32	msg_len;		// rndis_data_hdr + data_len + pad
> +	__le32	data_offset;		// 36 -- right after header
> +	__le32	data_len;		// ... real packet size
> +
> +	__le32	oob_data_offset;	// zero
> +	__le32	oob_data_len;		// zero
> +	__le32	num_oob;		// zero
> +	__le32	packet_data_offset;	// zero
> +
> +	__le32	packet_data_len;	// zero
> +	__le32	vc_handle;		// zero
> +	__le32	reserved;		// zero
> +} __attribute__ ((packed));
> +
> +struct rndis_init {		/* OUT */
> +	// header and:
> +	__le32	msg_type;			/* RNDIS_MSG_INIT */
> +	__le32	msg_len;			// 24
> +	__le32	request_id;
> +	__le32	major_version;			// of rndis (1.0)
> +	__le32	minor_version;
> +	__le32	max_transfer_size;
> +} __attribute__ ((packed));
> +
> +struct rndis_init_c {		/* IN */
> +	// header and:
> +	__le32	msg_type;			/* RNDIS_MSG_INIT_C */
> +	__le32	msg_len;
> +	__le32	request_id;
> +	__le32	status;
> +	__le32	major_version;			// of rndis (1.0)
> +	__le32	minor_version;
> +	__le32	device_flags;
> +	__le32	medium;				// zero == 802.3
> +	__le32	max_packets_per_message;
> +	__le32	max_transfer_size;
> +	__le32	packet_alignment;		// max 7; (1<<n) bytes
> +	__le32	af_list_offset;			// zero
> +	__le32	af_list_size;			// zero
> +} __attribute__ ((packed));
> +
> +struct rndis_halt {		/* OUT (no reply) */
> +	// header and:
> +	__le32	msg_type;			/* RNDIS_MSG_HALT */
> +	__le32	msg_len;
> +	__le32	request_id;
> +} __attribute__ ((packed));
> +
> +struct rndis_query {		/* OUT */
> +	// header and:
> +	__le32	msg_type;			/* RNDIS_MSG_QUERY */
> +	__le32	msg_len;
> +	__le32	request_id;
> +	__le32	oid;
> +	__le32	len;
> +	__le32	offset;
> +/*?*/	__le32	handle;				// zero
> +} __attribute__ ((packed));
> +
> +struct rndis_query_c {		/* IN */
> +	// header and:
> +	__le32	msg_type;			/* RNDIS_MSG_QUERY_C */
> +	__le32	msg_len;
> +	__le32	request_id;
> +	__le32	status;
> +	__le32	len;
> +	__le32	offset;
> +} __attribute__ ((packed));
> +
> +struct rndis_set {		/* OUT */
> +	// header and:
> +	__le32	msg_type;			/* RNDIS_MSG_SET */
> +	__le32	msg_len;
> +	__le32	request_id;
> +	__le32	oid;
> +	__le32	len;
> +	__le32	offset;
> +/*?*/	__le32	handle;				// zero
> +} __attribute__ ((packed));
> +
> +struct rndis_set_c {		/* IN */
> +	// header and:
> +	__le32	msg_type;			/* RNDIS_MSG_SET_C */
> +	__le32	msg_len;
> +	__le32	request_id;
> +	__le32	status;
> +} __attribute__ ((packed));
> +
> +struct rndis_reset {		/* IN */
> +	// header and:
> +	__le32	msg_type;			/* RNDIS_MSG_RESET */
> +	__le32	msg_len;
> +	__le32	reserved;
> +} __attribute__ ((packed));
> +
> +struct rndis_reset_c {		/* OUT */
> +	// header and:
> +	__le32	msg_type;			/* RNDIS_MSG_RESET_C */
> +	__le32	msg_len;
> +	__le32	status;
> +	__le32	addressing_lost;
> +} __attribute__ ((packed));
> +
> +struct rndis_indicate {		/* IN (unrequested) */
> +	// header and:
> +	__le32	msg_type;			/* RNDIS_MSG_INDICATE */
> +	__le32	msg_len;
> +	__le32	status;
> +	__le32	length;
> +	__le32	offset;
> +/**/	__le32	diag_status;
> +	__le32	error_offset;
> +/**/	__le32	message;
> +} __attribute__ ((packed));
> +
> +struct rndis_keepalive {	/* OUT (optionally IN) */
> +	// header and:
> +	__le32	msg_type;			/* RNDIS_MSG_KEEPALIVE */
> +	__le32	msg_len;
> +	__le32	request_id;
> +} __attribute__ ((packed));
> +
> +struct rndis_keepalive_c {	/* IN (optionally OUT) */
> +	// header and:
> +	__le32	msg_type;			/* RNDIS_MSG_KEEPALIVE_C */
> +	__le32	msg_len;
> +	__le32	request_id;
> +	__le32	status;
> +} __attribute__ ((packed));
> +
> +/* NOTE:  about 30 OIDs are "mandatory" for peripherals to support ... and
> + * there are gobs more that may optionally be supported.  We'll avoid as much
> + * of that mess as possible.
> + */
> +#define OID_802_3_PERMANENT_ADDRESS	ccpu2(0x01010101)
> +#define OID_GEN_MAXIMUM_FRAME_SIZE	ccpu2(0x00010106)
> +#define OID_GEN_CURRENT_PACKET_FILTER	ccpu2(0x0001010e)
> +#define OID_GEN_PHYSICAL_MEDIUM		ccpu2(0x00010202)
> +
> +/* packet filter bits used by OID_GEN_CURRENT_PACKET_FILTER */
> +#define RNDIS_PACKET_TYPE_DIRECTED		ccpu2(0x00000001)
> +#define RNDIS_PACKET_TYPE_MULTICAST		ccpu2(0x00000002)
> +#define RNDIS_PACKET_TYPE_ALL_MULTICAST		ccpu2(0x00000004)
> +#define RNDIS_PACKET_TYPE_BROADCAST		ccpu2(0x00000008)
> +#define RNDIS_PACKET_TYPE_SOURCE_ROUTING	ccpu2(0x00000010)
> +#define RNDIS_PACKET_TYPE_PROMISCUOUS		ccpu2(0x00000020)
> +#define RNDIS_PACKET_TYPE_SMT			ccpu2(0x00000040)
> +#define RNDIS_PACKET_TYPE_ALL_LOCAL		ccpu2(0x00000080)
> +#define RNDIS_PACKET_TYPE_GROUP			ccpu2(0x00001000)
> +#define RNDIS_PACKET_TYPE_ALL_FUNCTIONAL	ccpu2(0x00002000)
> +#define RNDIS_PACKET_TYPE_FUNCTIONAL		ccpu2(0x00004000)
> +#define RNDIS_PACKET_TYPE_MAC_FRAME		ccpu2(0x00008000)
> +
> +/* default filter used with RNDIS devices */
> +#define RNDIS_DEFAULT_FILTER ( \
> +	RNDIS_PACKET_TYPE_DIRECTED | \
> +	RNDIS_PACKET_TYPE_BROADCAST | \
> +	RNDIS_PACKET_TYPE_ALL_MULTICAST | \
> +	RNDIS_PACKET_TYPE_PROMISCUOUS)
> +
> +/* Flags to require specific physical medium type for generic_rndis_bind() */
> +#define FLAG_RNDIS_PHYM_NOT_WIRELESS	0x0001
> +#define FLAG_RNDIS_PHYM_WIRELESS	0x0002
> +
> +
> +extern void rndis_status(struct usbnet *dev, struct urb *urb);
> +extern int rndis_command(struct usbnet *dev, struct rndis_msg_hdr *buf);
> +extern int
> +generic_rndis_bind(struct usbnet *dev, struct usb_interface *intf, int flags);
> +extern void rndis_unbind(struct usbnet *dev, struct usb_interface *intf);
> +extern int rndis_rx_fixup(struct usbnet *dev, struct sk_buff *skb);
> +extern struct sk_buff *
> +rndis_tx_fixup(struct usbnet *dev, struct sk_buff *skb, gfp_t flags);
> +
> +#endif	/* __RNDIS_HOST_H */
> +
> diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
> new file mode 100644
> index 0000000..e0501da
> --- /dev/null
> +++ b/include/linux/usb/usbnet.h
> @@ -0,0 +1,214 @@
> +/*
> + * USB Networking Link Interface
> + *
> + * Copyright (C) 2000-2005 by David Brownell <dbrownell@users.sourceforge.net>
> + * Copyright (C) 2003-2005 David Hollis <dhollis@davehollis.com>
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
> + */
> +
> +
> +#ifndef	__USBNET_H
> +#define	__USBNET_H
> +
> +
> +/* interface from usbnet core to each USB networking link we handle */
> +struct usbnet {
> +	/* housekeeping */
> +	struct usb_device	*udev;
> +	struct usb_interface	*intf;
> +	struct driver_info	*driver_info;
> +	const char		*driver_name;
> +	void			*driver_priv;
> +	wait_queue_head_t	*wait;
> +	struct mutex		phy_mutex;
> +	unsigned char		suspend_count;
> +
> +	/* i/o info: pipes etc */
> +	unsigned		in, out;
> +	struct usb_host_endpoint *status;
> +	unsigned		maxpacket;
> +	struct timer_list	delay;
> +
> +	/* protocol/interface state */
> +	struct net_device	*net;
> +	struct net_device_stats	stats;
> +	int			msg_enable;
> +	unsigned long		data [5];
> +	u32			xid;
> +	u32			hard_mtu;	/* count any extra framing */
> +	size_t			rx_urb_size;	/* size for rx urbs */
> +	struct mii_if_info	mii;
> +
> +	/* various kinds of pending driver work */
> +	struct sk_buff_head	rxq;
> +	struct sk_buff_head	txq;
> +	struct sk_buff_head	done;
> +	struct urb		*interrupt;
> +	struct tasklet_struct	bh;
> +
> +	struct work_struct	kevent;
> +	unsigned long		flags;
> +#		define EVENT_TX_HALT	0
> +#		define EVENT_RX_HALT	1
> +#		define EVENT_RX_MEMORY	2
> +#		define EVENT_STS_SPLIT	3
> +#		define EVENT_LINK_RESET	4
> +};
> +
> +static inline struct usb_driver *driver_of(struct usb_interface *intf)
> +{
> +	return to_usb_driver(intf->dev.driver);
> +}
> +
> +/* interface from the device/framing level "minidriver" to core */
> +struct driver_info {
> +	char		*description;
> +
> +	int		flags;
> +/* framing is CDC Ethernet, not writing ZLPs (hw issues), or optionally: */
> +#define FLAG_FRAMING_NC	0x0001		/* guard against device dropouts */
> +#define FLAG_FRAMING_GL	0x0002		/* genelink batches packets */
> +#define FLAG_FRAMING_Z	0x0004		/* zaurus adds a trailer */
> +#define FLAG_FRAMING_RN	0x0008		/* RNDIS batches, plus huge header */
> +
> +#define FLAG_NO_SETINT	0x0010		/* device can't set_interface() */
> +#define FLAG_ETHER	0x0020		/* maybe use "eth%d" names */
> +
> +#define FLAG_FRAMING_AX 0x0040		/* AX88772/178 packets */
> +#define FLAG_WLAN	0x0080		/* use "wlan%d" names */
> +
> +
> +	/* init device ... can sleep, or cause probe() failure */
> +	int	(*bind)(struct usbnet *, struct usb_interface *);
> +
> +	/* cleanup device ... can sleep, but can't fail */
> +	void	(*unbind)(struct usbnet *, struct usb_interface *);
> +
> +	/* reset device ... can sleep */
> +	int	(*reset)(struct usbnet *);
> +
> +	/* see if peer is connected ... can sleep */
> +	int	(*check_connect)(struct usbnet *);
> +
> +	/* for status polling */
> +	void	(*status)(struct usbnet *, struct urb *);
> +
> +	/* link reset handling, called from defer_kevent */
> +	int	(*link_reset)(struct usbnet *);
> +
> +	/* fixup rx packet (strip framing) */
> +	int	(*rx_fixup)(struct usbnet *dev, struct sk_buff *skb);
> +
> +	/* fixup tx packet (add framing) */
> +	struct sk_buff	*(*tx_fixup)(struct usbnet *dev,
> +				struct sk_buff *skb, gfp_t flags);
> +
> +	/* early initialization code, can sleep. This is for minidrivers
> +	 * having 'subminidrivers' that need to do extra initialization
> +	 * right after minidriver have initialized hardware. */
> +	int	(*early_init)(struct usbnet *dev);
> +
> +	/* called by minidriver when link state changes, state: 0=disconnect,
> +	 * 1=connect */
> +	void	(*link_change)(struct usbnet *dev, int state);
> +
> +	/* for new devices, use the descriptor-reading code instead */
> +	int		in;		/* rx endpoint */
> +	int		out;		/* tx endpoint */
> +
> +	unsigned long	data;		/* Misc driver specific data */
> +};
> +
> +/* Minidrivers are just drivers using the "usbnet" core as a powerful
> + * network-specific subroutine library ... that happens to do pretty
> + * much everything except custom framing and chip-specific stuff.
> + */
> +extern int usbnet_probe(struct usb_interface *, const struct usb_device_id *);
> +extern int usbnet_suspend (struct usb_interface *, pm_message_t );
> +extern int usbnet_resume (struct usb_interface *);
> +extern void usbnet_disconnect(struct usb_interface *);
> +
> +
> +/* Drivers that reuse some of the standard USB CDC infrastructure
> + * (notably, using multiple interfaces according to the CDC
> + * union descriptor) get some helper code.
> + */
> +struct cdc_state {
> +	struct usb_cdc_header_desc	*header;
> +	struct usb_cdc_union_desc	*u;
> +	struct usb_cdc_ether_desc	*ether;
> +	struct usb_interface		*control;
> +	struct usb_interface		*data;
> +};
> +
> +extern int usbnet_generic_cdc_bind (struct usbnet *, struct usb_interface *);
> +extern void usbnet_cdc_unbind (struct usbnet *, struct usb_interface *);
> +
> +/* CDC and RNDIS support the same host-chosen packet filters for IN transfers */
> +#define	DEFAULT_FILTER	(USB_CDC_PACKET_TYPE_BROADCAST \
> +			|USB_CDC_PACKET_TYPE_ALL_MULTICAST \
> +			|USB_CDC_PACKET_TYPE_PROMISCUOUS \
> +			|USB_CDC_PACKET_TYPE_DIRECTED)
> +
> +
> +/* we record the state for each of our queued skbs */
> +enum skb_state {
> +	illegal = 0,
> +	tx_start, tx_done,
> +	rx_start, rx_done, rx_cleanup
> +};
> +
> +struct skb_data {	/* skb->cb is one of these */
> +	struct urb		*urb;
> +	struct usbnet		*dev;
> +	enum skb_state		state;
> +	size_t			length;
> +};
> +
> +
> +extern int usbnet_get_endpoints(struct usbnet *, struct usb_interface *);
> +extern void usbnet_defer_kevent (struct usbnet *, int);
> +extern void usbnet_skb_return (struct usbnet *, struct sk_buff *);
> +extern void usbnet_unlink_rx_urbs(struct usbnet *);
> +
> +extern int usbnet_get_settings (struct net_device *net, struct ethtool_cmd *cmd);
> +extern int usbnet_set_settings (struct net_device *net, struct ethtool_cmd *cmd);
> +extern u32 usbnet_get_link (struct net_device *net);
> +extern u32 usbnet_get_msglevel (struct net_device *);
> +extern void usbnet_set_msglevel (struct net_device *, u32);
> +extern void usbnet_get_drvinfo (struct net_device *, struct ethtool_drvinfo *);
> +extern int usbnet_nway_reset(struct net_device *net);
> +
> +/* messaging support includes the interface name, so it must not be
> + * used before it has one ... notably, in minidriver bind() calls.
> + */
> +#ifdef DEBUG
> +#define devdbg(usbnet, fmt, arg...) \
> +	printk(KERN_DEBUG "%s: " fmt "\n" , (usbnet)->net->name , ## arg)
> +#else
> +#define devdbg(usbnet, fmt, arg...) do {} while(0)
> +#endif
> +
> +#define deverr(usbnet, fmt, arg...) \
> +	printk(KERN_ERR "%s: " fmt "\n" , (usbnet)->net->name , ## arg)
> +#define devwarn(usbnet, fmt, arg...) \
> +	printk(KERN_WARNING "%s: " fmt "\n" , (usbnet)->net->name , ## arg)
> +
> +#define devinfo(usbnet, fmt, arg...) \
> +	printk(KERN_INFO "%s: " fmt "\n" , (usbnet)->net->name , ## arg); \
> +
> +
> +#endif	/* __USBNET_H */
> 



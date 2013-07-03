From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: Re: [PATCH 1/3] Export cdc_ncm_{tx,rx}_fixup functions
Date: Wed, 3 Jul 2013 12:19:00 +0200 (CEST)
Message-ID: <alpine.LNX.2.02.1307031217390.19087@eeeadesso>
References: <alpine.LNX.2.02.1307021241380.8884@eeeadesso> <87wqp9xja5.fsf@nemi.mork.no> <alpine.LNX.2.02.1307021855270.19053@eeeadesso> <alpine.LNX.2.02.1307022202570.26010@eeeadesso> <alpine.LNX.2.02.1307022207060.26010@eeeadesso>
 <87a9m4w0ju.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Enrico Mioso <mrkiko.rs@gmail.com>, netdev@vger.kernel.org
To: =?ISO-8859-15?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:32893 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932352Ab3GCKSk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jul 2013 06:18:40 -0400
Received: by mail-wg0-f53.google.com with SMTP id y10so5617928wgg.20
        for <netdev@vger.kernel.org>; Wed, 03 Jul 2013 03:18:39 -0700 (PDT)
In-Reply-To: <87a9m4w0ju.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thank you! I'll follow your suggestions.
Regarding the 80 chars limit - not, it's not strictly a problem, but since my 
braille device is 80 chars and I'm using a terminal 80x50 (80 colums, 50 rows), 
I felt more confortable with it. No problems, I'll add them on a single line.



On Wed, 3 Jul 2013, Bj?rn Mork wrote:

==Date: Wed, 03 Jul 2013 09:43:49 +0200
==From: Bj?rn Mork <bjorn@mork.no>
==To: Enrico Mioso <mrkiko.rs@gmail.com>
==Cc: netdev@vger.kernel.org
==Subject: Re: [PATCH 1/3] Export cdc_ncm_{tx,rx}_fixup functions
==
==Enrico Mioso <mrkiko.rs@gmail.com> writes:
==
==> Exports those functions to be able to re-use them in other drivers if needed.
==>
==> diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
==> index 493277e..22ed51c 100644
==> --- a/drivers/net/usb/cdc_ncm.c
==> +++ b/drivers/net/usb/cdc_ncm.c
==> @@ -885,6 +885,8 @@ error:
==>  
==>  	return NULL;
==>  }
==> +EXPORT_SYMBOL_GPL(cdc_ncm_tx_fixup);
==> +
==>  
==
==Don't add spurious empty lines.
==
==
==
==>  /* verify NTB header and return offset of first NDP, or negative error */
==>  int cdc_ncm_rx_verify_nth16(struct cdc_ncm_ctx *ctx, struct sk_buff *skb_in)
==> @@ -1040,6 +1042,7 @@ err_ndp:
==>  error:
==>  	return 0;
==>  }
==> +EXPORT_SYMBOL_GPL(cdc_ncm_rx_fixup);
==>  
==>  static void
==>  cdc_ncm_speed_change(struct cdc_ncm_ctx *ctx,
==> diff --git a/include/linux/usb/cdc_ncm.h b/include/linux/usb/cdc_ncm.h
==> index cc25b70..163244b 100644
==> --- a/include/linux/usb/cdc_ncm.h
==> +++ b/include/linux/usb/cdc_ncm.h
==> @@ -133,3 +133,6 @@ extern void cdc_ncm_unbind(struct usbnet *dev, struct usb_interface *intf);
==>  extern struct sk_buff *cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, struct sk_buff *skb, __le32 sign);
==>  extern int cdc_ncm_rx_verify_nth16(struct cdc_ncm_ctx *ctx, struct sk_buff *skb_in);
==>  extern int cdc_ncm_rx_verify_ndp16(struct sk_buff *skb_in, int ndpoffset);
==> +struct sk_buff *
==> +cdc_ncm_tx_fixup(struct usbnet *dev, struct sk_buff *skb, gfp_t flags);
==
==I would have put this on a single line, even if it breaks the 80 character limit.
==
==BTW, is breaking that limit more of a problem for you?  I can certainly
==understand that you want to strictly obey it if it is..
==
==> +int cdc_ncm_rx_fixup(struct usbnet *dev, struct sk_buff *skb_in);
==
==Both of these need "export" I believe...
==
==
==Bj?rn
==

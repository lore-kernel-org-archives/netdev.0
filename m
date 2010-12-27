From: Hans Ulli Kroll <ulli.kroll@googlemail.com>
Subject: Re: [RFC PATCH v2] Gemini: Gigabit ethernet driver
Date: Mon, 27 Dec 2010 20:21:44 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1012271956260.8215@localhost>
References: <20101227103247.8D2E813909@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-1900419167-1293477711=:8215"
Cc: Hans Ulli Kroll <ulli.kroll@googlemail.com>,
	gemini-board-dev@lists.berlios.de, netdev@vger.kernel.org,
	Christoph Biedl <linux-kernel.bfrz@manchmal.in-ulm.de>
To: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:34389 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754052Ab0L0TVy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Dec 2010 14:21:54 -0500
Received: by eye27 with SMTP id 27so4005556eye.19
        for <netdev@vger.kernel.org>; Mon, 27 Dec 2010 11:21:53 -0800 (PST)
In-Reply-To: <20101227103247.8D2E813909@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-1900419167-1293477711=:8215
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT



On Mon, 27 Dec 2010, Michał Mirosław wrote:

> Driver for SL351x (Gemini) SoC ethernet peripheral. Based in part
> on work by Paulius Zaleckas and GPLd code from Raidsonic and other
> NAS vendors.
> 
> Tested on Raidsonic IcyBox 4220-B (dual SATA NAS).
> 
> Signed-off-by: Michał Mirosław <mirq-linux@rere.qmqm.pl>
> 
> ---
> 
> Hans, please drop previous mail from the gemini-board-dev queue -
> it had broken headers.

mail is already out.

> +		.dis_tx = 1,
> +		.dis_rx = 1,
> +		.max_len = 2,	/* magic; 512 << max_len? */
> +		.ipv4_rx_chksum = 1,
> +		.ipv6_rx_chksum = 1,

This is what I found in some netbsd code for maxlen

#define	CONFIG0_MAXLEN_MASK			__BITS(8,10)
#define	CONFIG0_MAXLEN_GET(x)			(((x) >> 8) & 
CONFIG0_MAXLEN_MASK)
#define	CONFIG0_MAXLEN(x)			(((x) & 
CONFIG0_MAXLEN_MASK) << 8)
#define	CONFIG0_MAXLEN_1536			0
#define	CONFIG0_MAXLEN_1518			1
#define	CONFIG0_MAXLEN_1522			2
#define	CONFIG0_MAXLEN_1548			3
#define	CONFIG0_MAXLEN_JUMBO			4

spec. for the SL3616 says jumbo is 9k frames, but i didn't proved this.

BTW:

Why u64_stats ?
I see only a few driver are using u64_stats.
vlan, br_device and some intel driver 
no gigabit driver for marvell devices uses u64_stats

Ulli
--8323328-1900419167-1293477711=:8215--

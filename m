From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/3] gianfar: Implement workaround for eTSEC74
 erratum
Date: Wed, 30 Jun 2010 11:37:13 -0700 (PDT)
Message-ID: <20100630.113713.180406828.davem@davemloft.net>
References: <20100630163804.GA636@oksana.dev.rtsoft.ru>
	<20100630163912.GA23337@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: manfred.rudigier@omicron.at, Sandeep.Kumar@freescale.com,
	afleming@freescale.com, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: avorontsov@mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55566
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752804Ab0F3ShA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 14:37:00 -0400
In-Reply-To: <20100630163912.GA23337@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Vorontsov <avorontsov@mvista.com>
Date: Wed, 30 Jun 2010 20:39:12 +0400

> MPC8313ECE says:
> 
> "If MACCFG2[Huge Frame]=0 and the Ethernet controller receives frames
>  which are larger than MAXFRM, the controller truncates the frames to
>  length MAXFRM and marks RxBD[TR]=1 to indicate the error. The controller
>  also erroneously marks RxBD[TR]=1 if the received frame length is MAXFRM
>  or MAXFRM-1, even though those frames are not truncated.
>  No truncation or truncation error occurs if MACCFG2[Huge Frame]=1."
> 
> There are two options to workaround the issue:
> 
> "1. Set MACCFG2[Huge Frame]=1, so no truncation occurs for invalid large
>  frames. Software can determine if a frame is larger than MAXFRM by
>  reading RxBD[LG] or RxBD[Data Length].
> 
>  2. Set MAXFRM to 1538 (0x602) instead of the default 1536 (0x600), so
>  normal-length frames are not marked as truncated. Software can examine
>  RxBD[Data Length] to determine if the frame was larger than MAXFRM-2."
> 
> This patch implements the first workaround option by setting HUGEFRAME
> bit, and gfar_clean_rx_ring() already checks the RxBD[Data Length].
> 
> Signed-off-by: Anton Vorontsov <avorontsov@mvista.com>

Applied.

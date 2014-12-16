From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] net: fec: Fix NAPI race
Date: Tue, 16 Dec 2014 15:24:52 -0500 (EST)
Message-ID: <20141216.152452.1492750403664993087.davem@davemloft.net>
References: <1418725558-17287-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, R49496@freescale.com,
	bhutchings@solarflare.com, stephen@networkplumber.org
To: b38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55691 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751585AbaLPUYz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 15:24:55 -0500
In-Reply-To: <1418725558-17287-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fugang Duan <b38611@freescale.com>
Date: Tue, 16 Dec 2014 18:25:58 +0800

> Do camera capture test on i.MX6q sabresd board, and save the capture data to
> nfs rootfs. The command is:
> gst-launch-1.0 -e imxv4l2src device=/dev/video1 num-buffers=2592000 ! tee name=t !
> queue ! imxv4l2sink sync=false t. ! queue ! vpuenc ! queue ! mux. pulsesrc num-buffers=3720937
> blocksize=4096 ! 'audio/x-raw, rate=44100, channels=2' ! queue ! imxmp3enc ! mpegaudioparse !
> queue ! mux. qtmux name=mux ! filesink location=video_recording_long.mov
> 
> After about 10 hours running, there have net watchdog timeout kernel dump:
 ...
> There might have a race in napi_schedule(), leaving interrupts disabled forever.
> After these patch, the case still work more than 40 hours running.
> 
> Signed-off-by: Fugang Duan <B38611@freescale.com>

Applied, thanks.

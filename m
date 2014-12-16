From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH net-next 1/1] net: fec: Fix NAPI race
Date: Tue, 16 Dec 2014 09:33:53 -0200
Message-ID: <CAOMZO5D3cysOauyptcjCDM6sjK7ZEiAY==xYu-qqHbwFreoV8g@mail.gmail.com>
References: <1418725558-17287-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Estevam Fabio-R49496 <R49496@freescale.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	robert.daniels@vantagecontrols.com,
	=?UTF-8?B?TWFyZWsgVmHFoXV0?= <marex@denx.de>,
	Russell King <linux@arm.linux.org.uk>
To: Fugang Duan <b38611@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:49101 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750911AbaLPLdz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 06:33:55 -0500
Received: by mail-lb0-f181.google.com with SMTP id l4so10490531lbv.40
        for <netdev@vger.kernel.org>; Tue, 16 Dec 2014 03:33:53 -0800 (PST)
In-Reply-To: <1418725558-17287-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Fugang,

On Tue, Dec 16, 2014 at 8:25 AM, Fugang Duan <b38611@freescale.com> wrote:
> Do camera capture test on i.MX6q sabresd board, and save the capture data to
> nfs rootfs. The command is:
> gst-launch-1.0 -e imxv4l2src device=/dev/video1 num-buffers=2592000 ! tee name=t !
> queue ! imxv4l2sink sync=false t. ! queue ! vpuenc ! queue ! mux. pulsesrc num-buffers=3720937
> blocksize=4096 ! 'audio/x-raw, rate=44100, channels=2' ! queue ! imxmp3enc ! mpegaudioparse !
> queue ! mux. qtmux name=mux ! filesink location=video_recording_long.mov
>
> After about 10 hours running, there have net watchdog timeout kernel dump:
> ...
> WARNING: CPU: 0 PID: 0 at net/sched/sch_generic.c:264 dev_watchdog+0x2b4/0x2d8()
> NETDEV WATCHDOG: eth0 (fec): transmit queue 0 timed out

Adding more people who reported similar issues in the past.

Marek,

Does this patch solve the problem you reported at
http://www.spinics.net/lists/netdev/msg268167.html ?

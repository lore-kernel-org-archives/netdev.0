From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v1 0/4] Enable FEC pps ouput
Date: Fri, 3 Oct 2014 10:23:41 +0200
Message-ID: <20141003082341.GB4249@localhost.localdomain>
References: <1411632621-17429-1-git-send-email-b45643@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, shawn.guo@linaro.org,
	bhutchings@solarflare.com, R49496@freescale.com,
	b38611@freescale.com, b20596@freescale.com,
	stephen@networkplumber.org
To: Luwei Zhou <b45643@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:50577 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751845AbaJCIXr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 04:23:47 -0400
Received: by mail-wg0-f41.google.com with SMTP id b13so857022wgh.0
        for <netdev@vger.kernel.org>; Fri, 03 Oct 2014 01:23:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1411632621-17429-1-git-send-email-b45643@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 25, 2014 at 04:10:17PM +0800, Luwei Zhou wrote:
> This patch does:
> 	- Replace 32-bit free-running PTP timer with 31-bit.
> 	- Implement hardware PTP timestamp adjustment.
> 	- Enable PPS output based on hardware adjustment.
> 
> 
> Luwei Zhou (4):
>   net: fec: ptp: Use the 31-bit ptp timer.
>   net: fec: ptp: Use hardware algorithm to adjust PTP counter.
>   net: fec: ptp: Enalbe PPS ouput based on ptp clock
                   ^^^^^^     ^^^^^
                   Enable     output

Also, it looks like you have implemented the wrong feature.

The "pps" capability means that the clock provides a PPS event
(interrupt) to the kernel.

IOW, if .pps==1, then you must call ptp_clock_event() with event type
PTP_CLOCK_PPS.

Your patch set seems to be creating a periodic output and not a PPS
kernel callback.

You should clarify what you are trying to do, and then implement the
appropriate interface in your driver.

Thanks,
Richard

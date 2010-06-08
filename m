From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [PATCH 11/12] sfc: Only count bad packets in rx_errors
Date: Tue, 08 Jun 2010 19:09:31 +0100
Message-ID: <1276020571.2185.52.camel@achroite.uk.solarflarecom.com>
References: <1275426967.2114.25.camel@achroite.uk.solarflarecom.com>
	 <1275427265.2114.35.camel@achroite.uk.solarflarecom.com>
	 <2DFD360E328B3941911E6D28B085D990107C9DA893@SJEXCHCCR01.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:43734 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751539Ab0FHSJd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 14:09:33 -0400
In-Reply-To: <2DFD360E328B3941911E6D28B085D990107C9DA893@SJEXCHCCR01.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-06-08 at 02:20 -0700, Dmitry Kravkov wrote:
> Hi,
> 
> Different drivers include different errors in stats->rx_errors:

Your table didn't line up when display here.  It appears you used
6-space tabs so I've expanded them to spaces on that assumption:

>   bxn2        bnx2x       ixgbx       sfc         dnet        atlx
> ----------------------------------------------------------------------
> rx_length   rx_length   rx_length   rx_length   rx_length   rx_length
> rx_over     rx_over                                         rx_over
> rx_frame    rx_frame                rx_frame    rx_frame    rx_frame
> rx_crc      rx_crc      rx_crc      rx_crc                  rx_crc
>             rx_fifo                                         rx_fifo
>             rx_missed                                       rx_missed
>                                     rx_symbol
>                                                 unsup_opcd
> ----------------------------------------------------------------------
> Is there any documentation which defines what should this statistic include?

My references are the comments on the structure (in <linux/if_link.h>
and <linux/netdevice.h>) and an email by Donald Becker
<http://www.uwsg.iu.edu/hypermail/linux/net/0003.3/0154.html>.  The
comments could probably be expanded.

Note also that some of the statistics are combined as follows in
/proc/net/dev, which is what ifconfig uses:

Heading/subheading  Summed statistics
-----------------------------------------------------------------------------------------------
Receive/drop        rx_dropped, rx_missed_errors
Receive/frame       rx_length_errors, rx_over_errors, rx_crc_errors, rx_frame_errors
Transmit/carrier    tx_carrier_errors, tx_aborted_errors, tx_window_errors, tx_heartbeat_errors

Something that doesn't make sense to me is that rx_over_errors is
included under 'frame' rather than under 'drop'.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: What ixgbe devices support HWTSTAMP_FILTER_ALL for hardware time
 stamping?
Date: Sat, 14 May 2016 09:30:03 +0200
Message-ID: <20160514073002.GA2053@netboy>
References: <582A121C-339D-4469-958C-9673C7E5A654@alum.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Network Development <netdev@vger.kernel.org>
To: Guy Harris <guy@alum.mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:35223 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751146AbcENHaJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 May 2016 03:30:09 -0400
Received: by mail-wm0-f52.google.com with SMTP id e201so45645727wme.0
        for <netdev@vger.kernel.org>; Sat, 14 May 2016 00:30:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <582A121C-339D-4469-958C-9673C7E5A654@alum.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 13, 2016 at 04:12:52PM -0700, Guy Harris wrote:
> The Linux implementation currently implements the inquiry by doing a
> ETHTOOL_GET_TS_INFO SIOETHTOOL ioctl and looking at the
> so_timestamping bits, if the linux/ethtool.h header defines
> ETHTOOL_GET_TS_INFO and the ioctl succeeds on the device.

So far, so good. 

> This is inadequate - as libpcap requests hardware time stamping for
> all packets, it should also check whether HWTSTAMP_FILTER_ALL is set
> in rx_filters, and only offer hardware time stamping if it's set.

The SO_TIMESTAMPING and SIOCSHWTSTAMP interfaces predate
ETHTOOL_GET_TS_INFO, and they work fine without it.  Applications
should simply use SIOCSHWTSTAMP to request the mode that they need and
check the result.

That said, the information in ETHTOOL_GET_TS_INFO should be correct.

> Is it the case that only the ixgbe_mac_X550 and ixgbe_mac_X550EM_x
> controllers support HWTSTAMP_FILTER_ALL?  

Looks like it.

> If so, shouldn't ixgbe_get_ts_info() be doing something such as:

> 		if (adapter->hw.mac.type >= ixgbe_mac_X550)
> 			info->rx_filters |= (1 << HWTSTAMP_FILTER_ALL);

Yes, probably.

> From a quick scan of drivers/net, it looks as if
> 
> 	drivers/net/ethernet/cavium/liquidio
> 
> also support HWTSTAMP_FILTER_ALL but don't advertise it, 

For this and the other drivers you mentioned, their maintainers might
appreciate patches...

Thanks,
Richard

From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 2/2] net/mlx5_en: Add HW timestamping (TS)
 support
Date: Wed, 16 Dec 2015 20:16:27 +0100
Message-ID: <20151216191627.GC28759@localhost.localdomain>
References: <1450284394-32386-1-git-send-email-saeedm@mellanox.com>
 <1450284394-32386-3-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:38554 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966128AbbLPTQc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 14:16:32 -0500
Received: by mail-wm0-f52.google.com with SMTP id l126so52668356wml.1
        for <netdev@vger.kernel.org>; Wed, 16 Dec 2015 11:16:32 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1450284394-32386-3-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 16, 2015 at 06:46:34PM +0200, Saeed Mahameed wrote:
> From: Eran Ben Elisha <eranbe@mellanox.com>
> 
> Add support for enable/disable HW timestamping for incoming and/or
> outgoing packets. It adds and initializes all structs and callbacks
> needed by kernel TS API.  To enable/disable HW timestamping appropriate
> ioctl should be used.  Currently HWTSTAMP_FILTER_ALL/NONE and
> HWTSAMP_TX_ON/OFF only are supported.  Make all relevant changes in
> RX/TX flows to consider TS request and plant HW timestamps into
> relevant structures.
> 
> Add a PHC support to the mlx5_en driver. Use reader/writer spinlocks to
> protect the timecounter since every packet received needs to call
> timecounter_cycle2time() when timestamping is enabled.  This can become
> a performance bottleneck with RSS and multiple receive queues if normal
> spinlocks are used.

The subject line doesn't mention PHC.  Please break this into two patches.

1. add hw time stamping
2. add phc support

Also, please CC the ptp maintainer for ptp patches.

Thanks,
Richard

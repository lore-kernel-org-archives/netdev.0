From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 02/14] sfc: Add sysfs entry for flags (link
 control and primary)
Date: Fri, 29 May 2015 10:48:43 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB42986@AcuExch.aculab.com>
References: <55683895.2090408@solarflare.com>
 <556838ED.8020407@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-net-drivers@solarflare.com" <linux-net-drivers@solarflare.com>
To: 'Shradha Shah' <sshah@solarflare.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.181]:50698 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755574AbbE2Kug convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 06:50:36 -0400
In-Reply-To: <556838ED.8020407@solarflare.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shradha Shah
> Sent: 29 May 2015 11:01
> On  every adapter there will be one primary PF per adaptor and
> one link control PF per port.
...
> +	return sprintf(buf, "%d\n",
> +		       ((efx->mcdi->fn_flags) &
> +			(1 << MC_CMD_DRV_ATTACH_EXT_OUT_FLAG_LINKCTRL))
> +		       ? 1 : 0);

Horrid expression.
Why not:
	(efx->mcdi->fn_flags >> MC_CMD_DRV_ATTACH_EXT_OUT_FLAG_LINKCTRL) & 1

using sprintf() is also excessive. Maybe:
	*buf = '0' + (expression);
	return 1;

You may also need to check for buffer overrun.

	David

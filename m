From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/7] switchdev: add IPv4 routing offload
Date: Wed, 04 Mar 2015 00:38:44 -0500 (EST)
Message-ID: <20150304.003844.1400829201582760359.davem@davemloft.net>
References: <1425425520-34017-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, roopa@cumulusnetworks.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40790 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751820AbbCDFiq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 00:38:46 -0500
In-Reply-To: <1425425520-34017-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sfeldma@gmail.com
Date: Tue,  3 Mar 2015 15:31:53 -0800

> v3:
> 
> Changes based on v2 review comments:
> 
>   - Move check for custom rules up earlier in patch set, to keep git bisect
>     safe.
>   - Simplify the route add/modify failure handling to simple try until
>     failure, and then on failure, undo everything.  The switchdev driver
>     will return err when route can normally be installed to device, but
>     the install fails for one reason or another (no space left on device,
>     etc).  If a failure happens, uninstall all routes from the device,
>     punting forwarding for all routes back to the kernel.
>   - Scan route's full nexthop list, ensuring all nexthop devs belong
>     to the same switchdev device, otherwise don't try to install route
>     to device.

Getting really close.

I think you have to make some minor adjustments to the
fib_flush_external() cases.

First of all, that code that unloads the entries from the hardware
should clear the RTNH_F_EXTERNAL flag.

Secondly, if you call fib_flush_external() because an add returned an
error, you have to set some boolean state which prevents the next new
route insert from loading only that new route into the hardware
because that's exactly what will happen with your current
implementation.

Thanks.

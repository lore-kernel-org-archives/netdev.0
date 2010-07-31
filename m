From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] Multiqueue macvtap driver
Date: Sat, 31 Jul 2010 20:18:27 +0100
Message-ID: <1280603907.13192.353.camel@localhost>
References: <20100731135743.3072.99933.sendpatchset@krkumar2.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, arnd@arndb.de, netdev@vger.kernel.org,
	mst@redhat.com
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:22490 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751083Ab0GaTSc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jul 2010 15:18:32 -0400
In-Reply-To: <20100731135743.3072.99933.sendpatchset@krkumar2.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2010-07-31 at 19:27 +0530, Krishna Kumar wrote:
[...]
> @@ -136,39 +158,68 @@ static void macvtap_put_queue(struct mac
>  }
>  
>  /*
> - * Since we only support one queue, just dereference the pointer.
> + * Select a queue based on the rxq of the device on which this packet
> + * arrived. If the incoming device is not mq, then use our cpu number
> + * to select a queue. vlan->numvtaps is cached in case it changes
> + * during the execution of this function.
>   */
[...]

This can result in reordering if a single-queue device's RX interrupt's
CPU affinity is changed.  We generally try to avoid that.  You should
really use or generate a flow hash.  There is code for this in
net/core/dev.c:get_rps_cpu() which could be factored out into a separate
function.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Adding Support for SG,GSO,GRO
Date: Thu, 09 Dec 2010 15:02:28 +0000
Message-ID: <1291906948.19763.16.camel@localhost>
References: <FCCFB4CDC6E5564B9182F639FC356087035F21D9F9@dbde02.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Govindarajan, Sriramakrishnan" <srk@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:51455 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751474Ab0LIPCb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Dec 2010 10:02:31 -0500
In-Reply-To: <FCCFB4CDC6E5564B9182F639FC356087035F21D9F9@dbde02.ent.ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-12-09 at 16:03 +0530, Govindarajan, Sriramakrishnan wrote:
> Hi
> We have a NAPI compliant driver(net/drivers/davinci_emac.c), that does
> well at 10/100Mbps loads. Now the same controller/driver is used for
> 1000Mbps
> mode as well, where the CPU gets saturated easily
> 
> Internally the module supports scatter gather DMA(which is currently not
> exercised) but there is no HW checksum support.
> 
> To specifically implement GRO, GSO support would it be sufficient to add
> SG support to the driver? Are there other means of increasing the throughput
> and decreasing the CPU loading?
[...]

On the RX side, the driver is allocating buffers and the stack doesn't
actually care whether you can do DMA scatter.  However GRO depends on
hardware checksum validation.

On the TX side, NETIF_F_SG means that the stack may include data in the
skb by reference to arbitrary pages *even if their contents are still
being changed* (think sendfile()), which means it depends on hardware
checksum generation.

So you really have no choice - you must implement hardware checksum
offload if you want any of the others.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


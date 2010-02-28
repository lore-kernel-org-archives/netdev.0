From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: GSO / TSO offload dependency
Date: Sun, 28 Feb 2010 19:30:46 +0000
Message-ID: <1267385446.2282.119.camel@localhost>
References: <de0a9dcb1002280900k728b241fyd72112defc0336ea@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: raj ravi <mekaviraj@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:52592 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936463Ab0B1Tax (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2010 14:30:53 -0500
In-Reply-To: <de0a9dcb1002280900k728b241fyd72112defc0336ea@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2010-02-28 at 22:30 +0530, raj ravi wrote:
> Hi,
> I m currently working on TSO feature in Linux network driver.
> 
> Please correct my understanding.
> 
> GSO - Generic segmentation offload - does not require any hardware support.
> 
> TSO - TCP segmentation offload  - does require hardward support
> 
> 
> Does TSO needs GSO to be turned on?  OR in other words,  can I have
> GSO disabled and TSO Enabled ?
> I beleive the code is tied between both offload...but not sure about
> the above possibility... please clarify.

Segmentation/fragmentation can be done in one of three places:
1. By the transport protocol, when constructing skbs to be queued
2. By the transport protocol, when an skb is about to be passed to the
device (enabled by NETIF_F_GSO)
3. By the device driver and hardware (enabled by NETIF_F_TSO,
NETIF_F_UFO, etc.)

Depending on the context, 'GSO' can refer either to case 2, or to both
cases 2 and 3.  TSO does not need the NETIF_F_GSO feature to be turned
on, but in some contexts it is considered to be included in GSO.

> Just before handing over the packets to the Network driver,
> segmentation is carried out a call to dev_gso_segment ( ) function.
> Given GSO is enabled, It will take care about creating TCP and other
> protocol  segments  too,  even if TSO is disabled.. ..correct ?

Correct.

> If hardware supports TSO, and  If TSO and GSO are both enabled, ...
> what will happen to segmentation assembly by means of GSO ...
> GSO will not do any segmentatoin assembly for TCP alone and will do
> for other protocols ??  bit confused here? Please clarify.

Your understanding is correct.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


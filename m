From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 RESEND] xfrm: Fix crash observed during device
 unregistration and decryption
Date: Thu, 24 Mar 2016 14:30:27 -0400 (EDT)
Message-ID: <20160324.143027.633275296533680869.davem@davemloft.net>
References: <1458794390-19788-1-git-send-email-subashab@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com,
	eric.dumazet@gmail.com, jeromes@codeaurora.org
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52126 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751108AbcCXSa3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 14:30:29 -0400
In-Reply-To: <1458794390-19788-1-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Date: Wed, 23 Mar 2016 22:39:50 -0600

> A crash is observed when a decrypted packet is processed in receive
> path. get_rps_cpus() tries to dereference the skb->dev fields but it
> appears that the device is freed from the poison pattern.
 ...
> Following are the sequence of events observed -
> 
> - Encrypted packet in receive path from netdevice is queued
> - Encrypted packet queued for decryption (asynchronous)
> - Netdevice brought down and freed
> - Packet is decrypted and returned through callback in esp_input_done
> - Packet is queued again for process in network stack using netif_rx
> 
> Since the device appears to have been freed, the dereference of
> skb->dev in get_rps_cpus() leads to an unhandled page fault
> exception.
> 
> Fix this by holding on to device reference when queueing packets
> asynchronously and releasing the reference on call back return.
> 
> v2: Make the change generic to xfrm as mentioned by Steffen and
> update the title to xfrm
> 
> Suggested-by: Herbert Xu <herbert@gondor.apana.org.au>
> Signed-off-by: Jerome Stanislaus <jeromes@codeaurora.org>
> Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>

Applied and queued up for -stable, thanks.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] altera tse: Fix network-delays and
 -retransmissions after high throughput.
Date: Thu, 16 Apr 2015 12:02:40 -0400 (EDT)
Message-ID: <20150416.120240.829328842697545698.davem@davemloft.net>
References: <1429043126-10829-1-git-send-email-ennoerlangen@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vbridger@opensource.altera.com, netdev@vger.kernel.org,
	nios2-dev@lists.rocketboards.org, ennoerlangen@gmail.com,
	andreas@oetken.name
To: ennoerlangen@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33283 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753783AbbDPQCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 12:02:42 -0400
In-Reply-To: <1429043126-10829-1-git-send-email-ennoerlangen@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Oetken <ennoerlangen@googlemail.com>
Date: Tue, 14 Apr 2015 22:25:26 +0200

> From: Andreas Oetken <andreas@oetken.name>
> 
> Fix bug which occurs when more than <limit> packets are available during napi-poll,
> leading to "delays" and retransmissions on the network.
> 
> Check for (count < limit) before checking the get_rx_status in tse_rx-function. get_rx_status is reading from the response-fifo.
> If there is currently a response in the fifo, reading the last byte of the response pops the value from the fifo.
> If the limit is check as second condition and the limit is reached the fifo is popped but the packet is not processed.
> 
> Signed-off-by: Andreas Oetken <ennoerlangen@gmail.com>

Your commit message lines are very long, format them to 80 columns
or less.

> -	while (((rxstatus = priv->dmaops->get_rx_status(priv)) != 0) &&
> -	       (count < limit))  {
> +	/* Check for limit first. get_rx_status is reading the from the
> +	* response-fifo. If there is a currently a response in the fifo,
> +	* reading the last byte of the response pops the value from the fifo.
> +	*/
> +	while ((count < limit) &&
> +		((rxstatus = priv->dmaops->get_rx_status(priv)) != 0)) {

You're corrupted the indentation.

The second line of this while statement should start precisely at
the first column after the openning parenthesis of the first line.
You must use the appropriate number of TAB then SPACE characters
necessary to achieve this.

If you are purely using TAB characters, as you have done here, for
indentation then it is very likely that you have indented things
incorrectly.

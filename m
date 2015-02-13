From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] hso: fix rx parsing logic when skb allocation fails
Date: Fri, 13 Feb 2015 07:17:29 -0800 (PST)
Message-ID: <20150213.071729.1526535214803147119.davem@davemloft.net>
References: <1423835462-3454-1-git-send-email-aleksander@aleksander.es>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	j.dumon@option.com
To: aleksander@aleksander.es
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46941 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752963AbbBMPKZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2015 10:10:25 -0500
In-Reply-To: <1423835462-3454-1-git-send-email-aleksander@aleksander.es>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aleksander Morgado <aleksander@aleksander.es>
Date: Fri, 13 Feb 2015 14:51:02 +0100

> If skb allocation fails once the IP header has been received, the rx state is
> being set to WAIT_SYNC. The logic, though, shouldn't directly return, as the
> buffer may contain a full packet, and therefore the WAIT_SYNC state needs to be
> processed (resetting state to WAIT_IP, clearing rx_buf_size and re-initializing
> rx_buf_missing).
> 
> So, just let the while loop continue so that in the next iteration the WAIT_SYNC
> state cleanly stops the loop. The WAIT_SYNC processing will be done just after
> that, only if the end of packet is flagged.
> 
> Signed-off-by: Aleksander Morgado <aleksander@aleksander.es>

Applied, thanks.

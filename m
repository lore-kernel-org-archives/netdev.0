From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Subject: Re: [PATCH v2] arc_emac: fix potential use after free
Date: Fri, 20 Dec 2013 14:06:07 +0000
Message-ID: <1387548366.32574.5.camel@abrodkin-8560l>
References: <1387504737.19078.416.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1387505440.19078.419.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"richardcochran@gmail.com" <richardcochran@gmail.com>
To: "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from us02smtp2.synopsys.com ([198.182.60.77]:34000 "EHLO
	smtp-relay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030255Ab3LTOGL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 09:06:11 -0500
In-Reply-To: <1387505440.19078.419.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Content-ID: <A2D98B9AD1461E4586284D012BE17A37@internal.synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-12-19 at 18:10 -0800, Eric Dumazet wrote:
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> 
> skb_tx_timestamp(skb) should be called _before_ TX completion
> has a chance to trigger, otherwise it is too late and we access
> freed memory.
> 
> Fixes: e4f2379db6c6 ("ethernet/arc/arc_emac - Add new driver")

Hi Eric,

thanks for this fix.

Indeed I missed this part and description of "skb_tx_timestamp" which
clearly directs to use it earlier:
=======
 * skb_tx_timestamp() - Driver hook for transmit timestamping
 *
 * Ethernet MAC Drivers should call this function in their hard_xmit()
 * function immediately before giving the sk_buff to the MAC hardware.
=======

-Alexey

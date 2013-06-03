From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] pktgen: Fix position of ip and udp header
Date: Mon, 3 Jun 2013 22:24:27 +0100
Message-ID: <20130603212427.GA14411@casper.infradead.org>
References: <10b1d385b151b94946b77183c34e34a07945983c.1370293920.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Simon Horman <horms@verge.net.au>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:49502 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755791Ab3FCVY3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 17:24:29 -0400
Content-Disposition: inline
In-Reply-To: <10b1d385b151b94946b77183c34e34a07945983c.1370293920.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/03/13 at 11:18pm, Thomas Graf wrote:
> skb_set_network_header() expects an offset based on the data pointer
> whereas skb_tail_offset() also includes the headroom. This resulted
> in the ip header being written in a wrong location.
> 
> Use return values of skb_put() directly and rely on skb->len to
> set mac, network, and transport header.
> 
> Cc: Simon Horman <horms@verge.net.au>
> Assisted-by: Daniel Borkmann <dborkmann@redhat.com>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

FYI: ipmr and netpoll may be affected as well, the code as-is
is only correct if skb->head = skb->data. Will check those
later if nobody beats me to it.

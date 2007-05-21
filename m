From: Patrick McHardy <kaber@trash.net>
Subject: Re: oops in net/ipv4/icmp.c:icmp_send() with icmp_errors_use_inbound_ifaddr
 (fwd)
Date: Mon, 21 May 2007 18:36:57 +0200
Message-ID: <4651CAA9.4050908@trash.net>
References: <E1Hpdw3-0006CY-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jmorris@namei.org, Curtis@greenkey.net,
	davem@davemloft.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59041 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755821AbXEUQjO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 May 2007 12:39:14 -0400
In-Reply-To: <E1Hpdw3-0006CY-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Patrick McHardy <kaber@trash.net> wrote:
> 
>>This leaves the question what to do in the path after ip_output,
>>when skb->dev points to the output device. We don't know the
>>input device anymore, so there doesn't seem to be a way to make
>>it do what the sysctl promises.
> 
> 
> Perhaps we could change things so that the setting of skb->dev is
> delayed until the packet has completely left the IP stack?  It'd
> require a massive audit though of the IP stack though.


The IP stack shouldn't be too hard, we currently set skb->dev in
ip_output, after that we only have the POST_ROUTING hook and ip_fragment
which care. It wouldn't help with ipip/ip_gre though, at that point
skb->dev must point to the tunnel device.


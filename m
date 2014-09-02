From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] net: Checksum offload changes - Part VI
Date: Mon, 01 Sep 2014 21:42:33 -0700 (PDT)
Message-ID: <20140901.214233.2138663914922963186.davem@davemloft.net>
References: <1409523166-9215-1-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47361 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750751AbaIBEme (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 00:42:34 -0400
In-Reply-To: <1409523166-9215-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Sun, 31 Aug 2014 15:12:40 -0700

> I am working on overhauling RX checksum offload. Goals of this effort
> are:
> 
> - Specify what exactly it means when driver returns CHECKSUM_UNNECESSARY
> - Preserve CHECKSUM_COMPLETE through encapsulation layers
> - Don't do skb_checksum more than once per packet
> - Unify GRO and non-GRO csum verification as much as possible
> - Unify the checksum functions (checksum_init)
> - Simplify code
> 
> What is in this seventh patch set:
> 
> - Add skb->csum. This allows a device or GRO to indicate that an
>   invalid checksum was detected.
> - Checksum unncessary to checksum complete conversions.
> 
> With these changes, I believe that the third goal of the overhaul is
> now mostly achieved. In the case of no encapsulation or one layer of
> encapsulation, there should only be at most one skb_checksum over
> each packet (between GRO and normal path). In the case of two layers
> of encapsulation, it is still possible with the right combination of
> non-zero and zero UDP checksums to have >1 skb_checksum. For instance:
> IP>GRE(with csum)>IP>UDP(zero csum)>VXLAN>IP>UDP(non-zero csum),
> would likely necessiate an skb_checksum in GRO and normal path.
> This doesn't seem like a common scenario at all so I'm inclined to
> not address this now, if multiple layers of encapsulation becomes
> popular we can reassess.
> 
> Note that checksum conversion shows a nice improvement for RX VXLAN when
> outer UDP checksum is enabled (12.65% CPU compared to 20.94%). This
> is not only from the fact that we don't need checksum calculation on
> the host, but also allows GRO for VXLAN in this case. Checksum
> conversion does not help send side (which still needs to perform
> a checksum on host). For that we will implement remote checksum offload
> in a later patch
> (http://tools.ietf.org/html/draft-herbert-remotecsumoffload-00).
> 
> Please review carefully and test if possible, mucking with basic
> checksum functions is always a little precarious :-)

Awesome work, I love watching infrastructure gradually fall into
place like this :-)

Series applied, thanks!

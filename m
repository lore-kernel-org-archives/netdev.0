From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] reset nf before xmit vxlan encapsulated packet
Date: Tue, 05 Mar 2013 23:56:33 -0500 (EST)
Message-ID: <20130305.235633.2031561829817668254.davem@davemloft.net>
References: <1362413254-10520-1-git-send-email-zealot0630@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: zealot0630@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60844 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752509Ab3CFE4e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 23:56:34 -0500
In-Reply-To: <1362413254-10520-1-git-send-email-zealot0630@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zang MingJie <zealot0630@gmail.com>
Date: Tue,  5 Mar 2013 00:07:34 +0800

> 
> We should reset nf settings bond to the skb as ipip/ipgre do.
> 
> If not, the conntrack/nat info bond to the origin packet may continually
> redirect the packet to vxlan interface causing a routing loop.
> 
> this is the scenario:
> 
>      VETP     VXLAN Gateway
>     /----\  /---------------\
>     |    |  |               |
>     |  vx+--+vx --NAT-> eth0+--> Internet
>     |    |  |               |
>     \----/  \---------------/
> 
> when there are any packet coming from internet to the vetp, there will be lots
> of garbage packets coming out the gateway's vxlan interface, but none actually
> sent to the physical interface, because they are redirected back to the vxlan
> interface in the postrouting chain of NAT rule, and dmesg complains:
> 
>     Mar  1 21:52:53 debian kernel: [ 8802.997699] Dead loop on virtual device vxlan0, fix it urgently!
>     Mar  1 21:52:54 debian kernel: [ 8804.004907] Dead loop on virtual device vxlan0, fix it urgently!
>     Mar  1 21:52:55 debian kernel: [ 8805.012189] Dead loop on virtual device vxlan0, fix it urgently!
>     Mar  1 21:52:56 debian kernel: [ 8806.020593] Dead loop on virtual device vxlan0, fix it urgently!
> 
> the patch should fix the problem
> 
> Signed-off-by: Zang MingJie <zealot0630@gmail.com>

Applied, thanks.

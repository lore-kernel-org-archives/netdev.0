From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vxlan: add x-netns support
Date: Thu, 24 Apr 2014 16:19:08 -0400 (EDT)
Message-ID: <20140424.161908.2156914915405212769.davem@davemloft.net>
References: <1398326569-4934-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33993 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751177AbaDXUTK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 16:19:10 -0400
In-Reply-To: <1398326569-4934-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Thu, 24 Apr 2014 10:02:49 +0200

> This patch allows to switch the netns when packet is encapsulated or
> decapsulated.
> The vxlan socket is openned into the i/o netns, ie into the netns where
> encapsulated packets are received. The socket lookup is done into this netns to
> find the corresponding vxlan tunnel. After decapsulation, the packet is
> injecting into the corresponding interface which may stand to another netns.
> 
> When one of the two netns is removed, the tunnel is destroyed.
> 
> Configuration example:
> ip netns add netns1
> ip netns exec netns1 ip link set lo up
> ip link add vxlan10 type vxlan id 10 group 239.0.0.10 dev eth0 dstport 0
> ip link set vxlan10 netns netns1
> ip netns exec netns1 ip addr add 192.168.0.249/24 broadcast 192.168.0.255 dev vxlan10
> ip netns exec netns1 ip link set vxlan10 up
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Looks good, applied, thanks Nicolas.

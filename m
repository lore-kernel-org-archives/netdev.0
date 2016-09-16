From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: VRF: Pass original iif to ip_route_input()
Date: Fri, 16 Sep 2016 04:24:48 -0400 (EDT)
Message-ID: <20160916.042448.465580563570138252.davem@davemloft.net>
References: <20160912014553.20927-1-mark.tomlinson@alliedtelesis.co.nz>
        <20160914234005.1240-1-mark.tomlinson@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dsa@cumulusnetworks.com, netdev@vger.kernel.org
To: mark.tomlinson@alliedtelesis.co.nz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38454 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757453AbcIPIY4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 04:24:56 -0400
In-Reply-To: <20160914234005.1240-1-mark.tomlinson@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Tomlinson <mark.tomlinson@alliedtelesis.co.nz>
Date: Thu, 15 Sep 2016 11:40:05 +1200

> The function ip_rcv_finish() calls l3mdev_ip_rcv(). On any VRF except
> the global VRF, this replaces skb->dev with the VRF master interface.
> When calling ip_route_input_noref() from here, the checks for forwarding
> look at this master device instead of the initial ingress interface.
> This will allow packets to be routed which normally would be dropped.
> For example, an interface that is not assigned an IP address should
> drop packets, but because the checking is against the master device, the
> packet will be forwarded.
> 
> The fix here is to still call l3mdev_ip_rcv(), but remember the initial
> net_device. This is passed to the other functions within ip_rcv_finish,
> so they still see the original interface.
> 
> Signed-off-by: Mark Tomlinson <mark.tomlinson@alliedtelesis.co.nz>
> Acked-by: David Ahern <dsa@cumulusnetworks.com>

Applied.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] veth: Be more robust on network device creation when
 no attributes
Date: Tue, 20 Jun 2017 12:40:59 -0400 (EDT)
Message-ID: <20170620.124059.822096659295374001.davem@davemloft.net>
References: <1497625500-19440-1-git-send-email-serhe.popovych@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: serhe.popovych@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37922 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750951AbdFTQlB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 12:41:01 -0400
In-Reply-To: <1497625500-19440-1-git-send-email-serhe.popovych@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Serhey Popovych <serhe.popovych@gmail.com>
Date: Fri, 16 Jun 2017 18:05:00 +0300

> There are number of problems with configuration peer
> network device in absence of IFLA_VETH_PEER attributes
> where attributes for main network device shared with
> peer.
> 
> First it is not feasible to configure both network
> devices with same MAC address since this makes
> communication in such configuration problematic.
> 
> This case can be reproduced with following sequence:
> 
>   # ip link add address 02:11:22:33:44:55 type veth
>   # ip li sh
>   ...
>   26: veth0@veth1: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc \
>   noop state DOWN mode DEFAULT qlen 1000
>       link/ether 00:11:22:33:44:55 brd ff:ff:ff:ff:ff:ff
>   27: veth1@veth0: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc \
>   noop state DOWN mode DEFAULT qlen 1000
>       link/ether 00:11:22:33:44:55 brd ff:ff:ff:ff:ff:ff
> 
> Second it is not possible to register main network device
> with given name and automatically create peer network
> device name. That happens because IFLA_IFNAME used when
> creating main and reused when creating peer.
> 
> This case can be reproduced with following sequence:
> 
>   # ip link add dev veth1a type veth
>   RTNETLINK answers: File exists
> 
> To fix both of the cases check if corresponding netlink
> attributes are taken from peer_tb when valid or
> name based on rtnl ops kind and random address is used.
> 
> Signed-off-by: Serhey Popovych <serhe.popovych@gmail.com>

This does not apply cleanly to the 'net' tree, please respin.

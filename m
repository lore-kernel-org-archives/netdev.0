From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 0/7] net: l3mdev: Support for sockets bound
 to enslaved device
Date: Mon, 07 Aug 2017 11:39:42 -0700 (PDT)
Message-ID: <20170807.113942.927598740175023982.davem@davemloft.net>
References: <1502120662-1430-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33744 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751429AbdHGSjn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 14:39:43 -0400
In-Reply-To: <1502120662-1430-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Mon,  7 Aug 2017 08:44:15 -0700

> A missing piece to the VRF puzzle is the ability to bind sockets to
> devices enslaved to a VRF. This patch set adds the enslaved device
> index, sdif, to IPv4 and IPv6 socket lookups. The end result for users
> is the following scope options for services:
> 
> 1. "global" services - sockets not bound to any device
> 
>    Allows 1 service to work across all network interfaces with
>    connected sockets bound to the VRF the connection originates
>    (Requires net.ipv4.tcp_l3mdev_accept=1 for TCP and
>     net.ipv4.udp_l3mdev_accept=1 for UDP)
> 
> 2. "VRF" local services - sockets bound to a VRF
> 
>    Sockets work across all network interfaces enslaved to a VRF but
>    are limited to just the one VRF.
> 
> 3. "device" services - sockets bound to a specific network interface
> 
>    Service works only through the one specific interface.
> 
> v3
> - convert __inet_lookup_established in dccp_v4_err; missed in v2
> 
> v2
> - remove sk_lookup struct and add sdif as an argument to existing
>   functions
> 
> Changes since RFC:
> - no significant logic changes; mainly whitespace cleanups

Series applied, let's see if it builds this time :-)

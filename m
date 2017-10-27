From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] arp: Ignore packets with an all zero sender
 mac address
Date: Fri, 27 Oct 2017 22:48:18 +0900 (KST)
Message-ID: <20171027.224818.1467938250125086766.davem@davemloft.net>
References: <887efd3fea68d2499edcc6afb35d5fe4341d93a7.1508939295.git.echaudro@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: echaudro@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49838 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750962AbdJ0NsX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 09:48:23 -0400
In-Reply-To: <887efd3fea68d2499edcc6afb35d5fe4341d93a7.1508939295.git.echaudro@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eelco Chaudron <echaudro@redhat.com>
Date: Thu, 26 Oct 2017 10:37:01 +0200

> Some applications/devices seem to forget their MAC address when
> performing some kind of a failover which triggers (something that
> looks like) a gratuities arp.
> 
> The ARP packet looks something like this:
> 
>   Address Resolution Protocol (reply)
>       Hardware type: Ethernet (1)
>       Protocol type: IPv4 (0x0800)
>       Hardware size: 6
>       Protocol size: 4
>       Opcode: reply (2)
>       Sender MAC address: 00:00:00:00:00:00
>       Sender IP address: 10.0.0.1
>       Target MAC address: 00:00:00:00:00:00
>       Target IP address: 255.255.255.255
> 
> This will result in existing arp entries being overwritten with an all
> zero mac address. Until the arp entry times out this host can no
> longer initiate a connection to this device.
> 
> Checking for and ignoring invalid mac addresses will solve this
> problem.
> 
> Signed-off-by: Eelco Chaudron <echaudro@redhat.com>

I really have trouble justifying this fully.

I looked at a bunch of ARP implementations, and I see no special
checks about the link level address other than to make sure it isn't
"our" address.

Whatever is generating these weird ARP packets should be fixed
instead.

Thank you.

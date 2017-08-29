From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: Use rt6i_idev index for echo replies to
 a local address
Date: Tue, 29 Aug 2017 15:33:16 -0700 (PDT)
Message-ID: <20170829.153316.1820450184399128262.davem@davemloft.net>
References: <1503953614-32395-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tariqt@mellanox.com
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40574 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751270AbdH2WdR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 18:33:17 -0400
In-Reply-To: <1503953614-32395-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Mon, 28 Aug 2017 13:53:34 -0700

> Tariq repored local pings to linklocal address is failing:
> $ ifconfig ens8
> ens8: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
>         inet 11.141.16.6  netmask 255.255.0.0  broadcast 11.141.255.255
>         inet6 fe80::7efe:90ff:fecb:7502  prefixlen 64  scopeid 0x20<link>
>         ether 7c:fe:90:cb:75:02  txqueuelen 1000  (Ethernet)
>         RX packets 12  bytes 1164 (1.1 KiB)
>         RX errors 0  dropped 0  overruns 0  frame 0
>         TX packets 30  bytes 2484 (2.4 KiB)
>         TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
> 
> $  /bin/ping6 -c 3 fe80::7efe:90ff:fecb:7502%ens8
> PING fe80::7efe:90ff:fecb:7502%ens8(fe80::7efe:90ff:fecb:7502) 56 data bytes
> 
> --- fe80::7efe:90ff:fecb:7502%ens8 ping statistics ---
> 3 packets transmitted, 0 received, 100% packet loss, time 2043ms
> 
> icmpv6_echo_reply needs to use the rt6i_idev dev index for local traffic
> similar to how icmp6_send does. Convert the change for icmp6_send into a
> helper that can be used in both places. Add the long over due
> skb_rt6_info helper to convert dst on an skb to rt6_info similar to
> skb_rtable for ipv4.
> 
> Fixes: 4832c30d5458 ("net: ipv6: put host and anycast routes on
>        device with address")
> Reported-by: Tariq Toukan <tariqt@mellanox.com>
> Signed-off-by: David Ahern <dsahern@gmail.com>

Applied but please do not break up Fixes: tags even if the line is
very long.

Otherwise it's a pain to grep the logs for specific multi-word string
sequences in the Fixes tag.

Thanks.

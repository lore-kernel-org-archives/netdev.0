From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv6: Use rt6i_idev index for echo replies to
 a local address
Date: Tue, 29 Aug 2017 20:18:14 -0700
Message-ID: <1504063094.11498.112.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1503953614-32395-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tariqt@mellanox.com
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:32965 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751440AbdH3DSP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 23:18:15 -0400
Received: by mail-pf0-f196.google.com with SMTP id r62so742011pfj.0
        for <netdev@vger.kernel.org>; Tue, 29 Aug 2017 20:18:15 -0700 (PDT)
In-Reply-To: <1503953614-32395-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-08-28 at 13:53 -0700, David Ahern wrote:
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

Note that the presence of this leading --- had the effect of truncating
the merged patch from this point. (all tags were ignored)

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
> ---

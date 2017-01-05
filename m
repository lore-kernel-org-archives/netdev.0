From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next V2 0/3] net/sched: act_pedit: Use offset
 relative to conventional network headers
Date: Thu, 5 Jan 2017 12:54:14 +0100
Message-ID: <20170105125414.5640b1b8@griffin>
References: <20170105095454.32644-1-amir@vadai.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Jiri Pirko <jiri@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>
To: Amir Vadai <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56780 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753625AbdAELyS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 5 Jan 2017 06:54:18 -0500
In-Reply-To: <20170105095454.32644-1-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  5 Jan 2017 11:54:51 +0200, Amir Vadai wrote:
> You asked me [1] why did I use specific header names instead of layers (L2, L3...),
> and I explained that it is on purpose, this extra information is planned to be used
> by hardware drivers to offload the action.
> 
> Some FW/HW parser APIs are such that they need to get the specific header type (e.g
> IPV4 or IPV6, TCP or UDP) and not only the networking level (e.g network or transport).

Don't we need better API specification (and enforcement) then, though?
See below.

> Usage example:
> $ tc filter add dev enp0s9 protocol ip parent ffff: \
>    flower \
>      ip_proto tcp \
>     dst_port 80 \
>    action \
>        pedit munge ip ttl add 0xff \
>        pedit munge tcp dport set 8080 \
>      pipe action mirred egress redirect dev veth0

What happens when one does:

tc filter add ... flower ip_proto udp action pedit munge tcp ...

?

 Jiri

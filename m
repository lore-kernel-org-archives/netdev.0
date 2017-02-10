From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V3 0/3] net/sched: act_pedit: Use offset
 relative to conventional network headers
Date: Fri, 10 Feb 2017 13:18:53 -0500 (EST)
Message-ID: <20170210.131853.2073979571755911124.davem@davemloft.net>
References: <20170207075608.8430-1-amir@vadai.me>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com, hadarh@mellanox.com
To: amir@vadai.me
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46030 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752217AbdBJS4Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 13:56:24 -0500
In-Reply-To: <20170207075608.8430-1-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amir@vadai.me>
Date: Tue,  7 Feb 2017 09:56:05 +0200

> Some FW/HW parser APIs are such that they need to get the specific header type (e.g
> IPV4 or IPV6, TCP or UDP) and not only the networking level (e.g network or transport).
> 
> Enhancing the UAPI to allow for specifying that, would allow the same flows to be
> set into both SW and HW.
> 
> This patchset also makes pedit more robust. Currently fields offset is specified
> by offset relative to the ip header, while using negative offsets for 
> MAC layer fields.
> 
> This series enables the user to set offset relative to the relevant header.
> 
> Usage example:
> $ tc filter add dev enp0s9 protocol ip parent ffff: \
>    flower \
>      ip_proto tcp \
>     dst_port 80 \
>    action \
>        pedit munge ip ttl add 0xff \
>        pedit munge tcp dport set 8080 \
>      pipe action mirred egress redirect dev veth0
> 
> Will forward traffic destined to tcp dport 80, while modifying the
> destination port to 8080, and decreasing the ttl by one.
> 
> I've uploaded a draft for the userspace [2] to make it easier to review and
> test the patchset.
> 
> [1] - http://patchwork.ozlabs.org/patch/700909/
> [2] - git: https://bitbucket.org/av42/iproute2.git
>       branch: pedit
> 
> Patchset was tested and applied on top of upstream commit bd092ad1463c ("Merge
> branch 'remove-__napi_complete_done'")

Series applied, thank you.

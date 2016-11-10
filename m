From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [patch net-next 5/8] Introduce sample tc action
Date: Thu, 10 Nov 2016 11:35:26 -0800
Message-ID: <5824CBFE.5030502@gmail.com>
References: <1478776988-5400-1-git-send-email-jiri@resnulli.us>
 <1478776988-5400-6-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        jhs@mojatatu.com, geert+renesas@glider.be,
        stephen@networkplumber.org, xiyou.wangcong@gmail.com,
        linux@roeck-us.net, roopa@cumulusnetworks.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33572 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752397AbcKJTfw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2016 14:35:52 -0500
Received: by mail-pf0-f194.google.com with SMTP id 144so5182779pfv.0
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 11:35:51 -0800 (PST)
In-Reply-To: <1478776988-5400-6-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-11-10 03:23 AM, Jiri Pirko wrote:
> From: Yotam Gigi <yotamg@mellanox.com>
> 
> This action allow the user to sample traffic matched by tc classifier.
> The sampling consists of choosing packets randomly, truncating them,
> adding some informative metadata regarding the interface and the original
> packet size and mark them with specific mark, to allow further tc rules to
> match and process. The marked sample packets are then injected into the
> device ingress qdisc using netif_receive_skb.
> 
> The packets metadata is packed using the ife encapsulation protocol, and
> the outer packet's ethernet dest, source and eth_type, along with the
> rate, mark and the optional truncation size can be configured from
> userspace.
> 
> Example:
> To sample ingress traffic from interface eth1, and redirect the sampled
> the sampled packets to interface dummy0, one may use the commands:
> 
> tc qdisc add dev eth1 handle ffff: ingress
> 
> tc filter add dev eth1 parent ffff: \
> 	   matchall action sample rate 12 mark 17
> 
> tc filter add parent ffff: dev eth1 protocol all \
> 	   u32 match mark 17 0xff \
> 	   action mirred egress redirect dev dummy0
> 
> Where the first command adds an ingress qdisc and the second starts
> sampling every 12'th packet on dev eth1 and marks the sampled packets with
> 17. The third command catches the sampled packets, which are marked with
> 17, and redirects them to dev dummy0.

The sampling algorithm was not randomized based on the above commit
log? It really needs to be for all the reasons Roopa mentioned earlier.
Did I miss some email on why it didn't get implemented?

Also there was an indication the already is actually implemented
correctly so don't we need the hw/sw to behave the same. The whole
argument about sw/hw parity, etc.

> 
> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---

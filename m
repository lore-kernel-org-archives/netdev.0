From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [patch net-next v2 5/8] Introduce sample tc action
Date: Wed, 16 Nov 2016 08:15:23 -0800
Message-ID: <582C861B.8010709@cumulusnetworks.com>
References: <1479135638-3580-1-git-send-email-jiri@resnulli.us> <1479135638-3580-6-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, yotamg@mellanox.com,
        idosch@mellanox.com, eladr@mellanox.com, nogahf@mellanox.com,
        ogerlitz@mellanox.com, jhs@mojatatu.com, geert+renesas@glider.be,
        stephen@networkplumber.org, xiyou.wangcong@gmail.com,
        linux@roeck-us.net, john.fastabend@gmail.com,
        simon.horman@netronome.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:33823 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751263AbcKPQP0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 11:15:26 -0500
Received: by mail-pf0-f176.google.com with SMTP id c4so31619509pfb.1
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 08:15:25 -0800 (PST)
In-Reply-To: <1479135638-3580-6-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/14/16, 7:00 AM, Jiri Pirko wrote:
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

Yotham, I am guessing in the future if one does not want to use mark,
the sample api is extensible to allow for other actions to be added.
This is from the general concern we had on using mark: some may not want to use mark.
As long as the api is extensible to allow an alternate way in the future,
 we should be good. (We would prefer to not go down the path of having to introduce
a new  'action sample' if this limits us in some way).

>
> tc filter add parent ffff: dev eth1 protocol all \
> 	   u32 match mark 17 0xff \
> 	   action mirred egress redirect dev dummy0
>

thanks.

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v5] rtnetlink: add new RTM_GETSTATS message to
 dump link stats
Date: Tue, 19 Apr 2016 12:05:00 -0700
Message-ID: <5716815C.6080601@cumulusnetworks.com>
References: <20160418.234137.26692086759328024.davem@davemloft.net> <1461040324.10638.159.camel@edumazet-glaptop3.roam.corp.google.com> <20160419.010316.1863885429013017239.davem@davemloft.net> <20160419.143134.2014460805657420897.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, jhs@mojatatu.com,
	tgraf@suug.ch, nicolas.dichtel@6wind.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35315 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754916AbcDSTFD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 15:05:03 -0400
Received: by mail-pa0-f41.google.com with SMTP id fs9so9400403pac.2
        for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 12:05:02 -0700 (PDT)
In-Reply-To: <20160419.143134.2014460805657420897.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/19/16, 11:31 AM, David Miller wrote:

[snip]
>
> Here is the final patch I'm about to push out, thanks a lot Eric.
>
> Roopa, please adjust your GETSTATS patch as needed (I think you need
> to adjust the SELinux table entry as well) and we can integrate that
> too.
ok, will do. one thing though, for GETSTATS, if I need a pad attribute like IFLA_PAD,
I will need to add a new stats attribute IFLA_STATS_PAD and burn a bit for it in filter_mask too.
In which case, I am wondering if we should live with the copy. I will take any suggestions here.

I had adjusted the SELinux table entries for v5. I will check again and make sure it is right for v6.

>
> ====================
> [PATCH] net: Align IFLA_STATS64 attributes properly on architectures that need it.
>
> Since the nlattr header is 4 bytes in size, it can cause the netlink
> attribute payload to not be 8-byte aligned.
>
> This is particularly troublesome for IFLA_STATS64 which contains 64-bit
> statistic values.
>
> Solve this by creating a dummy IFLA_PAD attribute which has a payload
> which is zero bytes in size.  When HAVE_EFFICIENT_UNALIGNED_ACCESS is
> false, we insert an IFLA_PAD attribute into the netlink response when
> necessary such that the IFLA_STATS64 payload will be properly aligned.
>
> With help and suggestions from Eric Dumazet.
>
> Signed-off-by: David S. Miller <davem@davemloft.net>
[snip]


Thanks David.

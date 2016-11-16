From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2] ipv6: sr: fix IPv6 initialization failure
 without lwtunnels
Date: Wed, 16 Nov 2016 07:49:19 -0800
Message-ID: <582C7FFF.70203@cumulusnetworks.com>
References: <5828C619.2020008@uclouvain.be> <5829C89B.7010405@cumulusnetworks.com> <582AE0B0.60006@uclouvain.be> <20161115.101857.1945116546500210861.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: david.lebrun@uclouvain.be, netdev@vger.kernel.org,
        lorenzo@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:36596 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751263AbcKPPtV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 10:49:21 -0500
Received: by mail-pg0-f44.google.com with SMTP id f188so80151982pgc.3
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 07:49:21 -0800 (PST)
In-Reply-To: <20161115.101857.1945116546500210861.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/15/16, 7:18 AM, David Miller wrote:
> From: David Lebrun <david.lebrun@uclouvain.be>
> Date: Tue, 15 Nov 2016 11:17:20 +0100
>
>> On 11/14/2016 03:22 PM, Roopa Prabhu wrote:
>>> I prefer option b). most LWTUNNEL encaps are done this way.
>>>
>>> seg6 and seg6_iptunnel is new segment routing code and can be under
>>> CONFIG_IPV6_SEG6 which depends on CONFIG_LWTUNNEL and CONFIG_IPV6.
>>> CONFIG_IPV6_SEG6_HMAC could then depend on CONFIG_IPV6_SEG6
>> Will do that, thanks
> This is good for the time being.
>
> Although I'd like to entertain the idea of making LWTUNNEL
> unconditionally built and considered a fundamental piece of
> networking infrastructure just like net/core/dst.c
ok, ack. I can submit a patch for that. But, I had the lwtunnel infra hooks in
CONFIG_LWTUNNEL to reduce the cost of hooks in the default fast path when it was not enabled.
Will need to re-evaluate the cost of the hooks in the default fast-path.

I am assuming you are ok with various encaps staying in their respective configs (mpls iptunnels, ila, and now
ipv6 segment routing).

thanks

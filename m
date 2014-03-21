From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: Re: [PATCH net] net: vxlan: fix crash when interface is created with
 no group
Date: Fri, 21 Mar 2014 12:22:35 +0200
Message-ID: <CAF1J0HPE9L1Z4xst9ap_Z8nQ9k-N-UAbW7yre0S-wvQF5+NznA@mail.gmail.com>
References: <1395055050-20874-1-git-send-email-mike.rapoport@ravellosystems.com>
	<20140320.160229.857536522237793124.davem@davemloft.net>
	<OFA209BE80.4610C3E5-ON87257CA1.00723468-87257CA1.0072346C@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f52.google.com ([209.85.219.52]:40912 "EHLO
	mail-oa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760647AbaCUKWf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2014 06:22:35 -0400
Received: by mail-oa0-f52.google.com with SMTP id l6so2249881oag.25
        for <netdev@vger.kernel.org>; Fri, 21 Mar 2014 03:22:35 -0700 (PDT)
In-Reply-To: <OFA209BE80.4610C3E5-ON87257CA1.00723468-87257CA1.0072346C@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 20, 2014 at 10:47 PM, David Stevens <dlstevens@us.ibm.com> wrote:
>
>>From: David Miller
>
>>Any objections to this? I think it maintains the pre-ipv6-support
>>behavior. I know there may be some concerns about supporting
>>multiple
>>families on the same socket, but I'm not so sure the code is able to
>>support that right now anyways.
>
> I'm ok with the idea of determining the AF from the socket -- mixed
> support, if useful, can be added later. But the patch needs to then
> check and drop packets encapsulated with the wrong address family.
>
> And it still shouldn't assume !v4 means v6.
>
> [apologies for spacing; doing this from a web browser...]
> So, I think we need something like:
>
>      if (vs->family == AF_INET && skb->protocol == ntohs(ETH_P_IP)) {
>         ....
>      } else if (vs->family == AF_INET6 && skb->protocol == ntohs(ETH_P_IPV6)) {
>         ...
>      } else
>            goto drop
>

Checking skb->protocol will drop ARP requests. What about using
ip_hdr(skb)->version?

>                                                           +-DLS
>



-- 
Sincerely yours,
Mike.

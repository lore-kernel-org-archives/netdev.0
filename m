From: pravin shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next 2/2] openvswitch: remove skb_mpls_header
Date: Thu, 29 Sep 2016 16:03:19 -0700
Message-ID: <CAOrHB_DJunwVXJse8XyVMqAxt2sf4BZ67vospaKD0Lj-6HS_yQ@mail.gmail.com>
References: <cover.1475176437.git.jbenc@redhat.com> <e32cd7d5d03b4cb86a872e76730aa29a2f7d9e38.1475176437.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Ahern <dsa@cumulusnetworks.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:42801 "EHLO
        relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932813AbcI2XDZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2016 19:03:25 -0400
Received: from mfilter37-d.gandi.net (mfilter37-d.gandi.net [217.70.178.168])
        by relay3-d.mail.gandi.net (Postfix) with ESMTP id ADCB9A80C7
        for <netdev@vger.kernel.org>; Fri, 30 Sep 2016 01:03:23 +0200 (CEST)
Received: from relay3-d.mail.gandi.net ([IPv6:::ffff:217.70.183.195])
        by mfilter37-d.gandi.net (mfilter37-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id 0EVjci2O_Ojs for <netdev@vger.kernel.org>;
        Fri, 30 Sep 2016 01:03:22 +0200 (CEST)
Received: from mail-it0-f41.google.com (mail-it0-f41.google.com [209.85.214.41])
        (Authenticated sender: pshelar@ovn.org)
        by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id 0CADBA80C8
        for <netdev@vger.kernel.org>; Fri, 30 Sep 2016 01:03:20 +0200 (CEST)
Received: by mail-it0-f41.google.com with SMTP id j69so13784404itb.0
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 16:03:20 -0700 (PDT)
In-Reply-To: <e32cd7d5d03b4cb86a872e76730aa29a2f7d9e38.1475176437.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 29, 2016 at 12:19 PM, Jiri Benc <jbenc@redhat.com> wrote:
> skb_mpls_header is equivalent to skb_network_header now. There's no reason
> to keep it.
>
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> ---
>  include/net/mpls.h        | 11 -----------
>  net/openvswitch/actions.c | 10 +++++-----
>  2 files changed, 5 insertions(+), 16 deletions(-)
>
> diff --git a/include/net/mpls.h b/include/net/mpls.h
> index 5b3b5addfb08..fde22d0b0ec1 100644
> --- a/include/net/mpls.h
> +++ b/include/net/mpls.h
> @@ -25,15 +25,4 @@ static inline bool eth_p_mpls(__be16 eth_type)
>                 eth_type == htons(ETH_P_MPLS_MC);
>  }
>
> -/*
> - * For non-MPLS skbs this will correspond to the network header.
> - * For MPLS skbs it will be before the network_header as the MPLS
> - * label stack lies between the end of the mac header and the network
> - * header. That is, for MPLS skbs the end of the mac header
> - * is the top of the MPLS label stack.
> - */
> -static inline unsigned char *skb_mpls_header(struct sk_buff *skb)
> -{
> -       return skb_mac_header(skb) + skb->mac_len;
> -}

I think we should keep this API, so that it is clear that MPLS header
mapped skb network header.

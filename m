From: pravin shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next 2/2] openvswitch: remove skb_mpls_header
Date: Fri, 30 Sep 2016 09:05:07 -0700
Message-ID: <CAOrHB_DZ3XsNzTSKD=mE2J-mcRL1q-fBi=9zBMMP4KvJq_3tGw@mail.gmail.com>
References: <cover.1475176437.git.jbenc@redhat.com> <e32cd7d5d03b4cb86a872e76730aa29a2f7d9e38.1475176437.git.jbenc@redhat.com>
 <CAOrHB_DJunwVXJse8XyVMqAxt2sf4BZ67vospaKD0Lj-6HS_yQ@mail.gmail.com> <20160930100608.1b4308b2@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Ahern <dsa@cumulusnetworks.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:36624 "EHLO
        relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932867AbcI3QFQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2016 12:05:16 -0400
Received: from mfilter26-d.gandi.net (mfilter26-d.gandi.net [217.70.178.154])
        by relay3-d.mail.gandi.net (Postfix) with ESMTP id 9FE0BA8131
        for <netdev@vger.kernel.org>; Fri, 30 Sep 2016 18:05:13 +0200 (CEST)
Received: from relay3-d.mail.gandi.net ([IPv6:::ffff:217.70.183.195])
        by mfilter26-d.gandi.net (mfilter26-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id KiwPgauRkXxI for <netdev@vger.kernel.org>;
        Fri, 30 Sep 2016 18:05:11 +0200 (CEST)
Received: from mail-it0-f52.google.com (mail-it0-f52.google.com [209.85.214.52])
        (Authenticated sender: pshelar@ovn.org)
        by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id B98A2A80EB
        for <netdev@vger.kernel.org>; Fri, 30 Sep 2016 18:05:11 +0200 (CEST)
Received: by mail-it0-f52.google.com with SMTP id j69so52597513itb.0
        for <netdev@vger.kernel.org>; Fri, 30 Sep 2016 09:05:11 -0700 (PDT)
In-Reply-To: <20160930100608.1b4308b2@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 30, 2016 at 1:06 AM, Jiri Benc <jbenc@redhat.com> wrote:
> On Thu, 29 Sep 2016 16:03:19 -0700, pravin shelar wrote:
>> > --- a/include/net/mpls.h
>> > +++ b/include/net/mpls.h
>> > @@ -25,15 +25,4 @@ static inline bool eth_p_mpls(__be16 eth_type)
>> >                 eth_type == htons(ETH_P_MPLS_MC);
>> >  }
>> >
>> > -/*
>> > - * For non-MPLS skbs this will correspond to the network header.
>> > - * For MPLS skbs it will be before the network_header as the MPLS
>> > - * label stack lies between the end of the mac header and the network
>> > - * header. That is, for MPLS skbs the end of the mac header
>> > - * is the top of the MPLS label stack.
>> > - */
>> > -static inline unsigned char *skb_mpls_header(struct sk_buff *skb)
>> > -{
>> > -       return skb_mac_header(skb) + skb->mac_len;
>> > -}
>>
>> I think we should keep this API, so that it is clear that MPLS header
>> mapped skb network header.
>
> I was pondering this but I don't think it really gains us anything.
> Wrappers like ip_hdr() are useful as they do type conversion; it's much
> nicer to write
>         ip_hdr(skb)->daddr
> than
>         (struct iphdr *)skb_network_header(skb)->daddr.
>
> But we don't really have a good type to return from skb_mpls_header, it
> boils down to be 100% equivalent to skb_network_header. In fact, you
> could just do:
> #define skb_mpls_header skb_network_header
>
I am fine with this too.

> In the code, I don't think there's much benefit from calling the
> wrapper, meaning of skb_network_header itself is clear enough. It *is*
> the network header, after all. In the whole openvswitch code, MPLS is
> treated as L3 header - no dissection is performed after the MPLS
> headers, the network header and mac_len is set as expected now, etc.
>

It makes it easier to locate which modules are using this API. That
also helps if in future we decide to change MPLS header mapping again.

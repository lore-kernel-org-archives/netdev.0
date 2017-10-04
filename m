From: Amine Kherbouche <amine.kherbouche@6wind.com>
Subject: Re: [PATCH v4 2/2] ip_tunnel: add mpls over gre encapsulation
Date: Wed, 4 Oct 2017 19:03:22 +0200
Message-ID: <56c97234-a284-53ac-ae2a-55ba07e247ec@6wind.com>
References: <cover.1506590878.git.amine.kherbouche@6wind.com>
 <2e611d0f6e0c39ff54bfe464cdf9cf6eeb7843e1.1506590878.git.amine.kherbouche@6wind.com>
 <CALx6S35b6gk39KOXTTzCFiz4S+JOOxcdJGB-+n3nx0x=xxVi8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        xeb@mail.ru, roopa <roopa@cumulusnetworks.com>, equinox@diac24.net
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:47104 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751240AbdJDRDe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 13:03:34 -0400
Received: by mail-wm0-f53.google.com with SMTP id t69so24090089wmt.2
        for <netdev@vger.kernel.org>; Wed, 04 Oct 2017 10:03:33 -0700 (PDT)
In-Reply-To: <CALx6S35b6gk39KOXTTzCFiz4S+JOOxcdJGB-+n3nx0x=xxVi8Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 09/29/2017 06:11 AM, Tom Herbert wrote:
>> > @@ -122,6 +125,30 @@ int gre_parse_header(struct sk_buff *skb, struct tnl_ptk_info *tpi,
>> >  }
>> >  EXPORT_SYMBOL(gre_parse_header);
>> >
>> > +#if IS_ENABLED(CONFIG_MPLS)
>> > +int mpls_gre_rcv(struct sk_buff *skb, int gre_hdr_len)
>> > +{
>> > +       if (unlikely(!pskb_may_pull(skb, gre_hdr_len)))
>> > +               goto drop;
>> > +
>> > +       /* Pop GRE hdr and reset the skb */
>> > +       skb_pull(skb, gre_hdr_len);
>> > +       skb_reset_network_header(skb);
>> > +
> I don't see why MPLS/GRE needs to be a special case in gre_rcv. Can't
> we just follow the normal processing patch which calls the proto ops
> handler for the protocol in the GRE header? Also, if protocol specific
> code is added to rcv function that most likely means that we need to
> update the related offloads also (grant it that MPLS doesn't support
> GRO but it looks like it supports GSO). Additionally, we'd need to
> consider if flow dissector needs a similar special case (I will point
> out that my recently posted patches there eliminated TEB as the one
> special case in GRE dissection).
>
> Thanks,
> Tom

Hi Tom,

Thanks for the feedback, I think this is the best way to do it, I'll do 
a v6 asap.

Regards,
Amine

From: Amine Kherbouche <amine.kherbouche@6wind.com>
Subject: Re: [PATCH 2/2] ip_tunnel: add mpls over gre encapsulation
Date: Fri, 22 Sep 2017 10:39:31 +0200
Message-ID: <30bfaab5-d4ba-e9bf-a4e4-f3058c71f517@6wind.com>
References: <1505985924-12479-1-git-send-email-amine.kherbouche@6wind.com>
 <1505985924-12479-3-git-send-email-amine.kherbouche@6wind.com>
 <CAJieiUicOTaxeT4t-y6QzoPibi1i7WJ31X978OP6sqjMjVuVNw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>, xeb@mail.ru,
        David Lamparter <equinox@diac24.net>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:50655 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751792AbdIVIjm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2017 04:39:42 -0400
Received: by mail-wm0-f45.google.com with SMTP id b195so1758385wmb.5
        for <netdev@vger.kernel.org>; Fri, 22 Sep 2017 01:39:42 -0700 (PDT)
In-Reply-To: <CAJieiUicOTaxeT4t-y6QzoPibi1i7WJ31X978OP6sqjMjVuVNw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 09/22/2017 12:35 AM, Roopa Prabhu wrote:
>> > diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
>> > index 36ea2ad..060ed07 100644
>> > --- a/net/mpls/af_mpls.c
>> > +++ b/net/mpls/af_mpls.c
>> > @@ -16,6 +16,7 @@
>> >  #include <net/arp.h>
>> >  #include <net/ip_fib.h>
>> >  #include <net/netevent.h>
>> > +#include <net/ip_tunnels.h>
>> >  #include <net/netns/generic.h>
>> >  #if IS_ENABLED(CONFIG_IPV6)
>> >  #include <net/ipv6.h>
>> > @@ -39,6 +40,40 @@ static int one = 1;
>> >  static int label_limit = (1 << 20) - 1;
>> >  static int ttl_max = 255;
>> >
>> > +size_t ipgre_mpls_encap_hlen(struct ip_tunnel_encap *e)
>> > +{
>> > +       return sizeof(struct mpls_shim_hdr);
>> > +}
>> > +
>> > +int ipgre_mpls_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
>> > +                           u8 *protocol, struct flowi4 *fl4)
>> > +{
>> > +       return 0;
>> > +}
>
> any reason you are supporting only rx ?

Tx path doesn't need changes, all gre hdr fields remain the same except 
for the protocol type which is loaded from skb->protocol this last is 
set by the mpls stack before entering gre device.

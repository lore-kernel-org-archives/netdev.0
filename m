From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next v2 2/7] vxlan: simplify exception handling
Date: Wed, 9 Nov 2016 19:33:24 -0800
Message-ID: <CAOrHB_AkVXDOaFKy_-ccRc--=wXG14TLfoC6Vc4HSBgjbDm3sA@mail.gmail.com>
References: <1478371557-71888-1-git-send-email-pshelar@ovn.org>
 <1478371557-71888-3-git-send-email-pshelar@ovn.org> <20161109171018.69d08ff9@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:54739 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753322AbcKJDd3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 22:33:29 -0500
Received: from mfilter20-d.gandi.net (mfilter20-d.gandi.net [217.70.178.148])
        by relay4-d.mail.gandi.net (Postfix) with ESMTP id D8E66172093
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 04:33:27 +0100 (CET)
Received: from relay4-d.mail.gandi.net ([IPv6:::ffff:217.70.183.196])
        by mfilter20-d.gandi.net (mfilter20-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id 8rK_m690RG7U for <netdev@vger.kernel.org>;
        Thu, 10 Nov 2016 04:33:26 +0100 (CET)
Received: from mail-it0-f53.google.com (mail-it0-f53.google.com [209.85.214.53])
        (Authenticated sender: pshelar@ovn.org)
        by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id 26CDB172098
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 04:33:25 +0100 (CET)
Received: by mail-it0-f53.google.com with SMTP id e187so242417175itc.0
        for <netdev@vger.kernel.org>; Wed, 09 Nov 2016 19:33:25 -0800 (PST)
In-Reply-To: <20161109171018.69d08ff9@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 9, 2016 at 8:10 AM, Jiri Benc <jbenc@redhat.com> wrote:
> On Sat,  5 Nov 2016 11:45:52 -0700, Pravin B Shelar wrote:
>> @@ -2058,7 +2059,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
>>               err = vxlan_build_skb(skb, &rt->dst, sizeof(struct iphdr),
>>                                     vni, md, flags, udp_sum);
>>               if (err < 0)
>> -                     goto xmit_tx_error;
>> +                     goto tx_error;
>
> Seems you're leaking rt here?
>
I have moved the dst error handling to vxlan_build_skb(), which is
releasing the dst entry.

>> @@ -2117,11 +2118,9 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
>>               skb_scrub_packet(skb, xnet);
>>               err = vxlan_build_skb(skb, ndst, sizeof(struct ipv6hdr),
>>                                     vni, md, flags, udp_sum);
>> -             if (err < 0) {
>> -                     dst_release(ndst);
>> -                     dev->stats.tx_errors++;
>> -                     return;
>> -             }
>> +             if (err < 0)
>> +                     goto tx_error;
>
> And ndst here?
>
same as above.

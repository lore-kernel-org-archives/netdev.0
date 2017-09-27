From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH v3 1/1] ip_tunnel: add mpls over gre encapsulation
Date: Wed, 27 Sep 2017 09:20:07 -0700
Message-ID: <CAJieiUgvHmXDmY3rvVj4u_1r=m0kOfDE_HYYYkY+Z73K9ZbwKw@mail.gmail.com>
References: <cover.1506504229.git.amine.kherbouche@6wind.com>
 <198fd7591bc1daae4727ee8b950e116b59f2d4c3.1506504229.git.amine.kherbouche@6wind.com>
 <CAJieiUgkOwJvrEq9vw+2-Up0qc9hvxt3M6LWnf8FSyx9VRX-Dw@mail.gmail.com> <1ce61dd3-293b-c26b-e173-3bdae4ba46a7@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>, xeb@mail.ru,
        David Lamparter <equinox@diac24.net>
To: Amine Kherbouche <amine.kherbouche@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f47.google.com ([209.85.213.47]:48778 "EHLO
        mail-vk0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751879AbdI0QUI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 12:20:08 -0400
Received: by mail-vk0-f47.google.com with SMTP id g69so7353021vke.5
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2017 09:20:08 -0700 (PDT)
In-Reply-To: <1ce61dd3-293b-c26b-e173-3bdae4ba46a7@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 27, 2017 at 9:08 AM, Amine Kherbouche
<amine.kherbouche@6wind.com> wrote:
>
>
> On 09/27/2017 05:36 PM, Roopa Prabhu wrote:
>>
>> Amine, one small nit here.., if you define mpls_gre_rcv in gre header
>> (like you had initially), you could do the below...
>>
>> #if IS_ENABLED(CONFIG_MPLS)
>> mpls_gre_rcv()
>> {
>>      /* real func */
>> }
>> #else
>> mpls_gre_rcv()
>> {
>>     kfree_skb(skb)
>>     return NET_RX_DROP
>> }
>> #endif
>>
>> and the check in gre_rcv() reduces to
>>
>> if (unlikely(tpi.proto == htons(ETH_P_MPLS_UC)))
>>         return mpls_gre_rcv(skb, hdr_len);
>>
>> Which looks much cleaner.
>
>
> If I do that, do I have to add back the patch that export mpls_forward() or
> just merge it with this one ?

I think its better to bring the patch back in.

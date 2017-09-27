From: Amine Kherbouche <amine.kherbouche@6wind.com>
Subject: Re: [PATCH v3 1/1] ip_tunnel: add mpls over gre encapsulation
Date: Wed, 27 Sep 2017 18:08:24 +0200
Message-ID: <1ce61dd3-293b-c26b-e173-3bdae4ba46a7@6wind.com>
References: <cover.1506504229.git.amine.kherbouche@6wind.com>
 <198fd7591bc1daae4727ee8b950e116b59f2d4c3.1506504229.git.amine.kherbouche@6wind.com>
 <CAJieiUgkOwJvrEq9vw+2-Up0qc9hvxt3M6LWnf8FSyx9VRX-Dw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>, xeb@mail.ru,
        David Lamparter <equinox@diac24.net>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:47627 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750752AbdI0QIg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 12:08:36 -0400
Received: by mail-wm0-f44.google.com with SMTP id r136so20191790wmf.2
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2017 09:08:35 -0700 (PDT)
In-Reply-To: <CAJieiUgkOwJvrEq9vw+2-Up0qc9hvxt3M6LWnf8FSyx9VRX-Dw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 09/27/2017 05:36 PM, Roopa Prabhu wrote:
> Amine, one small nit here.., if you define mpls_gre_rcv in gre header
> (like you had initially), you could do the below...
>
> #if IS_ENABLED(CONFIG_MPLS)
> mpls_gre_rcv()
> {
>      /* real func */
> }
> #else
> mpls_gre_rcv()
> {
>     kfree_skb(skb)
>     return NET_RX_DROP
> }
> #endif
>
> and the check in gre_rcv() reduces to
>
> if (unlikely(tpi.proto == htons(ETH_P_MPLS_UC)))
>         return mpls_gre_rcv(skb, hdr_len);
>
> Which looks much cleaner.

If I do that, do I have to add back the patch that export mpls_forward() 
or just merge it with this one ?

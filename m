From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: net/ipv6: slab-out-of-bounds in ip6_tnl_xmit
Date: Tue, 25 Apr 2017 14:32:47 +0200
Message-ID: <CAAeHK+z9B94iGJshTa7h++ZhS2BBqZD4GuyrNNp1awX=OKM5Tg@mail.gmail.com>
References: <CAAeHK+w-EYicrLHhBR0LHMMTc22GjsB=PTmgswm44w4VpfQ_hA@mail.gmail.com>
 <CAM_iQpXLHx=NhSNYU_o4F_V6nNXUHGBSdV=QQnML0B+HD7MbBQ@mail.gmail.com> <CAM_iQpWnPgn0+-y34nGTB0byonLWCdf3_VAKcH8tK5fdzF4CBg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f177.google.com ([209.85.161.177]:33144 "EHLO
        mail-yw0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1430396AbdDYMcu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 08:32:50 -0400
Received: by mail-yw0-f177.google.com with SMTP id 203so91974009ywe.0
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 05:32:49 -0700 (PDT)
In-Reply-To: <CAM_iQpWnPgn0+-y34nGTB0byonLWCdf3_VAKcH8tK5fdzF4CBg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 25, 2017 at 7:04 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Mon, Apr 24, 2017 at 9:47 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>
>> We use ipv4 dst in ip6_tunnel and cast an IPv4 neigh key as an
>> IPv6 address...
>>
>>
>>                 neigh = dst_neigh_lookup(skb_dst(skb),
>>                                          &ipv6_hdr(skb)->daddr);
>>                 if (!neigh)
>>                         goto tx_err_link_failure;
>>
>>                 addr6 = (struct in6_addr *)&neigh->primary_key; // <=== HERE
>>                 addr_type = ipv6_addr_type(addr6);
>>
>>                 if (addr_type == IPV6_ADDR_ANY)
>>                         addr6 = &ipv6_hdr(skb)->daddr;
>>
>>                 memcpy(&fl6->daddr, addr6, sizeof(fl6->daddr));
>>
>> Also the network header of the skb at this point should be still IPv4?
>
> Please try the attached patch.

I don't see these crashes with your patch.

Thanks!

Tested-by: Andrey Konovalov <andreyknvl@google.com>

>
> I am not sure how we could handle 4in6 case better than just relying on
> the config of ip6 tunnel.

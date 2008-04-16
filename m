From: "Ian Brown" <ianbrn@gmail.com>
Subject: Re: Why MLDv2 Report packet is freed ?
Date: Wed, 16 Apr 2008 14:50:47 +0300
Message-ID: <d0383f90804160450x31e1577en60d4a6cca29a00ca@mail.gmail.com>
References: <d0383f90804150623r2eb071fau200a67c6ce65a7e0@mail.gmail.com>
	 <20080415.234844.99535411.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "=?BIG5?B?WU9TSElGVUpJIEhpZGVha2kgLyCmTsPDrV6p+g==?="
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:34593 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758075AbYDPLut (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2008 07:50:49 -0400
Received: by fg-out-1718.google.com with SMTP id l27so2404202fgb.17
        for <netdev@vger.kernel.org>; Wed, 16 Apr 2008 04:50:48 -0700 (PDT)
In-Reply-To: <20080415.234844.99535411.yoshfuji@linux-ipv6.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I am sorry, I tried to delve into the code and I not sure I can figure out this
point.
> MLD packets are handled in other place.

Can anybody please try to elaborate on this point: how
are MLD packets handled ? Shouldn't MLD packets be
handled by pim6sd daemon? I see handlers for accepting MLD (v1 and v2)
in pim6sd daemon;
And in case MLD packets  should be handled by pim6sd  - shouldn't the kernel
pass these MLD packets to the pim6sd daemon (by calling sock_queue_rcv_skb()
in ip6mr.c) ? As far as I can understand, these MLD packets are
dropped in icmpv6_rcv()., see my
former post ;

IB

On Tue, Apr 15, 2008 at 5:48 PM, YOSHIFUJI Hideaki / 吉藤英明
<yoshfuji@linux-ipv6.org> wrote:
> In article <d0383f90804150623r2eb071fau200a67c6ce65a7e0@mail.gmail.com> (at Tue, 15 Apr 2008 16:23:33 +0300), "Ian Brown" <ianbrn@gmail.com> says:
>
>  > Now, I don't understand something here:
>  > I had looked at icmpv6_rcv() in net/ipv6/icmp.c.
>  >
>  > I see that when the type of the ICMP packet is ICMPV6_MLD2_REPORT it
>  > is dropped (calling kfree_skb()).
>  >
>  > shouldn't it be handled and passed onward so that it will
>  > eventually reach the pim6sd daemon ? or is this
>  > only implemented currently for MLDV1 ?
>
>  In MLDv1, Report suppress other hosts' reports, but
>  On the other hand, in MLDv2, Reports does not suppress.
>  So, MLDv2 Report is useless for in-kernel MLD handler.
>
>  MLD packets are handled in other place.
>
>  --yoshfuji
>

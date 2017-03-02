From: Liping Zhang <zlpnobody@gmail.com>
Subject: Re: [PATCH nf 1/1] netfilter: h323,sip: Fix possible dead loop in
 nat_rtp_rtcp and nf_nat_sdp_media
Date: Thu, 2 Mar 2017 19:18:17 +0800
Message-ID: <CAML_gOdZM8-mWXMbF7cHSo4X3zdNrytv_dTOrWvtnoxLzyP=XA@mail.gmail.com>
References: <1488441420-25537-1-git-send-email-fgao@ikuai8.com>
 <CAML_gOfLQq7Q=E+oHrXuXz=uFFMyc0rQXxGO_RTi5hXJ3AaRuw@mail.gmail.com> <CA+6hz4qO2Le_DCyuFt9zGnq2+TcR_GaDxXvSN_=1KOXYZti+iQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        David Miller <davem@davemloft.net>,
        Netfilter Developer Mailing List
        <netfilter-devel@vger.kernel.org>, coreteam@netfilter.org,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Gao Feng <fgao@ikuai8.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f181.google.com ([209.85.217.181]:36342 "EHLO
        mail-ua0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750709AbdCBLUw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Mar 2017 06:20:52 -0500
In-Reply-To: <CA+6hz4qO2Le_DCyuFt9zGnq2+TcR_GaDxXvSN_=1KOXYZti+iQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
2017-03-02 18:18 GMT+08:00 Gao Feng <fgao@ikuai8.com>:
[...]
> The expect class is NF_CT_EXPECT_CLASS_DEFAULT, and proto is
> IPPROTO_UDP at the function "expect_rtp_rtcp",
> And it makes sure the port is even number.
>
> But look at the process_gcf, the port is got from the packet data at
> function get_h225_addr.
> So it may be odd number.
> It also would add one expect node whose class is
> NF_CT_EXPECT_CLASS_DEFAULT, and proto is IPPROTO_UDP.

The nat_rtp_rtcp() is only invoked by expect_rtp_rtcp, and nf_nat_sdp_media()
is only invoked by set_expected_rtp_rtcp. So the RTP port is ensured to be
even, as well as the rtp_exp->tuple.dst.u.udp.port.

Note: the rtp_exp is alloced by nf_ct_expect_alloc, and initialized by
nf_ct_expect_init, then passed to nat_rtp_rtcp or nf_nat_sdp_media.

So I cannot figure out why process_gcf will affect this? Or I missed something?

From: Liping Zhang <zlpnobody@gmail.com>
Subject: Re: [PATCH nf 1/1] netfilter: h323,sip: Fix possible dead loop in
 nat_rtp_rtcp and nf_nat_sdp_media
Date: Thu, 2 Mar 2017 16:50:04 +0800
Message-ID: <CAML_gOfLQq7Q=E+oHrXuXz=uFFMyc0rQXxGO_RTi5hXJ3AaRuw@mail.gmail.com>
References: <1488441420-25537-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        David Miller <davem@davemloft.net>,
        Netfilter Developer Mailing List
        <netfilter-devel@vger.kernel.org>, coreteam@netfilter.org,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Feng Gao <gfree.wind@gmail.com>
To: Gao Feng <fgao@ikuai8.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f193.google.com ([209.85.217.193]:36656 "EHLO
        mail-ua0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754336AbdCBJAC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Mar 2017 04:00:02 -0500
In-Reply-To: <1488441420-25537-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

2017-03-02 15:57 GMT+08:00  <fgao@ikuai8.com>:
> From: Gao Feng <fgao@ikuai8.com>
>
> When h323 and sip try to insert expect nodes, they would increase
> the port by 2 for loop, and the loop condition is that "port != 0".
> So when the start port is odd number, port never increases to zero.

This seems will never happen, since the RTP port has been ensured to
be even.

For example, at expect_rtp_rtcp():
   ...
   /* RTP port is even */
   rtp_port = port & ~htons(1);
   rtcp_port = port | htons(1);

And at set_expected_rtp_rtcp():
   ...
   base_port = ntohs(tuple.dst.u.udp.port) & ~1;
   rtp_port = htons(base_port);

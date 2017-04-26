From: Craig Gallek <kraigatgoog@gmail.com>
Subject: Re: [PATCH net-next] ip6_tunnel: Fix missing tunnel encapsulation
 limit option
Date: Wed, 26 Apr 2017 13:59:19 -0400
Message-ID: <CAEfhGiyTGS_ccz1mQquk3VYTG_3eU4+4s+wQpMffRMUaBEcLaQ@mail.gmail.com>
References: <20170426170707.165201-1-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:34862 "EHLO
        mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932497AbdDZR7W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 13:59:22 -0400
Received: by mail-qk0-f181.google.com with SMTP id f76so7726636qke.2
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 10:59:21 -0700 (PDT)
Received: from mail-qt0-f170.google.com (mail-qt0-f170.google.com. [209.85.216.170])
        by smtp.gmail.com with ESMTPSA id k86sm719320qkh.12.2017.04.26.10.59.20
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Apr 2017 10:59:20 -0700 (PDT)
Received: by mail-qt0-f170.google.com with SMTP id y33so7328437qta.2
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 10:59:20 -0700 (PDT)
In-Reply-To: <20170426170707.165201-1-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 26, 2017 at 1:07 PM, Craig Gallek <kraigatgoog@gmail.com> wrote:
> From: Craig Gallek <kraig@google.com>
>
> The IPv6 tunneling code tries to insert IPV6_TLV_TNL_ENCAP_LIMIT and
> IPV6_TLV_PADN options when an encapsulation limit is defined (the
> default is a limit of 4).  An MTU adjustment is done to account for
> these options as well.  However, the options are never present in the
> generated packets.
>
> ipv6_push_nfrag_opts requires that IPV6_RTHDR be present in order to
> include any IPV6_DSTOPTS options.  The v6 tunnel code does not
> use routing options, so the encap limit options are not included.
>
> A brief reading of RFC 3542 section 9.2 (specifically the 4th paragraph)
> makes me believe that this requirement in the kernel is incorrect.
Looking more closely, I think I'm wrong here.  Specifically, the cmsg
parser puts IPV6_RTHDRDSTOPTS in dst0opt and IPV6_DSTOPTS in dst1opt.
The tunnel code is currently building dst0opt and using
ipv6_push_nfrag_opts.  Perhaps it should be building dst1opt and
calling ipv6_push_frag_opts?

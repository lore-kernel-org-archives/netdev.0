From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: ipv6: handle -EFAULT from skb_copy_bits
Date: Tue, 20 Dec 2016 22:09:49 -0800
Message-ID: <CAM_iQpXWCWMKDjLVTLuHNSKKGq5MWf5ZRLpyE=PDD3EgQ7PS4Q@mail.gmail.com>
References: <20161219.144848.736886978545428136.davem@davemloft.net>
 <20161220003144.omoqyghgdfbxdyuu@codemonkey.org.uk> <20161220004013.43pcopemc6im32az@codemonkey.org.uk>
 <20161219.203623.119653805184192345.davem@davemloft.net> <20161220181728.dd2cynjwrceruwcu@codemonkey.org.uk>
 <CAM_iQpUgqJEG544HqH1iwdQFL9-nV3-hMuuH_eU9OnJ--pX+jg@mail.gmail.com> <20161220221214.w3zerfiy4wu6apee@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Dave Jones <davej@codemonkey.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f174.google.com ([209.85.216.174]:35798 "EHLO
        mail-qt0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754020AbcLUGKL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 01:10:11 -0500
Received: by mail-qt0-f174.google.com with SMTP id c47so197485365qtc.2
        for <netdev@vger.kernel.org>; Tue, 20 Dec 2016 22:10:10 -0800 (PST)
In-Reply-To: <20161220221214.w3zerfiy4wu6apee@codemonkey.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 20, 2016 at 2:12 PM, Dave Jones <davej@codemonkey.org.uk> wrote:
>         fd = socket(AF_INET6, SOCK_RAW, 7);
>
>         setsockopt(fd, SOL_IPV6, IPV6_CHECKSUM, &zero, 4);
>         setsockopt(fd, SOL_IPV6, IPV6_DSTOPTS, &buf, LEN);
>

Interesting, you set the checksum offset to be 0, but the packet size
is actually 49, transport header is located at offset 48, so apparently
the packet doesn't have room for a 16bit checksum after network header.

Your original patch seems reasonable to me, unless there is some
check in __ip6_append_data() which is supposed to catch this, but
CHECKSUM is specific to raw socket only.

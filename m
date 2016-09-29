From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH RFC iproute2] iplink: Support envhdrlen
Date: Thu, 29 Sep 2016 14:49:44 +0200
Message-ID: <20160929144944.609d5434@griffin>
References: <1474966541-4420-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
        <1474966541-4420-5-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Vlad Yasevich <vyasevich@gmail.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50054 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752479AbcI2Mts (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 29 Sep 2016 08:49:48 -0400
In-Reply-To: <1474966541-4420-5-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 27 Sep 2016 17:55:40 +0900, Toshiaki Makita wrote:
> This adds support for envhdrlen.
> 
> Example:
>  # ip link set eno1 envhdrlen 8

I don't see why this should be user visible, let alone requiring user
to set it. This should be transparent, kernel should compute the value
as needed based on the configuration and set it up. Requiring the
administrator to pick up a calculator and sum up all the vlan, mpls and
whatever header lengths is silly.

I realize that we currently have no easy way to do that. Especially
with lwtunnels and stuff line MPLS where we don't easily know the
number of tags. But every uAPI we introduce will have to be supported
forever and going a particular way just because it is easy to implement
is not sustainable.

At the very least, it should be configurable from the other direction.
I.e. telling which interfaces can be used by vlans or MPLS (if it
cannot be inferred automatically) and configuring maximum number of
tags on the given vlan/mpls/whatever interface/route/whatever.

 Jiri

From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net] ipv6: release rt6->rt6i_idev properly during ifdown
Date: Mon, 14 Aug 2017 13:05:16 -0600
Message-ID: <6e1bb883-8d44-fcf6-4d2e-6c1ccd0ca95e@gmail.com>
References: <20170814174459.3569-1-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Martin KaFai Lau <kafai@fb.com>
To: Wei Wang <weiwan@google.com>, David Miller <davem@davemloft.net>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34300 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750989AbdHNTFS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2017 15:05:18 -0400
Received: by mail-pg0-f67.google.com with SMTP id y192so12018657pgd.1
        for <netdev@vger.kernel.org>; Mon, 14 Aug 2017 12:05:18 -0700 (PDT)
In-Reply-To: <20170814174459.3569-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/14/17 11:44 AM, Wei Wang wrote:
> From: Wei Wang <weiwan@google.com>
> 
> When a dst is created by addrconf_dst_alloc() for a host route or an
> anycast route, dst->dev points to loopback dev while rt6->rt6i_idev
> points to a real device.
> When the real device goes down, the current cleanup code only checks for
> dst->dev and assumes rt6->rt6i_idev->dev is the same. This causes the
> refcount leak on the real device in the above situation.
> This patch makes sure to always release the refcount taken on
> rt6->rt6i_idev during dst_dev_put().
> 
> Fixes: 587fea741134 ("ipv6: mark DST_NOGC and remove the operation of
> dst_free()")
> Reported-by: John Stultz <john.stultz@linaro.org>
> Tested-by: John Stultz <john.stultz@linaro.org>
> Tested-by: Martin KaFai Lau <kafai@fb.com>
> Signed-off-by: Wei Wang <weiwan@google.com>
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>
> ---
>  net/ipv6/route.c | 13 +++++--------
>  1 file changed, 5 insertions(+), 8 deletions(-)

Acked-by: David Ahern <dsahern@gmail.com>

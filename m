From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: release rt6->rt6i_idev properly during ifdown
Date: Mon, 14 Aug 2017 22:19:45 -0700 (PDT)
Message-ID: <20170814.221945.1039673650891799146.davem@davemloft.net>
References: <20170814174459.3569-1-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kafai@fb.com, dsahern@gmail.com
To: weiwan@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50536 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752977AbdHOFTq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 01:19:46 -0400
In-Reply-To: <20170814174459.3569-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>
Date: Mon, 14 Aug 2017 10:44:59 -0700

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

Applied, thank you.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: vrf: Reset rt6i_idev in local dst after put
Date: Tue, 21 Mar 2017 17:51:25 -0700 (PDT)
Message-ID: <20170321.175125.405948588572698532.davem@davemloft.net>
References: <1489792031-13547-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59394 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751042AbdCVBBm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 21:01:42 -0400
In-Reply-To: <1489792031-13547-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Fri, 17 Mar 2017 16:07:11 -0700

> The VRF driver takes a reference to the inet6_dev on the VRF device for
> its rt6_local dst when handling local traffic through the VRF device as
> a loopback. When the device is deleted the driver does a put on the idev
> but does not reset rt6i_idev in the rt6_info struct. When the dst is
> destroyed, dst_destroy calls ip6_dst_destroy which does a second put for
> what is essentially the same reference causing it to be prematurely freed.
> Reset rt6i_idev after the put in the vrf driver.
> 
> Fixes: b4869aa2f881e ("net: vrf: ipv6 support for local traffic to
>                        local addresses")
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied and queued up for -stable.

From: Eli Cooper <elicooper@gmx.com>
Subject: Re: Large performance regression with 6in4 tunnel (sit)
Date: Fri, 25 Nov 2016 14:05:04 +0800
Message-ID: <a4a7b888-04d1-55ce-28de-cc15f01a15fc@gmx.com>
References: <20161125120947.142c3af5@canb.auug.org.au>
 <cf2fff0a-7d41-1416-0056-3718ea50a5bd@gmx.com>
 <20161125134520.68ca0969@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.21]:55636 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751645AbcKYGF5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 25 Nov 2016 01:05:57 -0500
In-Reply-To: <20161125134520.68ca0969@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

On 2016/11/25 10:45, Stephen Rothwell wrote:
> Hi Eli,
>
> On Fri, 25 Nov 2016 10:18:12 +0800 Eli Cooper <elicooper@gmx.com> wrote:
>> Sounds like TSO/GSO packets are not properly segmented and therefore
>> dropped.
>>
>> Could you first try turning off segmentation offloading for the tunnel
>> interface?
>>     ethtool -K sit0 tso off gso off
> On Thu, 24 Nov 2016 18:30:14 -0800 Eric Dumazet <eric.dumazet@gmail.com>
>> You also could try to disable TSO and see if this makes a difference
>>
>> ethtool -K sixtofour0 tso off
> So turning off tso brings performance up to IPv4 levels ...
>
> Thanks for that, it solves my immediate problem.

I think this is similar to the bug I fixed in commit ae148b085876
("ip6_tunnel: Update skb->protocol to ETH_P_IPV6 in ip6_tnl_xmit()").

I can reproduce a similar problem by applying xfrm to sit traffic.
TSO/GSO packets are dropped when IPSec is enabled, and IPv6 throughput
drops to 10s of Kbps. I am not sure if this is the same issue you
experienced, but I wrote a patch that fixed at least the issue I had.

Could you test the patch I sent to the mailing list just now?

Thanks,
Eli

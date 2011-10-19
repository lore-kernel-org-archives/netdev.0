From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH 1/4] ipv4: Fix pmtu propagating
Date: Wed, 19 Oct 2011 17:07:50 +0800
Message-ID: <4E9E9366.1050702@cn.fujitsu.com>
References: <20111011110922.GD1830@secunet.com> <20111012.170218.279202034199478303.davem@davemloft.net> <20111013100950.GO1830@secunet.com> <20111013.135808.636341622629050648.davem@davemloft.net> <20111014055406.GP1830@secunet.com> <20111017121805.GR1830@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57097 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752789Ab1JSJHX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Oct 2011 05:07:23 -0400
In-Reply-To: <20111017121805.GR1830@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011.10.17 20:18, Steffen Klassert wrote:
> On Fri, Oct 14, 2011 at 07:54:06AM +0200, Steffen Klassert wrote:
>> On Thu, Oct 13, 2011 at 01:58:08PM -0400, David Miller wrote:
>>>
>>> Please find out exactly why dst->obsolete is non-zero on a freshly
>>> looked up route.  It's unexpected.
>>
>> Hm, on a slow path route lookup e.g. __mkroute_output() calls
>> rt_dst_alloc() which initializes dst->obsolete to -1.
> 
> Just a follow up:
> git commit d11a4dc18 (ipv4: check rt_genid in dst_check)
> changed the initialization value of dst->obsolete from
> 0 to -1.
> --

Anybody give any suggestion?
Actually,we can't suppose the dst->obsolete is non-zero.
maybe we should use both dst->obsolete and rt->rt_peer_genid to decide whether to do dst_check or not?

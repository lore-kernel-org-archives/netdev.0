From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH V2] ipv6: fix race condition regarding dst->expires and
 dst->from.
Date: Wed, 20 Feb 2013 08:12:40 -0800
Message-ID: <1361376760.19353.185.camel@edumazet-glaptop>
References: <5124A48F.3060907@linux-ipv6.org>
	 <5124A574.5030904@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Gao Feng <gaofeng@cn.fujitsu.com>, netdev@vger.kernel.org,
	davem@davemloft.net, "Steinar H. Gunderson" <sesse@google.com>
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:63679 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964794Ab3BTQMn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2013 11:12:43 -0500
Received: by mail-pb0-f47.google.com with SMTP id rp2so2944152pbb.20
        for <netdev@vger.kernel.org>; Wed, 20 Feb 2013 08:12:43 -0800 (PST)
In-Reply-To: <5124A574.5030904@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-02-20 at 19:29 +0900, YOSHIFUJI Hideaki wrote:
> Eric Dumazet wrote:
> | Some strange crashes happen in rt6_check_expired(), with access
> | to random addresses.
> |
> | At first glance, it looks like the RTF_EXPIRES and
> | stuff added in commit 1716a96101c49186b
> | (ipv6: fix problem with expired dst cache)
> | are racy : same dst could be manipulated at the same time
> | on different cpus.
> |
> | At some point, our stack believes rt->dst.from contains a dst pointer,
> | while its really a jiffie value (as rt->dst.expires shares the same area
> | of memory)
> |
> | rt6_update_expires() should be fixed, or am I missing something ?
> |
> | CC Neil because of https://bugzilla.redhat.com/show_bug.cgi?id=892060
> 
> Because we do not have any locks for dst_entry, we cannot change
> essential structure in the entry; e.g., we cannot change reference
> to other entity.
> 
> To fix this issue, split 'from' and 'expires' field in dst_entry
> out of union.  Once it is 'from' is assigned in the constructor,
> keep the reference until the very last stage of the life time of
> the object.
> 
> Of course, it is unsafe to change 'from', so make rt6_set_from simple
> just for fresh entries.
> 
> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> Reported-by: Neil Horman <nhorman@tuxdriver.com>
> CC: Gao Feng <gaofeng@cn.fujitsu.com>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> ---

This seems good to me, but I cant test it at this moment.

I CC Steinar as he reported one crash to me.

Thanks Yoshifuji !

Reviewed-by: Eric Dumazet <edumazet@google.com>

Reported-by: Steinar H. Gunderson <sesse@google.com>

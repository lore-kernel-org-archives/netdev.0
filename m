From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6: Fix NULL dereference in ipv6_del_addr()
Date: Fri, 17 Nov 2006 23:26:23 +0900 (JST)
Message-ID: <20061117.232623.61341274.yoshfuji@linux-ipv6.org>
References: <455DB884.3050203@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:34688 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S933620AbWKQO03
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Nov 2006 09:26:29 -0500
To: vnuorval@tcs.hut.fi
In-Reply-To: <455DB884.3050203@tcs.hut.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <455DB884.3050203@tcs.hut.fi> (at Fri, 17 Nov 2006 15:26:28 +0200), Ville Nuorvala <vnuorval@tcs.hut.fi> says:


> -		dst_release(&rt->u.dst);
> +		if (rt)
> +			dst_release(&rt->u.dst);
>  	}

I disagree.  This does NOT fix any bugs.

(void *)&rt->u.dst is ever equal to (void*)rt, and
dst_release() checks if the argument is NULL.

--yoshfuji

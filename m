From: David Miller <davem@davemloft.net>
Subject: Re: [Patch iproute2] ipaddress: do not add ifa_flags when not
 necessary
Date: Fri, 04 Apr 2014 09:59:05 -0400 (EDT)
Message-ID: <20140404.095905.2169727474578538143.davem@davemloft.net>
References: <1396591503-16632-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	stephen@networkplumber.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51879 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752473AbaDDN5a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2014 09:57:30 -0400
In-Reply-To: <1396591503-16632-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Thu,  3 Apr 2014 23:05:03 -0700

> commit 37c9b94ed21d5779acc23d89a4 (add support for extended ifa_flags)
> introduced a regression:
> 
> 	# ./ip/ip addr add 192.168.0.1/24 dev eth0
> 	RTNETLINK answers: Invalid argument
> 
> This is due to old kernels don't support IFA_FLAGS flag, it should be skipped
> if we don't use this feature at all.
> 
> Cc: Jiri Pirko <jiri@resnulli.us>
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Your patch doesn't really fully fix the problem.

If the kernel rejects because of presence of the IFA_FLAGS attribute,
it will do so for all such cases.

Therefore the guard you need is not whether ifa_flags is NULL, but
whether a large enough flag bit is set such that IFA_FLAGS is required.

IFA_FLAGS was added because ifa.ifa_flags is too small for the new
values we needed to add.

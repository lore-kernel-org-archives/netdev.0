From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [2.6 PATCH] IPV6: Check length of optval provided by user in
 setsockopt()
Date: Mon, 31 Mar 2008 19:53:23 +0900 (JST)
Message-ID: <20080331.195323.83430743.yoshfuji@linux-ipv6.org>
References: <47F0AA16.1070900@cn.fujitsu.com>
	<20080331.181551.118587102.yoshfuji@linux-ipv6.org>
	<47F0C101.9090302@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:55666 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752054AbYCaKvu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2008 06:51:50 -0400
In-Reply-To: <47F0C101.9090302@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <47F0C101.9090302@cn.fujitsu.com> (at Mon, 31 Mar 2008 18:46:25 +0800), Wang Chen <wangchen@cn.fujitsu.com> says:

> YOSHIFUJI Hideaki / 吉藤英明 said the following on 2008-3-31 17:15:
> > In article <47F0AA16.1070900@cn.fujitsu.com> (at Mon, 31 Mar 2008 17:08:38 +0800), Wang Chen <wangchen@cn.fujitsu.com> says:
> > 
> >> Check length of setsockopt's optval, which provided by user, before copy it
> >> from user space.
> > 
> > Please use "<" not "==".
> > 
> 
> There are two reasons that why I only check whether
> len of optval is equal to that one in user space.
> 1. We currently copy the entire structure from user
>    to kernel.
> 2. In other cases, such as IPV6_LEAVE/JOIN_ANYCAST,
>    we check whether the len is equal to struct's len.
> 
> So, Yoshifuji-san, can you tell me more about why we
> should use "<"? :)

POSIX, as we have some comments in that file ;-).
If it is shorter than expected, -EINVAL, otherwise, no error.
We need to fix other sites as well.

--yoshfuji

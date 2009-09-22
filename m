From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ipv4: fix do_ip_setsockopt optlen check for
 IP_MULTICAST_IF
Date: Tue, 22 Sep 2009 13:38:19 -0700 (PDT)
Message-ID: <20090922.133819.173686372.davem@davemloft.net>
References: <1253164784-15789-1-git-send-email-dfeng@redhat.com>
	<4AB1FE2A.1060906@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dfeng@redhat.com, kaber@trash.net, yoshfuji@linux-ipv6.org,
	jmorris@namei.org, pekkas@netcore.fi, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: shanwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40264
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752262AbZIVUiA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2009 16:38:00 -0400
In-Reply-To: <4AB1FE2A.1060906@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <shanwei@cn.fujitsu.com>
Date: Thu, 17 Sep 2009 17:15:22 +0800

> Xiaotian Feng wrote, at 09/17/2009 01:19 PM:
>> Due to man page of setsockopt, if optlen is not valid, kernel should return
>> -EINVAL. But a simple testcase as following, errno is 0, which means setsockopt
>> is successful.
>> 
>>         addr.s_addr = inet_addr("192.1.2.3");
>>         setsockopt(s, IPPROTO_IP, IP_MULTICAST_IF, &addr, 1);
>> 	printf("errno is %d\n", errno);
>> 
>> This patch fixes the optlen check part, with the patch, we got errno EINVAL.
>> 
> 
> I also think it's a bug, the freebsd also does the optlen check. 
> But the style should be coincident with other option: firstly check the
> availability of optlen, then copy option value from user and deal with it.   
> 
> How about this one:

This definitely is better and cleaner, but please don't post such
things without proper signoffs and commit messages because now
I have to ask you to do that instead of me just applying your
patch :-/

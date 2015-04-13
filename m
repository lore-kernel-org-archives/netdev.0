From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v2 0/5] fou: some fixes and updates
Date: Sun, 12 Apr 2015 21:25:54 -0400 (EDT)
Message-ID: <20150412.212554.737999932991161774.davem@davemloft.net>
References: <1428692430-14465-1-git-send-email-xiyou.wangcong@gmail.com>
	<CALx6S37WGT7p=ZMLc+ZOiXmvjQxaxG+k6yR2m2h9SEn5Av5xjg@mail.gmail.com>
	<CAHA+R7MLifECseX=R4R6ZSz=JYhBBcNrqkSpu51rQ833OKXdjg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, xiyou.wangcong@gmail.com,
	netdev@vger.kernel.org
To: cwang@twopensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48258 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752538AbbDMBZ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Apr 2015 21:25:56 -0400
In-Reply-To: <CAHA+R7MLifECseX=R4R6ZSz=JYhBBcNrqkSpu51rQ833OKXdjg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <cwang@twopensource.com>
Date: Fri, 10 Apr 2015 13:50:55 -0700

> On Fri, Apr 10, 2015 at 1:38 PM, Tom Herbert <tom@herbertland.com> wrote:
>> On Fri, Apr 10, 2015 at 12:00 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>> Patch 1~3 fix some minor bugs in net/ipv4/fou.c, the only
>>> thing I am not sure is if it's too late to change the
>>> byte order of FOU_ATTR_PORT, if so we have to fix iproute2
>>> instead of kernel.
>>>
>> Is this a relic from previous patch set, or is there a reason you want
>> to make this hbo?
> 
> I was referring to this change:
> 
> -               u16 port = nla_get_u16(info->attrs[FOU_ATTR_PORT]);
> +               __be16 port = nla_get_be16(info->attrs[FOU_ATTR_PORT]);
> 
> I meant I am not sure if this breaks ABI here even in v2, we
> just use the raw value passed from user-space, so probably
> we are safe.

This is fine, there is no byte swapping done by nla_get_be16() so the
bits used are exactly the same.

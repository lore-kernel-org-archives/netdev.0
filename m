From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/4] libnl: enhance API to ease 64bit
 alignment for attribute
Date: Thu, 21 Apr 2016 14:28:31 -0400 (EDT)
Message-ID: <20160421.142831.1815562418742721577.davem@davemloft.net>
References: <1461142655-5067-1-git-send-email-nicolas.dichtel@6wind.com>
	<1461257907-4458-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	eric.dumazet@gmail.com, tgraf@suug.ch, jhs@mojatatu.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54299 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752118AbcDUS2d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 14:28:33 -0400
In-Reply-To: <1461257907-4458-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Thu, 21 Apr 2016 18:58:23 +0200

> Here is a proposal to add more helpers in the libnetlink to manage 64-bit
> alignment issues.
> Note that this series was only tested on x86 by tweeking
> CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS and adding some traces.
> 
> The first patch adds helpers for 64bit alignment and other patches
> use them.
> 
> We could also add helpers for nla_put_u64() and its variants if needed.
> 
> v1 -> v2:
>  - remove patch #1
>  - split patch #2 (now #1 and #2)
>  - add nla_need_padding_for_64bit()

I like it, nice work Nicolas.

Applied to net-next.

I did a quick scan and the following jumped out at me as cases we need
to fix up as well:

1) xfrm_user
2) tcp_info
3) taskstats
4) pkt_{cls,sched}
5) openvswitch
etc.

Most of these are statistic cases just like all of the existing ones
we have fixed so far.

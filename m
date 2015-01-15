From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH net-next v13 0/3] add hisilicon hip04 ethernet driver
Date: Thu, 15 Jan 2015 10:42:17 +0100
Message-ID: <14674609.dERhba4yMV@wuerfel>
References: <1421217254-12008-1-git-send-email-dingtianhong@huawei.com> <54B642B4.8010807@suse.de> <54B77C43.6010200@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Alexander Graf <agraf@suse.de>, robh+dt@kernel.org,
	davem@davemloft.net, grant.likely@linaro.org,
	sergei.shtylyov@cogentembedded.com,
	linux-arm-kernel@lists.infradead.org, eric.dumazet@gmail.com,
	xuwei5@hisilicon.com, zhangfei.gao@linaro.org,
	netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux@arm.linux.org.uk
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.187]:63153 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751403AbbAOJnf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 04:43:35 -0500
In-Reply-To: <54B77C43.6010200@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 15 January 2015 16:37:23 Ding Tianhong wrote:
> On 2015/1/14 18:19, Alexander Graf wrote:
> > 
> >>From a 10000 feet perspective it looks like two problems to me
> > 
> >   1) Allocation failure doesn't get handled properly somewhere

This is the bug that Eric pointed out as well.

> >   2) We fail to allocate with order=0 - I don't see why

GFP_ATOMIC. When allocating from a the napi poll function in softirq
context, you have to use nonblocking allocations, which occasionally
fail. This should not cause any harm other than dropped packets.

> is it easy to repetition this bug? how big is your memory on your board,
> is it happened in your previous hip04 driver?

It should be independent of memory size, but may be more likely if you
don't have swap space configured.

	Arnd

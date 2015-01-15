From: Alexander Graf <agraf@suse.de>
Subject: Re: [PATCH net-next v13 0/3] add hisilicon hip04 ethernet driver
Date: Thu, 15 Jan 2015 13:39:03 +0100
Message-ID: <54B7B4E7.8030108@suse.de>
References: <1421217254-12008-1-git-send-email-dingtianhong@huawei.com> <54B642B4.8010807@suse.de> <54B77C43.6010200@huawei.com> <14674609.dERhba4yMV@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: robh+dt@kernel.org, davem@davemloft.net, grant.likely@linaro.org,
	sergei.shtylyov@cogentembedded.com,
	linux-arm-kernel@lists.infradead.org, eric.dumazet@gmail.com,
	xuwei5@hisilicon.com, zhangfei.gao@linaro.org,
	netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux@arm.linux.org.uk
To: Arnd Bergmann <arnd@arndb.de>,
	Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:49180 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752320AbbAOMjI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2015 07:39:08 -0500
In-Reply-To: <14674609.dERhba4yMV@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 15.01.15 10:42, Arnd Bergmann wrote:
> On Thursday 15 January 2015 16:37:23 Ding Tianhong wrote:
>> On 2015/1/14 18:19, Alexander Graf wrote:
>>>
>>> >From a 10000 feet perspective it looks like two problems to me
>>>
>>>   1) Allocation failure doesn't get handled properly somewhere
> 
> This is the bug that Eric pointed out as well.
> 
>>>   2) We fail to allocate with order=0 - I don't see why
> 
> GFP_ATOMIC. When allocating from a the napi poll function in softirq
> context, you have to use nonblocking allocations, which occasionally
> fail. This should not cause any harm other than dropped packets.
> 
>> is it easy to repetition this bug? how big is your memory on your board,
>> is it happened in your previous hip04 driver?
> 
> It should be independent of memory size, but may be more likely if you
> don't have swap space configured.

With the previous driver I was unable to get this far - I ended up in
random memory corruption and had a ~90% packet loss after about an hour
of uptime.

I'm not sure whether it's easy to reproduce, I merely started up a few
VMs, did some disk I/O and started to compile QEMU in the background ;).

I'll happily give your follow up patch that's going to fix the memory
allocation problems a try though.


Alex

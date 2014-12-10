From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v8 3/3] net: hisilicon: new hip04 ethernet driver
Date: Wed, 10 Dec 2014 11:07:32 -0500 (EST)
Message-ID: <20141210.110732.519666115784722516.davem@davemloft.net>
References: <5487C357.9030507@huawei.com>
	<5487EC09.8090907@huawei.com>
	<2331317.LV3gPP3odb@wuerfel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dingtianhong@huawei.com, agraf@suse.de, zhangfei.gao@linaro.org,
	linux@arm.linux.org.uk, f.fainelli@gmail.com,
	sergei.shtylyov@cogentembedded.com, mark.rutland@arm.com,
	David.Laight@aculab.com, eric.dumazet@gmail.com,
	xuwei5@hisilicon.com, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, devicetree@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45382 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932180AbaLJQHl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 11:07:41 -0500
In-Reply-To: <2331317.LV3gPP3odb@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 10 Dec 2014 10:35:20 +0100

> On Wednesday 10 December 2014 14:45:29 Ding Tianhong wrote:
>> 
>> Miss this code, I think the best way is skb_orphan(skb), just like the cxgb3 drivers, some hardware
>> didn't use the tx inq to free dmad Tx packages.
> 
> The problem with skb_orphan is that you are telling the network stack that
> the packet is now out of its reach and it will no longer be able to take
> queued packets into account.

skb_orphan() also does not release netfilter resources attached to the
packet.

Really, all drivers must free TX SKBs in a small, finite, amount of
time after submission.

There is no way around this.

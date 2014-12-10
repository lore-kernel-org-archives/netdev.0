From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v8 3/3] net: hisilicon: new hip04 ethernet driver
Date: Wed, 10 Dec 2014 17:36:46 +0100
Message-ID: <34612839.hAkXUcbKUQ@wuerfel>
References: <5487C357.9030507@huawei.com> <2331317.LV3gPP3odb@wuerfel> <20141210.110732.519666115784722516.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: David Miller <davem@davemloft.net>, mark.rutland@arm.com,
	devicetree@vger.kernel.org, f.fainelli@gmail.com,
	linux@arm.linux.org.uk, eric.dumazet@gmail.com,
	sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org,
	agraf@suse.de, xuwei5@hisilicon.com, David.Laight@aculab.com,
	dingtianhong@huawei.com, zhangfei.gao@linaro.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.131]:49660 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755136AbaLJQhV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 11:37:21 -0500
In-Reply-To: <20141210.110732.519666115784722516.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 10 December 2014 11:07:32 David Miller wrote:
> From: Arnd Bergmann <arnd@arndb.de>
> Date: Wed, 10 Dec 2014 10:35:20 +0100
> 
> > On Wednesday 10 December 2014 14:45:29 Ding Tianhong wrote:
> >> 
> >> Miss this code, I think the best way is skb_orphan(skb), just like the cxgb3 drivers, some hardware
> >> didn't use the tx inq to free dmad Tx packages.
> > 
> > The problem with skb_orphan is that you are telling the network stack that
> > the packet is now out of its reach and it will no longer be able to take
> > queued packets into account.
> 
> skb_orphan() also does not release netfilter resources attached to the
> packet.
> 
> Really, all drivers must free TX SKBs in a small, finite, amount of
> time after submission.
> 
> There is no way around this.

I see. Do you see a problem with returning early from napi->poll()
without calling napi_complete() when the TX queue remains full at
the end of the poll function?

Or is there any better alternative for broken hardware that lacks
a TX-complete interrupt?

	Arnd

From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v8 3/3] net: hisilicon: new hip04 ethernet driver
Date: Sun, 07 Dec 2014 21:09:22 +0100
Message-ID: <2619239.NTtdNaZCJM@wuerfel>
References: <1397869980-21187-1-git-send-email-zhangfei.gao@linaro.org> <5483C977.2060308@huawei.com> <54842298.2010007@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Ding Tianhong <dingtianhong@huawei.com>,
	Zhangfei Gao <zhangfei.gao@linaro.org>, davem@davemloft.net,
	linux@arm.linux.org.uk, f.fainelli@gmail.com,
	sergei.shtylyov@cogentembedded.com, mark.rutland@arm.com,
	David.Laight@aculab.com, eric.dumazet@gmail.com,
	xuwei5@hisilicon.com, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, devicetree@vger.kernel.org
To: Alexander Graf <agraf@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.131]:63517 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753402AbaLGUJx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Dec 2014 15:09:53 -0500
In-Reply-To: <54842298.2010007@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 07 December 2014 10:49:12 Alexander Graf wrote:
> On 07.12.14 04:28, Ding Tianhong wrote:
> > On 2014/12/7 8:42, Alexander Graf wrote:
> >> On 19.04.14 03:13, Zhangfei Gao wrote:
> >>> Support Hisilicon hip04 ethernet driver, including 100M / 1000M controller.
> >>> The controller has no tx done interrupt, reclaim xmitted buffer in the poll.
> >>>
> >>> Signed-off-by: Zhangfei Gao <zhangfei.gao@linaro.org>
> >>
> >> Is this driver still supposed to go upstream? I presume this was the
> >> last submission and it's been quite some time ago 
> >>
> > 
> > yes, it is really a long time, but The hip04 did not support tx irq, 
> > we couldn't get any better idea to fix this defect, do you have any suggestion?
> 
> Well, if hardware doesn't have a TX irq I don't see there's anything we
> can do to fix that ;).

I don't know if it's related to the ethernet on hip01, but I would assume
it is, and that platform is currently being submitted for inclusion, so
I'd definitely hope to see this driver get merged too eventually.

IIRC, the last revision of the patch set had basically fixed the problem,
except for a race that would still allow the napi poll function to exit
with poll_complete() but a full queue of TX descriptors and no fallback
to clean them up. There was also still an open question about whether or
not the driver should use skb_orphan, but I may be misremembering that part.
 
> Dave, what's your take here? Should we keep a driver from going upstream
> just because the hardware is partly broken? I'd really prefer to have an
> upstream driver on that SoC rather than some random (eventually even
> more broken) downstream code.

We can certainly have a slow driver for this hardware, and I'd much
prefer slow over broken. I'd guess that some of the performance impact
of the missing interrupts can now be offset with the xmit_more	 logic.

	Arnd

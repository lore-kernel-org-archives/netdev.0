From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 0/7] net: dsa: add QCA AR8xxx switch family support\
Date: Fri, 29 May 2015 12:58:12 -0700
Message-ID: <5568C4D4.7010701@gmail.com>
References: <1432863742-18427-1-git-send-email-mathieu@codeaurora.org> <20150529020001.GF11260@lunn.ch> <20150529184951.GA2458@codeaurora.org> <20150529185953.GF19580@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	davem@davemloft.net, linux@roeck-us.net, gang.chen.5i5j@gmail.com,
	jiri@resnulli.us, leitec@staticky.com, fabf@skynet.be,
	alexander.h.duyck@intel.com, pavel.nakonechny@skitlab.ru,
	joe@perches.com, sfeldma@gmail.com, nbd@openwrt.org,
	juhosg@openwrt.org, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>,
	Mathieu Olivari <mathieu@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34444 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756834AbbE2T6T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 15:58:19 -0400
In-Reply-To: <20150529185953.GF19580@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29/05/15 11:59, Andrew Lunn wrote:
> On Fri, May 29, 2015 at 11:49:54AM -0700, Mathieu Olivari wrote:
>> On Fri, May 29, 2015 at 04:00:01AM +0200, Andrew Lunn wrote:
>>> FYI:
>>>
>>> I have patches which allow DSA to use two cpu interfaces. Seems to
>>> work on my DIR665 with a Marvell Switch.
>>>
>>> I will post the patches as an RFC.
>>>
>>>   Andrew
>>
>> Does it require the switch CPU ports to support LAG or is it generic
>> enough to allow switch partitioning?
> 
> When using tags, DSA by default partitions the switch. Each user port
> is separate from other ports. lan4 will not bridge to lan1 unless you
> either do it in software, or you implement the
> .port_join_bridge/.port_leave_bridge/.port_stp_update methods of
> dsa_switch_driver.
> 
> What it requires is that for each user port, you can configure what
> cpu port it should use. Marvell devices have this ability, and at a
> first look, it seems like SF2 does as well, but i will leave Florian
> to answer definitively.

That's right, such configuration happens by using VLAN_CTL in the
context of SF2, by default only Port <N> and CPU can talk to each other.
Bridging ports involving putting them in the same domain, e.g: updating
the VLAN_CTL bitmask to include all bridge members.
-- 
Florian

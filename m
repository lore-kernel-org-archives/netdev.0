From: Jonas Gorski <jogo@openwrt.org>
Subject: Re: [PATCH] bcm63xx_enet: fix poll callback.
Date: Wed, 04 Mar 2015 00:05:15 +0100
Message-ID: <54F63E2B.1050100@openwrt.org>
References: <1425383112-23851-1-git-send-email-nschichan@freebox.fr>	 <1425389399.5130.169.camel@edumazet-glaptop2.roam.corp.google.com> <1425390142.5130.173.camel@edumazet-glaptop2.roam.corp.google.com> <54F5BCE0.3060507@freebox.fr> <54F5F28C.40202@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Tobias Klauser <tklauser@distanz.ch>,
	Felipe Balbi <balbi@ti.com>,
	Wilfried Klaebe <w-lkml@lebenslange-mailadresse.de>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>,
	Nicolas Schichan <nschichan@freebox.fr>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arrakis.dune.hu ([78.24.191.176]:41897 "EHLO arrakis.dune.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756618AbbCCXFT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Mar 2015 18:05:19 -0500
In-Reply-To: <54F5F28C.40202@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03.03.2015 18:42, Florian Fainelli wrote:
> On 03/03/15 05:53, Nicolas Schichan wrote:
>> On 03/03/2015 02:42 PM, Eric Dumazet wrote:
>>>> To avoid that, I would take priv->tx_lock only once, or add a limit on
>>>> the number of skbs that can be drained per round.
>>>
>>> Something like this (untested) patch
>>
>> I'm not against testing this patch, but we do not have any SMP capable bcm63xx
>> board here so I don't think it will be of any use.
>>
>> bcm6358 and bcm6368 do indeed have two MIPS threads, but SMP is not possible
>> (due to a data cache or TLB shared across all MIPS threads , unbearably
>> complicating things, IIRC).
> 
> 6358 does have the shared TLB (early BMIPS4350), but 6368 (later
> BMIPS4350) runs just fine in a regular SMP configuration, that's the
> default for OpenWrt actually. Maybe Jonas has something readily
> available he could test on?

While I do have several SMP capable boards here, I'm not sure what I'm
supposed to test and especially how.

I mean I can test whether it breaks things, but for testing whether it
fixes things I would need some help on how to break it first ;-)


Jonas

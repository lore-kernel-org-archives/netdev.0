From: "Seewer Philippe" <philippe.seewer@bfh.ch>
Subject: Re: [PATCH 2/2] pcnet32: PHY selection support
Date: Fri, 17 Feb 2006 20:56:35 +0100
Message-ID: <43F62A73.3090509@bfh.ch>
References: <20060217134938.B24429@mail.kroptech.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<tsbogend@alpha.franken.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751584AbWBQT4p@vger.kernel.org>
Content-class: urn:content-classes:message
To: "Adam Kropelin" <akropel1@rochester.rr.com>
In-Reply-To: <20060217134938.B24429@mail.kroptech.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Adam Kropelin wrote:
> Seewer Philippe wrote:
> 
>>Most AMD pcnet chips support up to 32 external PHYs. This patch
>>introduces basic PHY selection/switching support, by adding two
>>new module parameters:
>>-maxphy: how many PHYs the card supports
>>-usephy: which phy to use instead of eeprom default
>>
>>Maxphy is necessary in order to check the range of usephy and may
>>be overriden inside the module.
> 
> 
> It seems a bit pointless for the range check of a user-supplied value to
> be driven by another user-supplied value.
I just want to make sure and there's the possibility of supplying only maxphy
and let the autoswitch algorithm decide...
> 
> 
>>If only maxphy is present I've implemented an algorithm which checks
>>the link state on all PHYs and uses the one that has a link.
> 
> 
> Knowing how many PHYs to scan is potentially useful, but how about
> determining that at runtime? Missing PHYs should be detectable with a
> timeout or similar. Too risky?
Actually its possible to query them with mii and all non-present phy's
should "return" 0xffff. I wanted my changes to have no impact on pcnet
cards with only one phy, thats why.

> 
> --Adam
> 

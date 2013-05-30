From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 1/3] net: phy: prevent linking breakage
Date: Thu, 30 May 2013 02:42:01 -0700 (PDT)
Message-ID: <20130530.024201.1913984663902628192.davem@davemloft.net>
References: <1369741403-25315-2-git-send-email-alexandre.belloni@free-electrons.com>
	<20130528.130920.1604291112518863799.davem@davemloft.net>
	<51A5BA86.3070609@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux@arm.linux.org.uk,
	shawn.guo@linaro.org, kernel@pengutronix.de
To: alexandre.belloni@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45032 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968041Ab3E3JmF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 05:42:05 -0400
In-Reply-To: <51A5BA86.3070609@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexandre Belloni <alexandre.belloni@free-electrons.com>
Date: Wed, 29 May 2013 10:21:26 +0200

> On 28/05/2013 22:09, David Miller wrote:
>>
>> This is the wrong way to go about this.
>>
>> If the arch code absolutely requires CONFIG_PHYLIB=y then express that
>> dependency in the arch Kconfig.  The arch code in question should not
>> be compiled at all if CONFIG_PHYLIB has an incompatible setting.
> But that is making it impossible to compile a kernel without any network
> stack for those platforms or we are going back to either enclosing the
> calls to phy_register_fixup{,_for_uid,_for_id} with #ifdef CONFIG_PHYLIB
> or if(IS_BUILTIN(CONFIG_PHYLIB)). And as you can see, it is quite error
> prone and is done only done for 2 platforms on a total of 6. I believe
> fixing that in phy.h is more foolproof.

Or you properly segregate the networking bits of the platform code so
that it can be built only when the necessary networking portions are
enabled.

Sometimes having dummy stubs makes sense, but not in this situation.

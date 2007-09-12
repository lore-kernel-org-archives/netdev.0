From: David Miller <davem@davemloft.net>
Subject: Re: RFC: possible NAPI improvements to reduce interrupt rates for
 low traffic rates
Date: Wed, 12 Sep 2007 08:12:11 -0700 (PDT)
Message-ID: <20070912.081211.13753718.davem@davemloft.net>
References: <200709061416.l86EG0Vb017675@quickie.katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hadi@cyberus.ca, jeff@garzik.org,
	mandeep.baines@gmail.com, ossthema@de.ibm.com
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:48908
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965914AbXILPMk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 11:12:40 -0400
In-Reply-To: <200709061416.l86EG0Vb017675@quickie.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Chapman <jchapman@katalix.com>
Date: Thu, 6 Sep 2007 15:16:00 +0100

> First, do we need to encourage consistency in NAPI poll drivers? A
> survey of current NAPI drivers shows different strategies being used
> in their poll(). Some such as r8169 do the napi_complete() if poll()
> does less work than their allowed budget. Others such as e100 and
> tg3 do napi_complete() only if they do no work at all.

Actually, I want to clarify this situation.  In reality these
drivers are more consistent than different.

For some chips the cheapest way to figure out if there is more
RX work is simply to see if the amount of work processed is
less than "budget".  It's too expensive to recheck the hardware.

On some chips like tg3, it's extremely cheap to see if new work
arrived between the completion of processing the RX queue and
the NAPI completion check, so they do it.

But logically they are testing the same exact high level thing.

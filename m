From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] bnx2x: Insane RX rings
Date: Fri, 10 Sep 2010 09:42:20 -0700 (PDT)
Message-ID: <20100910.094220.220056217.davem@davemloft.net>
References: <20100909.143001.104050644.davem@davemloft.net>
	<4C8953D3.9060204@hp.com>
	<1284117374.30831.2.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, ole@ans.pl, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41057
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755910Ab0IJQmD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Sep 2010 12:42:03 -0400
In-Reply-To: <1284117374.30831.2.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Fri, 10 Sep 2010 14:16:14 +0300

> There are few factors that can be considered when scaling the ring
> sizes:
> - Number of queues per device
> - Number of devices
> - Available amount of memory
> - Others...
> 
> I'm thinking about adding a factor only according to the number of
> queues - this will still cause issues for systems with many ports. Does
> that sound reasonable or not enough? Do you think the number of devices
> or even the amount of free memory should be considered?

I think scaling based upon the number of queues is a good place
to start.

Multi-port is less of an issue.  The problem we really care about is
stemming from the fact that the same exact port will require more
memory than another one simply because it has more queues active.

I would even argue that this is a zero sum thing to do, because
since the traffic ought to be distributed, you have enough buffers
to handle the load.

Of course I understand that a certain level of buffering is necessary
even on a per-queue level with many queues active, so if you scale
based upon the number of queues but then enforce a minimum (something
like 128 entries) that would be a reasonable thing to do.

Thanks for looking into this Eilon.

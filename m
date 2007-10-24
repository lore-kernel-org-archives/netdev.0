From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] e1000, e1000e valid-addr fixes
Date: Tue, 23 Oct 2007 18:07:44 -0700 (PDT)
Message-ID: <20071023.180744.115914004.davem@davemloft.net>
References: <20071023.145339.55504234.davem@davemloft.net>
	<471E9801.2000006@garzik.org>
	<471E99E8.6030404@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davej@redhat.com, auke-jan.h.kok@intel.com,
	ajax@redhat.com, linux-kernel@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34283
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752807AbXJXBHR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2007 21:07:17 -0400
In-Reply-To: <471E99E8.6030404@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jeff@garzik.org>
Date: Tue, 23 Oct 2007 21:03:36 -0400

> I'm wondering if there is a way to avoid adding
> 
> 	if (!is_valid_ether_addr(dev->dev_addr))
> 		return -EINVAL;
> 
> to every ethernet driver's ->open() hook.

The first idea I get is:

1) Create netdev->validate_dev_addr().

2) If it exists, invoke it before ->open(), abort
   and return if any errors signaled.

etherdev init hooks up a function that does the above
check, which allows us to avoid editing every ethernet
driver

What do you think?

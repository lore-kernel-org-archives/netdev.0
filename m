From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar: Wait for both RX and TX to stop
Date: Wed, 21 Apr 2010 14:33:30 -0700 (PDT)
Message-ID: <20100421.143330.80015172.davem@davemloft.net>
References: <10AE27BE-1830-4AAD-83E6-20001BC430D8@kernel.crashing.org>
	<z2ged82fe3e1004210733v8fa40902k664549aa9620b13@mail.gmail.com>
	<CD8C73BA-0E18-4F85-A90B-C2FA5FFC8689@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: timur.tabi@gmail.com, afleming@freescale.com,
	netdev@vger.kernel.org
To: galak@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58500
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755252Ab0DUVdZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 17:33:25 -0400
In-Reply-To: <CD8C73BA-0E18-4F85-A90B-C2FA5FFC8689@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kumar Gala <galak@kernel.crashing.org>
Date: Wed, 21 Apr 2010 14:13:00 -0500

> I'm not opposed, I'm just asking if we are saying we shouldn't be using cpu_relax() for spinning on HW status registers ever.
> 
> If we are suggesting that cpu_relax() shouldn't be used in these scenarios going forward I'm ok w/the change you suggest and starting to convert other cpu_relax() calls to use spin_event_timeout()


Kumar this isn't an either-or thing.

In both cases we're using cpu_relax().

But by using spin_event_timeout() you're getting both the cpu_relax()
and a break-out in case the hardware gets wedged for some reason.

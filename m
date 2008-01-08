From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/7]: [NET]: Do not check netif_running() and carrier
 state in ->poll()
Date: Tue, 08 Jan 2008 14:47:31 -0800 (PST)
Message-ID: <20080108.144731.168854521.davem@davemloft.net>
References: <20080107.213907.160610552.davem@davemloft.net>
	<78C9135A3D2ECE4B8162EBDCE82CAD7702CAA89B@nekter>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ramkrishna.Vepa@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33568
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751944AbYAHWrc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 17:47:32 -0500
In-Reply-To: <78C9135A3D2ECE4B8162EBDCE82CAD7702CAA89B@nekter>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Date: Tue, 8 Jan 2008 13:17:03 -0500

> Dave,
> 
> This change is not required as the macro, is_s2io_card_up() checks for
> an internal state of the adapter and not netif's state. We want to make
> sure that the adapter registers are not accessed when the adapter is
> being brought down.

If the adapter is being brought down, you would have done
a napi_disable() first and therefore never reach this code
path.

The removal is correct, I read how your driver works.

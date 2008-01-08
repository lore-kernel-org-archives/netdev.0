From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/7]: [NET]: Do not check netif_running() and carrier
 state in ->poll()
Date: Tue, 08 Jan 2008 15:07:35 -0800 (PST)
Message-ID: <20080108.150735.182342472.davem@davemloft.net>
References: <20080108.144731.168854521.davem@davemloft.net>
	<78C9135A3D2ECE4B8162EBDCE82CAD7702CAA9E8@nekter>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ramkrishna.Vepa@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58964
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751213AbYAHXHg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 18:07:36 -0500
In-Reply-To: <78C9135A3D2ECE4B8162EBDCE82CAD7702CAA9E8@nekter>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Date: Tue, 8 Jan 2008 18:01:32 -0500

> Dave,
> Sorry, should have been clearer. When I meant "brought down" did not
> mean close, but when a adapter reset is initiated. The napi_disable() is
> called only on a close. When the driver does a reset, napi_disable() is
> not called. 

You should be doing a napi_disable() during a reset, like every
other driver does.

It is the only reliable way to prevent the code path from running.

Otherwise, you can start resetting the device right after
that check in the ->poll() routine, and thus still touch
the device during the reset sequence.

In short the check is wrong, because it doesn't fully prevent
what you want it to prevent.  Only a napi_disable() would do
that fully for you.

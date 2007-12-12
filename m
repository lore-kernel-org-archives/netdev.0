From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] net: napi fix
Date: Wed, 12 Dec 2007 07:21:21 -0800 (PST)
Message-ID: <20071212.072121.93137990.davem@davemloft.net>
References: <002901c83c73$b089b6e0$9c94fea9@jason>
	<20071211213939.122de1db@freepuppy.rosehill>
	<20071211214634.4dedb274@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joonwpark81@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	baum@tehutinetworks.net, andy@greyhouse.net
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45162
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755295AbXLLPVY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 10:21:24 -0500
In-Reply-To: <20071211214634.4dedb274@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Tue, 11 Dec 2007 21:46:34 -0800

> Isn't this a better fix for all drivers, rather than peppering every
> driver with the special case. This is how the logic worked up until
> 2.6.24.

Stephen this is not the problem.

The problem is that the driver is doing a NAPI completion and
re-enabling chip interrupts with work_done == weight, and that is
illegal.

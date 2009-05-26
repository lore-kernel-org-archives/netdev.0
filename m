From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.30-rc4] r8169: avoid losing MSI interrupts
Date: Mon, 25 May 2009 22:55:03 -0700 (PDT)
Message-ID: <20090525.225503.173348268.davem@davemloft.net>
References: <1242328457.32579.12.camel@lap75545.ornl.gov>
	<4A0C7443.1010000@googlemail.com>
	<1243042174.3580.23.camel@obelisk.thedillows.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: michael.riepe@googlemail.com, mb@bu3sch.de, romieu@fr.zoreil.com,
	rsantos@grupopie.com, m.bueker@berlin.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: dave@thedillows.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59446
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751659AbZEZFzE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 01:55:04 -0400
In-Reply-To: <1243042174.3580.23.camel@obelisk.thedillows.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Dillow <dave@thedillows.org>
Date: Fri, 22 May 2009 21:29:34 -0400

> The 8169 chip only generates MSI interrupts when all enabled event
> sources are quiescent and one or more sources transition to active. If
> not all of the active events are acknowledged, or a new event becomes
> active while the existing ones are cleared in the handler, we will not
> see a new interrupt.
> 
> The current interrupt handler masks off the Rx and Tx events once the
> NAPI handler has been scheduled, which opens a race window in which we
> can get another Rx or Tx event and never ACK'ing it, stopping all
> activity until the link is reset (ifconfig down/up). Fix this by always
> ACK'ing all event sources, and loop in the handler until we have all
> sources quiescent.
> 
> Signed-off-by: David Dillow <dave@thedillows.org>

I've applied this, thanks David.

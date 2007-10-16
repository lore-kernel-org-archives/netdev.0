From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: netif_napi_add vs. multiple netdev's
Date: Tue, 16 Oct 2007 15:47:13 +1000
Message-ID: <1192513633.19073.21.camel@pasglop>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:49506 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759131AbXJPFrS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2007 01:47:18 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stehphen !

The new netif_napi_add() function takes a netdev argument. In the EMAC
case, there is one NAPI instance working on behalf of multiple netdev's,
so that isn't very useful. For my EMAC patch (just posted to you & the
list), I'm not passing NULL, but I'm wondering what would be a good way
to handle netpoll here...

The way it's currently implemented, there's a list of NAPI's attached to
the netdev, so obviously, that won't work for my usage scenario.

I'm not sure what's the best data structure that would be suitable for
both N ndev's for 1 NAPI and 1 ndev for N NAPI's though... I could
allocate "stub" list heads and queue those up, but that's a bit gross...

Any better idea ?

Cheers,
Ben.



From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 2.6.25 1/1]S2io: Multiqueue network device support implementation
Date: Thu, 24 Jan 2008 08:25:49 +0100
Message-ID: <20080124072549.GA6814@one.firstfloor.org>
References: <p73odbclsft.fsf@crumb.suse.de> <78C9135A3D2ECE4B8162EBDCE82CAD7702E70E92@nekter>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>,
	netdev@vger.kernel.org, jeff@garzik.org,
	support <support@neterion.com>
To: Ramkrishna Vepa <Ramkrishna.Vepa@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:50915 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752454AbYAXGwE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2008 01:52:04 -0500
Content-Disposition: inline
In-Reply-To: <78C9135A3D2ECE4B8162EBDCE82CAD7702E70E92@nekter>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> [Ram] I am assuming that this is with regards to msi-x interrupts. We

Yes. 

And avoiding bouncing locks for device state between CPUs.

> have done away with handling tx completion in the interrupt handler, and
> are instead handling them in the context of the transmit. The slow path,
> straggling transmit completions will be handled in the timer context.

Ok -- hopefully you don't have bad corner cases from this when the pipe
is not fully filled and then causing longer latencies on completion. 
Old NAPI sometimes suffered from such problems. 

-Andi

From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/5] ixgbe: drop support for UDP in RSS
 hash generation
Date: Mon, 19 Jul 2010 23:39:47 -0700 (PDT)
Message-ID: <20100719.233947.66752494.davem@davemloft.net>
References: <20100719.202417.218061462.davem@davemloft.net>
	<20100720020754.135b5ff7.billfink@mindspring.com>
	<1279607400.2458.76.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: billfink@mindspring.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	alexander.h.duyck@intel.com, donald.c.skidmore@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35132
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753884Ab0GTGjb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 02:39:31 -0400
In-Reply-To: <1279607400.2458.76.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 20 Jul 2010 08:30:00 +0200

> By nature, UDP flows are subject to out of order issues, so what is this
> patch tries to avoid ?

UDP being subject to out-of-order issues really doesn't matter one
bit.

We should never, _knowingly_ create out-of-order packets in our
networking stack.  And this is regardless of protocol.

If there is no way to make ixgbe respect in-order packet delivery for
UDP frames vis-a-vis fragmented frames, we must disable RX flow
spreading for UDP.

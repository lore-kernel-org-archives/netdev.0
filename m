From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: Re: [PATCH 1/7] mlx4: Added interrupts test support
Date: Mon, 05 Oct 2009 13:16:47 +0200
Message-ID: <4AC9D59F.1090409@mellanox.co.il>
References: <4AC4BD9A.2050101@mellanox.co.il> <adaeipmqxmv.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:38857 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751975AbZJEITR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Oct 2009 04:19:17 -0400
In-Reply-To: <adaeipmqxmv.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roland Dreier wrote:
> This feels like a pretty risky thing to do while the device might be
> handling all sorts of other traffic at the same time.  Are you sure
> there are no races you expose here? 
We did testing on this, during heavy traffic.
A race can happen when there are two processes that execute that test simultaneously,
but the tests always executed from Ethtool context.
I will add additional protection in case somebody tries to execute this test from another context.

> Have you actually seen cases where
> the interrupt test during initialization works but then this test
> catches a problem?  (My experience has been that if any MSI-X interrupts
> work from a device, then they'll all work)
It also checks that all the EQs work properly. During initialization we only check the asynchronous EQ


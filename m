From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/8 2.6.28] cxgb3 - Allocate multiqueues at init time
Date: Wed, 08 Oct 2008 17:42:02 -0700 (PDT)
Message-ID: <20081008.174202.160320028.davem@davemloft.net>
References: <20081009003402.13315.18192.stgit@speedy5>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32848
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755845AbYJIAm0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 20:42:26 -0400
In-Reply-To: <20081009003402.13315.18192.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>
Date: Wed, 08 Oct 2008 17:34:02 -0700

> Allocate a queue set per core, up to the maximum of available qsets.
> Share the queue sets on multi port adapters.
> Rename MSI-X interrupt vectors ethX-N, N being the queue set number.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>

Applied, but...

This "num processors" logic and policy belongs in some generic place.
Perhaps "num_possible_cpus()" is more appropriate, who knows right?

Otherwise every stinking driver is going to implement this in
their own way and use their own policy, and from a user experience
perspective that totally sucks.

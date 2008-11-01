From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH] mv643xx_eth: fix SMI bus access timeouts
Date: Fri, 31 Oct 2008 22:47:47 -0700
Message-ID: <ada63n8xaik.fsf@cisco.com>
References: <20081101053220.GA13348@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:9233 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750716AbYKAFrs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Nov 2008 01:47:48 -0400
In-Reply-To: <20081101053220.GA13348@xi.wantstofly.org> (Lennert Buytenhek's
	message of "Sat, 1 Nov 2008 06:32:20 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > If wait_event_timeout() would return zero, mv643xx_eth would conclude
 > that the SMI access timed out, but this is not necessarily true --
 > wait_event_timeout() can also return zero in the case where the SMI
 > completion interrupt did happen in time but where it took longer than
 > the requested timeout for the process performing the SMI access to be
 > scheduled again.  This would lead to occasional SMI access timeouts
 > when the system would be under heavy load.

Would it make more sense to fix this in the wait_event_timeout() code
itself a la bb10ed09 ("sched: fix wait_for_completion_timeout() spurious
failure under heavy load")?

 - R.

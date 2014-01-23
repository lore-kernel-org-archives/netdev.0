From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] tuntap: Fix for a race in accessing
 numqueues
Date: Wed, 22 Jan 2014 21:33:16 -0800 (PST)
Message-ID: <20140122.213316.1975984315340872670.davem@davemloft.net>
References: <1390359803-27989-1-git-send-email-dominic.curran@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jasowang@redhat.com, maxk@qti.qualcomm.com
To: dominic.curran@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53984 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750927AbaAWFdR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 00:33:17 -0500
In-Reply-To: <1390359803-27989-1-git-send-email-dominic.curran@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dominic Curran <dominic.curran@citrix.com>
Date: Wed, 22 Jan 2014 03:03:23 +0000

> A patch for fixing a race between queue selection and changing queues
> was introduced in commit 92bb73ea2("tuntap: fix a possible race between
> queue selection and changing queues").
> 
> The fix was to prevent the driver from re-reading the tun->numqueues
> more than once within tun_select_queue() using ACCESS_ONCE().
> 
> We have been experiancing 'Divide-by-zero' errors in tun_net_xmit() 
> since we moved from 3.6 to 3.10, and believe that they come from a 
> simular source where the value of tun->numqueues changes to zero 
> between the first and a subsequent read of tun->numqueues.
> 
> The fix is a simular use of ACCESS_ONCE(), as well as a multiply
> instead of a divide in the if statement.
> 
> Signed-off-by: Dominic Curran <dominic.curran@citrix.com>

Applied, thank you.

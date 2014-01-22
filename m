From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] tuntap: Fix for a race in accessing numqueues
Date: Tue, 21 Jan 2014 18:37:45 -0800 (PST)
Message-ID: <20140121.183745.327558429953663898.davem@davemloft.net>
References: <1390255158-9058-1-git-send-email-dominic.curran@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jasowang@redhat.com, maxk@qti.qualcomm.com
To: dominic.curran@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39347 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754221AbaAVChr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 21:37:47 -0500
In-Reply-To: <1390255158-9058-1-git-send-email-dominic.curran@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dominic Curran <dominic.curran@citrix.com>
Date: Mon, 20 Jan 2014 21:59:18 +0000

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
> Cc: Jason Wang <jasowang@redhat.com>
> Cc: Maxim Krasnyansky <maxk@qti.qualcomm.com>
> ---
> V2: Use multiply instead of divide. Suggested by Eric Dumazet.
>     Fixed email address for maxk. Rebase against net tree.

Can you please respin this against net-next?  Thank you.

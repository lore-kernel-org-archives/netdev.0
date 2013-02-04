From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v4] netpoll: protect napi_poll and poll_controller during
 dev_[open|close]
Date: Sun, 3 Feb 2013 19:32:57 -0500
Message-ID: <20130204003257.GA4985@neilslaptop.think-freely.org>
References: <1359578665-29248-1-git-send-email-nhorman@tuxdriver.com>
 <1359831076-32476-1-git-send-email-nhorman@tuxdriver.com>
 <20130203.160558.164595629505218847.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ivecera@redhat.com,
	bhutchings@solarflare.com, romieu@fr.zoreil.com,
	eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:41246 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754093Ab3BDAdK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Feb 2013 19:33:10 -0500
Content-Disposition: inline
In-Reply-To: <20130203.160558.164595629505218847.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 03, 2013 at 04:05:58PM -0500, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Sat,  2 Feb 2013 13:51:16 -0500
> 
> > I can't say Im a huge fan of returning -EBUSY in open/close, but I
> > like it better than busy waiting while the poll path completes.
> 
> Sorry Neil, this is a show stopper for me.
> 
> There is no reason why, just because of bad timing, a device open or
> close that would normally succeed, should fail.  And this situation is
> only being created because the mutual exclusion and context handling
> is "hard", well that's too bad :-)
> 

Alright, fair enough Dave.  I'll either covert this to a busy wait, or use a
mutex to do this.
Neil

From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH] usbnet: ratelimit kevent may have been dropped warnings
Date: Mon, 12 Nov 2012 08:16:29 +0100
Message-ID: <2192335.eVEjctQSPm@linux-lqwf.site>
References: <1352391981-15692-1-git-send-email-steve.glendinning@shawell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org
To: Steve Glendinning <steve.glendinning@shawell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:46728 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751377Ab2KLHQV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Nov 2012 02:16:21 -0500
In-Reply-To: <1352391981-15692-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 08 November 2012 16:26:21 Steve Glendinning wrote:

> There's an underlying problem in usbnet's kevent deferral

This is imported from schedule_work().

> mechanism which needs fixing, specifically that events *can*
> get dropped and not handled.  This patch doesn't address this,
> but just mitigates fallout caused by the current implemention.

All is not lost, as the flag is still set. How about starting a timer
in the failure case? It feels kind of dirty, but a solution with locks would
leave open a window to a race in any case.

	Regards
		Oliver

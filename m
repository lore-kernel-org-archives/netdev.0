From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH] r8152: correct error returns
Date: Tue, 05 Aug 2014 09:43:04 +0200
Message-ID: <1407224584.12844.5.camel@linux-fkkt.site>
References: <1406901370-6847-1-git-send-email-oneukum@suse.de>
	 <20140802.163418.1314777407262254543.davem@davemloft.net>
	 <1407049618.26893.8.camel@linux-fkkt.site>
	 <20140804.151827.179999106523102125.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:42947 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753608AbaHEHnJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Aug 2014 03:43:09 -0400
In-Reply-To: <20140804.151827.179999106523102125.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-08-04 at 15:18 -0700, David Miller wrote:
> From: Oliver Neukum <oneukum@suse.de>
> Date: Sun, 03 Aug 2014 09:06:58 +0200
> 
> > OK, I just looked at this single driver. I'll try to come up with
> > a generic solution. The mapping is a bit simplistic. I should let
> > -ENOMEM pass for example.
> 
> And the problem also isn't limited USB networking drivers, just
> about every driver I looked at passed these autopm errors right
> back to userspace.

I drilled a gas bubble.

> Largely people just call the autopm interfaces and propagate any
> errors they get.  So you probably want to put the translator/filter
> there.

That would swallow up all error returns and hurt the users who actually
use the error codes. How about a native and a sanitized
version?

> But of course, that doesn't handle the non-autopm code paths into the
> PM layer that can end up in this situation.
Hm. Are they numerous? Which did you find?

	Regards
		Oliver

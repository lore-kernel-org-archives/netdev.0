From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: IPv6: autoconfiguration and suspend/resume or link down/up
Date: Wed, 20 Jul 2011 18:36:56 +0200
Message-ID: <20110720163656.GD11692@midget.suse.cz>
References: <20110719180222.GA7509@midget.suse.cz>
 <1311178905.21004.9.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Bohac <jbohac@suse.cz>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	"David S. Miller" <davem@davemloft.net>,
	stephen hemminger <shemminger@vyatta.com>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:36614 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751740Ab1GTQg6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 12:36:58 -0400
Content-Disposition: inline
In-Reply-To: <1311178905.21004.9.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 20, 2011 at 11:21:43AM -0500, Dan Williams wrote:
> ... and in the resume handler use that value to age anything
> that needs to know about time spent in suspend, and then do what needs
> to be done with that.  So something like that may work for IPv6
> addrconf; on suspend save current time, and on resume check the current
> time, subtract the time you saved on suspend, and magically add that to
> the lifetime counts and then run any expiry stuff.

IPv6 (by specification) does not send any RS when an IP address
or route expires. So only subtracting the supend time from the
lifetimes and possibly expiring the routes/IP addresses won't fix
the problem.

When I move to a new network, I need to restart the
autoconfiguration. This does not currently happen - neither for
an alive system where the ethernet link goes down/up, nor for a
system that gets suspended, moved and then resumed.

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ


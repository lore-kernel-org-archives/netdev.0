From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] SCTP: Reduce log spamming for sctp setsockopt
Date: Mon, 16 Dec 2013 09:17:27 -0800
Message-ID: <1387214247.18217.49.camel@joe-AO722>
References: <1387205049-22752-1-git-send-email-nhorman@tuxdriver.com>
	 <1387206233.18217.21.camel@joe-AO722> <52AF18B7.6050602@redhat.com>
	 <1387207301.18217.30.camel@joe-AO722> <52AF2001.2090108@redhat.com>
	 <20131216160440.GE19809@hmsreliant.think-freely.org>
	 <1387212635.18217.45.camel@joe-AO722>
	 <20131216170254.GF19809@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>, linux-sctp@vger.kernel.org,
	Vlad Yasevich <vyasevich@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0189.hostedemail.com ([216.40.44.189]:44275 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754583Ab3LPRRa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 12:17:30 -0500
In-Reply-To: <20131216170254.GF19809@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-12-16 at 12:02 -0500, Neil Horman wrote:
> On Mon, Dec 16, 2013 at 08:50:35AM -0800, Joe Perches wrote:
[]
> > Does adding a couple of functions like:
> > 
> > void pr_warn_deprecated(const char *old, const char *new)
> > {
> > 	static DEFINE_RATELIMIT_STATE(_rs,
> > 				      DEFAULT_RATELIMIT_INTERVAL,
> > 				      DEFAULT_RATELIMIT_BURST);
> > 
> > 	if (!__ratelimit(&_rs))
> > 		return;
> > 
> > 	if (new)
> > 		printk(KERN_WARNING "%pf: Use of \"%s\" is deprecated - use \"%s\" instead\n",
> > 				    __builtin_return_address(1), old, new); 
> > 	else
> > 		printk(KERN_WARNING "%pf: Use of \"%s\" is deprecated\n",
> > 				    __builtin_return_address(1), old); 
> > }
> > 
> > suit?  Other suggestions?
> > 
> 
> i'm just doing this:
> #define pr_warn_deprecated(fmt, ...) \
> pr_warn_ratelimited("Deprecated: " fmt, ##__VA_ARGS__)
> 
> That will work for every form, giving consistency to the location of a single
> word for ease of searching.  I don't really see the need to institutionalize
> "use <blank> instead", since there may be no drop in replacement for something
> that is deprecated.

That's what the test for non-null "new" was for
but fine, it's your code.

Do what you think appropriate.

Also, using pr_warn_once may be better.  Dunno.

cheers, Joe

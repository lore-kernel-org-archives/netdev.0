From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] cnic: fix double initalization of bnx2 based cards
Date: Tue, 08 Mar 2011 19:40:55 +0000
Message-ID: <1299613255.4957.3.camel@bwh-desktop>
References: <1299610588-22356-1-git-send-email-nhorman@tuxdriver.com>
	 <1299610768.4957.1.camel@bwh-desktop> <1299611277.12601.15.camel@HP1>
	 <20110308193601.GA19669@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	Eddie Wai <eddie.wai@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:23239 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752621Ab1CHTlC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2011 14:41:02 -0500
In-Reply-To: <20110308193601.GA19669@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-03-08 at 14:36 -0500, Neil Horman wrote:
> On Tue, Mar 08, 2011 at 11:07:57AM -0800, Michael Chan wrote:
> > 
> > On Tue, 2011-03-08 at 10:59 -0800, Ben Hutchings wrote:
> > > On Tue, 2011-03-08 at 13:56 -0500, Neil Horman wrote:
> > > > bnx2 cards can work with the cnic driver, but when the cnic driver detects a
> > > > bnx2 card, is_cnic_dev erroneously calls the initalization routines for both
> > > > bnx2 and bnx2x (the former being a regex subset of the later).
> > > 
> > > Since when does strcmp() do a regex match?
> > 
> > Yeah, strcmp() does NULL-terminated string compare, right?
> > 
> Sorry, poor choice of words.  It doesn't do a regex match, I only ment to
> illustrate that bnx2 is a substring of bnx2x.
> 
> strcmp does this:
> 
> strcmp(const char *str1, const char *str2) {
> ...
> 	while (*s1 || *s2) {
> 		...
> 	}
> ...
> }
> 
> Since bnx2 is a substring of bnx2 both if clauses are a match, since you'll hit
> the null terminator of the shorter string in both, which means we call both
> initalization functions.
[...]

If you don't even know what strcmp() does, what are you doing hacking on
the kernel?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


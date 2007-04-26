From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH 7/9] wext: reduce inline abuse
Date: Thu, 26 Apr 2007 19:03:27 +0200
Message-ID: <200704261903.27932.mb@bu3sch.de>
References: <20070424180732.371620000@sipsolutions.net> <20070424180849.651555000@sipsolutions.net> <20070426165032.GB22576@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: jt@hpl.hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:44408
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754898AbXDZRDu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 13:03:50 -0400
In-Reply-To: <20070426165032.GB22576@bougret.hpl.hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 26 April 2007 18:50:32 Jean Tourrilhes wrote:
> On Tue, Apr 24, 2007 at 08:07:39PM +0200, Johannes Berg wrote:
> > This patch removes a bunch of inline abuse from wext. Most functions
> > that were marked inline are only used once so the compiler will inline
> > them anyway, others are used multiple times but there's no requirement
> > for them to be inline since they aren't in any fast paths.
> > 
> > Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
> 
> 	That's clearly not true of all compilers. All gcc versions
> before 4.0 need serious help to inline functions used only once. Our
> current minimal requirement for the kernel is gcc 3.2, therefore this
> code is still useful.
> 	Note that this is a legitimate use of inline (tell the
> compiler to inline the function), not an abuse.

By my personal definition _every_ use of inline is abuse, if it's not
in an absolute fastpath and applied to a really tiny function.
Sure, other people have different opinions on that, but I think
with my approach we get smallest code with good speed.
In general I try to avoid inline whereever possible.
I think this patch is OK and should go in.

Often it's even desired to have out of line functions in fastpaths.
See spinlocks.

-- 
Greetings Michael.

From: Dan Williams <dcbw@redhat.com>
Subject: Re: Hidden SSID's
Date: Mon, 29 Jan 2007 08:00:11 -0500
Message-ID: <1170075611.2895.2.camel@localhost.localdomain>
References: <45BACB71.2080107@lwfinger.net>
	 <1169899689.25670.3.camel@localhost.localdomain>
	 <1170019717.30318.0.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:35888 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752488AbXA2M5v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jan 2007 07:57:51 -0500
In-Reply-To: <1170019717.30318.0.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2007-01-28 at 22:28 +0100, Johannes Berg wrote:
> On Sat, 2007-01-27 at 07:08 -0500, Dan Williams wrote:
> 
> > I really, really don't know why ieee80211 uses <hidden>, but it's a pain
> > in the ass and should NOT be done for d80211.  I don't know if we can
> > ever remove it from ieee80211 though for backwards compat reasons.
> 
> Ugh. /me makes a note for the cfg80211/we compat layer. This is a
> mess :(

Well, there's no way a userspace program could depend on all hidden SSID
APs having the <hidden> tag, since if you stick in another,
non-ieee80211-stack card it won't be like that.  So I don't think we
should care about <hidden> in d80211, but I don't think we can remove it
from ieee80211 either.  The only case where we'll care about it is if we
move to common scan-result processing code, and there we may have to put
a compat flag in that the driver can set or something.  But we should
definitely _not_ use <hidden> in d80211 or cfg80211, because any program
depending on <hidden> just won't work with anything other than an ipw
card.

Dan



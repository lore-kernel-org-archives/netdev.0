From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] net: compare_ether_addr[_64bits]() has no ordering
Date: Mon, 07 May 2012 16:12:41 +0200
Message-ID: <1336399961.4325.30.camel@jlt3.sipsolutions.net>
References: <1336397946.4325.27.camel@jlt3.sipsolutions.net>
	 <1336398809.3752.2313.camel@edumazet-glaptop>
	 (sfid-20120507_155404_477858_B3C1D724)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:47860 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757022Ab2EGOMm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 May 2012 10:12:42 -0400
In-Reply-To: <1336398809.3752.2313.camel@edumazet-glaptop> (sfid-20120507_155404_477858_B3C1D724)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-05-07 at 15:53 +0200, Eric Dumazet wrote:
> On Mon, 2012-05-07 at 15:39 +0200, Johannes Berg wrote:
> > From: Johannes Berg <johannes.berg@intel.com>
> > 
> > Neither compare_ether_addr() nor compare_ether_addr_64bits()
> > (as it can fall back to the former) have comparison semantics
> > like memcmp() where the sign of the return value indicates sort
> > order. We had a bug in the wireless code due to a blind memcmp
> > replacement because of this.
> > 
> > A cursory look suggests that the wireless bug was the only one
> > due to this semantic difference.
> > 
> > Signed-off-by: Johannes Berg <johannes.berg@intel.com>
> > ---
> >  include/linux/etherdevice.h |   11 ++++++-----
> >  1 file changed, 6 insertions(+), 5 deletions(-)
> 
> The right way to avoid this kind of problems is to change these
> functions to return a bool

Well, I guess so, but that'd be a weird thing for a compare_ function...
should probably be named equal_... then, but I'm not really able to do
such a huge change on the first day after my vacation :-)

johannes

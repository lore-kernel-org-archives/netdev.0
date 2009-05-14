From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: ports beeing reused too fast
Date: Thu, 14 May 2009 13:29:44 -0700
Message-ID: <20090514132944.561a1691@nehalam>
References: <200905082311.09414.opurdila@ixiacom.com>
	<200905121532.57477.opurdila@ixiacom.com>
	<20090512081119.598b22c5@nehalam>
	<200905121852.26099.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Bill Fink <billfink@mindspring.com>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Cosmin Ratiu <cratiu@ixiacom.com>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:32890 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754377AbZENU3s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 May 2009 16:29:48 -0400
In-Reply-To: <200905121852.26099.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 12 May 2009 18:52:25 +0300
Octavian Purdila <opurdila@ixiacom.com> wrote:

> 
> > I raised the issue to the original author of the proposed RFC and added
> > the issue to the ongoing review of the draft.
> >
> > There is a suggested workaround using a bitmap but it seems like it would
> > be expensive to implement:
> >       
> > http://ietfreport.isoc.org/all-ids/draft-ananth-tsvwg-timewait-00.txt
> 
> OK, I now understand how TW could be an issue here - I didn't realize that we 
> could have sockets in TW on the server side.
> 
> Since the workaround seems expensive, would it be acceptable to add a new 
> sysctl option to disable port randomization?
> 
> Thanks,
> tavi
> 

Patches welcome.  Also, it matters whether application does bind() first
or port is assigned as part of the accept. In the later case the starting
point is a hash of the 5 tuple and changes only every 5 minutes.  Linux
also reuses ports in time wait, so it will reuse sockets more aggressively
than other hosts; this existed before port randomization.

-- 

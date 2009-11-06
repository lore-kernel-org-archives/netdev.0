From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/5] Candidate fix for increased number of GFP_ATOMIC
	failures V2
Date: Fri, 6 Nov 2009 09:24:47 +0000
Message-ID: <20091106092447.GC25926__2249.86740290678$1257499521$gmane$org@csn.ul.ie>
References: <1256221356-26049-1-git-send-email-mel@csn.ul.ie> <20091106060323.GA5528@yumi.tdiedrich.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
To: Tobias Diedrich <ranma+kernel@tdiedrich.de>,
	Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>,
	Sven Geggus <lists@fuchsschwanzdomain.de>,
	Karol Lewandowski <karol.k.lewand
Return-path: <netdev-owner@vger.kernel.org>
Received: from gir.skynet.ie ([193.1.99.77]:59814 "EHLO gir.skynet.ie"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751831AbZKFJYq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Nov 2009 04:24:46 -0500
Content-Disposition: inline
In-Reply-To: <20091106060323.GA5528@yumi.tdiedrich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 06, 2009 at 07:03:23AM +0100, Tobias Diedrich wrote:
> Mel Gorman wrote:
> > [No BZ ID] Kernel crash on 2.6.31.x (kcryptd: page allocation failure..)
> > 	This apparently is easily reproducible, particular in comparison to
> > 	the other reports. The point of greatest interest is that this is
> > 	order-0 GFP_ATOMIC failures. Sven, I'm hoping that you in particular
> > 	will be able to follow the tests below as you are the most likely
> > 	person to have an easily reproducible situation.
> 
> I've also seen order-0 failures on 2.6.31.5:
> Note that this is with a one process hogging and mlocking memory and
> min_free_kbytes reduced to 100 to reproduce the problem more easily.
> 

Is that a vanilla, with patches 1-3 applied or both?

> I tried bisecting the issue, but in the end without memory pressure
> I can't reproduce it reliably and with the above mentioned pressure
> I get allocation failures even on 2.6.30.o
> 

To be honest, it's not entirely unexpected with min_free_kbytes set that
low. The system should cope with a certain amount of pressure but with
pressure and a low min_free_kbytes, the system will simply be reacting
too late to free memory in the non-atomic paths.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 0/15] spidernet driver bug fixes
Date: Wed, 13 Jun 2007 14:51:56 -0400
Message-ID: <46703CCC.5030607@garzik.org>
References: <20070607191707.GA7904@austin.ibm.com> <1181265151.6026.1.camel@concordia.ozlabs.ibm.com> <20070608170608.GI7904@austin.ibm.com> <20070608172020.GA31089@havoc.gtf.org> <20070611181429.GA4397@austin.ibm.com> <466F2581.2080808@garzik.org> <20070612233237.GN4397@austin.ibm.com> <466F3482.4050305@garzik.org> <20070613161414.GO4397@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Ellerman <michael@ellerman.id.au>, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org
To: Linas Vepstas <linas@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38359 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751018AbXFMSwD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2007 14:52:03 -0400
In-Reply-To: <20070613161414.GO4397@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linas Vepstas wrote:
> "git branch" shows that I'm on "upstream".  So I performed a "git pull" 
> (without any additional arguments) assuming that it would sync to your
> "upstream" branch.  And so my email was based on this.
> 
> Some googling seems to show that "git pull" has a bug/feature of
> ignoring the branch that one is working in, and pulling "master"
> no matter what.  I have no clue why; this seems broken to me.
> 
> So ... let me try again ... 
> git pull git://git.kernel.org/pub/scm/linux/kernel/git/jgarzik/netdev-2.6 upstream
> ...
> Automatic merge failed; fix up by hand

Unfortunately git isn't the greatest for saying "just give me what is on 
the remote", since each repository is an independent peer.

You need to:
* grab the latest torvalds/linux-2.6.git
* erase local netdev-2.6
* clone to create local netdev-2.6:
	URL=git//git.kernel.org/.../jgarzik/netdev-2.6
	git-clone --reference linux-2.6 $URL netdev-2.6
* that creates 'master' branch, which always equals vanilla upstream
* now create a local upstream branch:
	git checkout -b upstream master
* and finally, pull remote upstream branch into local upstream branch:
	git pull $URL upstream:upstream

Occasionally the remote 'upstream' will get "rebased", which means is 
has been completely replaced by a new linear history.  If you pull 
'upstream' after a rebase, into a local 'upstream', git will attempt to 
merge the same patches all over again, with disastrous results.

I wish there was a git option to "just make my shit look like the 
remote, dammit!"  The above is the "easiest" way I know how to do that.

	Jeff




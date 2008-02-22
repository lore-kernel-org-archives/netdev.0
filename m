From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: lockdep warning
Date: Fri, 22 Feb 2008 18:01:33 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0802221757130.30955@jikos.suse.cz>
References: <20080222104049.BD95A93C12F@tippex.mynet.homeunix.org>
 <Pine.LNX.4.64.0802221214020.7699@twin.jikos.cz>
 <20080222131608.7FC1E93C12F@tippex.mynet.homeunix.org>
 <Pine.LNX.4.64.0802221420250.30955@jikos.suse.cz>
 <20080222163213.5BDE293C12F@tippex.mynet.homeunix.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Anders Eriksson <aeriksson@fastmail.fm>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:55493 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751934AbYBVRBf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Feb 2008 12:01:35 -0500
In-Reply-To: <20080222163213.5BDE293C12F@tippex.mynet.homeunix.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 22 Feb 2008, Anders Eriksson wrote:

> > > Any chance that
> > > 	git revert 69cc64d8d92
> > > makes this report go away?  
> I've tested the patch and I no longer get that lock thing in my syslog.

Thanks for verification.

Hmm, I don't immediately see how this patch could make neigh->lock owner 
to change between lock and unlock ... I have skimmed through the solicit 
methods, and they don't seem to be doing anything nasty to neigh ...

The scenario I was thinking about is that before 69cc64d8d92, if any of 
the _solicit methods could do anything bad to neigh struct, this warning 
wouldn't trigger, because the lock has been dropped before calling 
_solicit() and reacquired later, so no mismatch on ->current could happen, 
but now as long as the lock is held during _solicit() call, this would 
trigger on the next unlock.

But I am not able to see anything like that in the code. Dave, do you have 
any idea? (the thread started at http://lkml.org/lkml/2008/2/22/105).

-- 
Jiri Kosina
SUSE Labs

From: Patrick McManus <mcmanus@ducksong.com>
Subject: Re: [fixed] [patch] Re: [bug] stuck localhost TCP connections,
	v2.6.26-rc3+
Date: Tue, 03 Jun 2008 10:41:22 -0400
Message-ID: <1212504082.28319.155.camel@tng>
References: <20080529084524.GA24892@elte.hu>
	 <Pine.LNX.4.64.0805291332401.16829@wrl-59.cs.helsinki.fi>
	 <20080529112257.GA18130@elte.hu> <20080530181839.GA31915@elte.hu>
	 <20080531060947.GA26441@elte.hu>
	 <Pine.LNX.4.64.0805311431100.2329@wrl-59.cs.helsinki.fi>
	 <Pine.LNX.4.64.0805311505410.2329@wrl-59.cs.helsinki.fi>
	 <20080531125428.GA22111@elte.hu>
	 <Pine.LNX.4.64.0805311555570.2329@wrl-59.cs.helsinki.fi>
	 <20080531163501.GB22607@elte.hu>  <20080603094057.GA29480@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Andrew Morton <akpm@linux-foundation.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from linode.ducksong.com ([64.22.125.164]:38704 "EHLO
	linode.ducksong.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753876AbYFCOkv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 10:40:51 -0400
In-Reply-To: <20080603094057.GA29480@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-06-03 at 11:40 +0200, Ingo Molnar wrote:
> * Ingo Molnar <mingo@elte.hu> wrote:
> 
> > > ...setsockopt(listenfd, SOL_TCP, TCP_DEFER_ACCEPT, &val, 
> > > sizeof(val)) seems to be the magic trick that is interestion here.
> > 
> > seems to be used:
> > 
> >  22003 write(3, "distccd[22003] (dcc_listen_by_ad"..., 62) = 62
> >  22003 listen(4, 10)                     = 0
> >  22003 setsockopt(4, SOL_TCP, TCP_DEFER_ACCEPT, [1], 4) = 0
> > 
> > i'll queue up your reverts for testing in -tip.
> 
> update: your 3 reverts in tip/out-of-tree [commit dad98991c] definitely 
> fixed the hangs!
> 
> Here is the testing i did:


hm.

Here's a theory - the DA code put the socket in the accept queue after
data has been queued on the socket, instead of the other way around
which is normal.

Could this be confusing the select() mechanism?

-Pat









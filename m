From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] e1000e: Change wthresh to 1 to avoid possible Tx
 stalls.
Date: Tue, 09 Oct 2012 23:02:07 +0200
Message-ID: <1349816527.21172.5303.camel@edumazet-glaptop>
References: <20120606174355.823e9aa7.shimoda.hiroaki@gmail.com>
	 <1339030752.2075.1.camel@jtkirshe-mobl>
	 <1339043085.26966.77.camel@edumazet-glaptop>
	 <1339044752.2075.14.camel@jtkirshe-mobl>
	 <loom.20121009T020718-563@post.gmane.org>
	 <1349762863.21172.3848.camel@edumazet-glaptop>
	 <20121009103629.0000569a@unknown>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Frank Reppin <frank@undermydesk.org>, netdev@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	e1000-devel@lists.sourceforge.net
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:45644 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756508Ab2JIVCY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2012 17:02:24 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so2914582bkc.19
        for <netdev@vger.kernel.org>; Tue, 09 Oct 2012 14:02:22 -0700 (PDT)
In-Reply-To: <20121009103629.0000569a@unknown>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-10-09 at 10:36 -0700, Jesse Brandeburg wrote:
> > > > Jesse did not share any performance numbers with me, I am sure he can
> > > > give some background tomorrow when he is back online.
> > > > 
> > > > I am working on an alternative patch now and should have something to
> > > > share tomorrow.
> > > Please allow me to ask if there's any progess here?
> > > 
> > > I've tried 3.5.4 a couple of days ago on a SuperMicro X8SIE-LN4 (82574L)
> > > and could still observe severe latency (up to 3000ms) spikes.
> > > 
> > > Applying Hiroakis suggested patch did fix this for me as well.
> > > [please note as well that I didn't had this issue in any 3.4.x kernel
> > > before - so +1 for fixing the regression]
> 
> I'm not sure what went wrong internally here that this hasn't been
> fixed, and I'm personally embarrassed.  I am working on it until I have
> a patch/solution.
> 
> currently am trying to reproduce the issue, am in some weird how to
> use BQL limbo, the lack of documentation on user usage of BQL is slowing
> me down.
> 

BQL is blocking qdisc from delivering additional packet to TX as long as
previous packets were not completed. Not sure what you want to know
about BQL.

> Hints or clues (I'm trying to follow the repro steps mentioned in
> some related threads) are appreciated.


Problem is BQL depends on TX completion being done in a reasonable time.

It seems e1000e can hold an skb in TX ring for up to 3000ms (not
reasonable it seems)

Aggregation / coalescing is fine, as long as we dont hold a packet too
long, in case no other packet follows.

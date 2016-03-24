From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH 1/1] net: Add SO_REUSEPORT_LISTEN_OFF socket option as
 drain mode
Date: Thu, 24 Mar 2016 15:22:22 +0100
Message-ID: <20160324142222.GB7237@1wt.eu>
References: <20151216161514.GA3476@1wt.eu>
 <CAO5YkUSL=k3UxmuqkGN666YSvH-=UGKCZvRgqqBnnr1EPRqRtw@mail.gmail.com>
 <20151218185812.GD4448@1wt.eu>
 <1450492683.8474.123.camel@edumazet-glaptop2.roam.corp.google.com>
 <20151219070009.GA4634@1wt.eu>
 <CALx6S35248apbWqtG+g2U99O=4UJqyAG0bJeuxhZWtShrpDF+w@mail.gmail.com>
 <20151221204127.GC8018@1wt.eu>
 <CALmu+SwjG0GVocGufTbgX-WJfcsP85SvHB=xtW7qQX3kZwJCxg@mail.gmail.com>
 <20160324061222.GA6807@1wt.eu>
 <1458828813.10868.65.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tolga Ceylan <tolga.ceylan@gmail.com>,
	Tom Herbert <tom@herbertland.com>, cgallek@google.com,
	Josh Snyder <josh@code406.com>,
	Aaron Conole <aconole@bytheb.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wtarreau.pck.nerim.net ([62.212.114.60]:32089 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756002AbcCXOWd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Mar 2016 10:22:33 -0400
Content-Disposition: inline
In-Reply-To: <1458828813.10868.65.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Thu, Mar 24, 2016 at 07:13:33AM -0700, Eric Dumazet wrote:
> On Thu, 2016-03-24 at 07:12 +0100, Willy Tarreau wrote:
> > Hi,
> > 
> > On Wed, Mar 23, 2016 at 10:10:06PM -0700, Tolga Ceylan wrote:
> > > I apologize for not properly following up on this. I had the
> > > impression that we did not want to merge my original patch and then I
> > > also noticed that it fails to keep the hash consistent. Recently, I
> > > read the follow ups on it as well as Willy's patch/proposals.
> > > 
> > > Is there any update on Willy's SO_REUSEPORT patch? IMHO, it solves the
> > > problem and it is simpler than adding new sock option.
> > 
> > no, Craig's changes were merged, and I haven't checked yet if my patch
> > needs to be rebased or still applies. Feel free to check it and resubmit
> > if you have time.
> 
> No need for a patch AFAIK.
> 
> BPF solution is generic enough.
> 
> All user space needs to do is to update the BPF filter so that the
> listener needing to be dismantled does not receive any new packet.

But that means that any software making use of SO_REUSEPORT needs to
also implement BPF on Linux to achieve the same as what it does on
other OSes ? Also I found a case where a dying process would still
cause trouble in the accept queue, maybe it's not redistributed, I
don't remember, all I remember is that my traffic stopped after a
segfault of only one of them :-/ I'll have to dig a bit regarding
this.

Thanks,
Willy

From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH 3/3] tc: pedit: Fix retain value for ihl
 adjustments
Date: Mon, 7 Mar 2016 13:57:44 +0100
Message-ID: <20160307125744.GC13481@orbyte.nwl.cc>
References: <1456917631-18447-1-git-send-email-phil@nwl.cc>
 <499abfe479324d1e83289cd68b2a7641@HQ1WP-EXMB11.corp.brocade.com>
 <20160302095414.45a928df@xeon-e3>
 <56D84863.5090203@mojatatu.com>
 <20160303143229.GC18624@orbyte.nwl.cc>
 <56DD642D.8010401@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemming@brocade.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:46827 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752180AbcCGM5q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2016 07:57:46 -0500
Content-Disposition: inline
In-Reply-To: <56DD642D.8010401@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mon, Mar 07, 2016 at 06:21:17AM -0500, Jamal Hadi Salim wrote:
> On 16-03-03 09:32 AM, Phil Sutter wrote:
> >> The patches look good to me. Phil, maybe get rid of that comment at the
> >> top which was worrying about endianness. I think you fixed it.
> >
> > I'm not so sure. The kernel explicitly takes care to get the bit
> > ordering right:
> >
> [..]
> > act_pedit though just mangles the whole byte as-is, and if that was
> > correct, we would not have to go that extra mile in struct iphdr, or do
> > we?
> >
> 
> I meant in general - the note to say that there are endianes issues
> should go.

Sorry, I didn't get that yet: To me it looks as if on a big-endian
system, the code will actually change the Version field instead of IHL.
Probably the proof of the pudding is in the eating, so I'll try to get
access to a big-endian system for testing.

> >> These would of course require more of a larger setup to vet
> >> and running tcpdump to check the correct bytes are being
> >> modified.
> >
> 
> Indeed - That is how i normally would test. It is more complex.
> Your scheme is good - but will not catch a kernel bug.

Sure. OTOH the algorithm in act_pedit is not overly complex. Plus,
fixing one side only prevents accidental workarounds of other side's
bugs.

> > Since I am lazy, I wanted to have as much automation as possible while
> > testing. Therefore I just assumed that act_pedit does the right thing
> > all the time,
> 
> famous last words ;->

:)

> > and iproute just has to feed it correct values. Given the
> > scope of this patch, this is also completely sufficient. Of course, the
> > tests/ directory would benefit more from a full test. But since
> > automation then becomes tricky, I'm not sure it makes much sense to
> > deliberately write code for that.
> >
> 
> Your test is still useful and i think should go into the tests dir.

OK, I'll give it a thought.

Thanks, Phil

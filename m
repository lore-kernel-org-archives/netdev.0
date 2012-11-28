From: Krzysztof Mazur <krzysiek@podlesie.net>
Subject: Re: [PATCH v3 8/7] pppoatm: fix missing wakeup in pppoatm_send()
Date: Wed, 28 Nov 2012 10:58:43 +0100
Message-ID: <20121128095843.GA8974@shrek.podlesie.net>
References: <201211112257.qABMvhP4021769@thirdoffive.cmf.nrl.navy.mil>
 <1354022867.26346.334.camel@shinybook.infradead.org>
 <20121127102333.68ac3234@thirdoffive.cmf.nrl.navy.mil>
 <1354063697.21562.4.camel@shinybook.infradead.org>
 <20121128081237.GA30488@shrek.podlesie.net>
 <1354094649.21562.34.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1354094649.21562.34.camel@shinybook.infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 28, 2012 at 09:24:09AM +0000, David Woodhouse wrote:
> On Wed, 2012-11-28 at 09:12 +0100, Krzysztof Mazur wrote:
> > On Wed, Nov 28, 2012 at 12:48:17AM +0000, David Woodhouse wrote:
> > > On Tue, 2012-11-27 at 10:23 -0500, chas williams - CONTRACTOR wrote:
> > > > yes, but dont call it 8/7 since that doesnt make sense.
> > > 
> > > It made enough sense when it was a single patch appended to a thread of
> > > 7 other patches from Krzysztof. But now it's all got a little more
> > > complex, so I've tried to collect together the latest version of
> > > everything we've discussed:
> > 
> > There was also discussion about patch 9/7 "pppoatm: wakeup after ATM
> > unlock only when it's needed".
> 
> True. Is that really necessary? How often is the lock actually taken? Is
> it once per packet that PPP sends (which is mostly just LCP
> echo/response during an active connection)? And does that really warrant
> the optimisation?
> 
> This is a tasklet that we used to run after absolutely *every* packet,
> remember. Optimising *that* made sense, but I'm less sure it's worth the
> added complexity for this case. As I have a vague recollection that we
> decided we couldn't use the existing BLOCKED bit for it... or can we? 
> 
> Can this work? Feel free to replace that test_bit() and the
> corresponding comment, with a test_and_clear_bit() and a new comment
> explaining *why* it's safe... while I go make another cup of tea.
> 

ok, I think that we should just drop that patch, with test_bit()
I think it's no longer an optimization.

Krzysiek

From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [GIT] Networking
Date: Mon, 7 Nov 2011 12:40:55 +0100
Message-ID: <20111107114054.GA2395@redhat.com>
References: <20111025.063206.2273357152859701628.davem@davemloft.net>
 <CA+55aFzkZofnUmBOGVvmNKyA0_FApo73xZ7J=aevbHPS_0+xKQ@mail.gmail.com>
 <1320426222.3969.121.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	"Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>,
	"Guy, Wey-Yi W" <wey-yi.w.guy@intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1320426222.3969.121.camel@jlt3.sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 04, 2011 at 06:03:42PM +0100, Johannes Berg wrote:
> On Tue, 2011-10-25 at 12:26 +0000, Linus Torvalds wrote:
> > On Tue, Oct 25, 2011 at 12:32 PM, David Miller <davem@davemloft.net> wrote:
> > >
> > > The most visible thing in here is the reorganization of the drivers
> > > under drivers/net.
> > 
> > Nope, the most visible thing are some new annoying warnings, that seem
> > absolutely broken.
> > 
> > At the very minimum, that WARN_ON(1) should be a WARN_ON_ONCE() or
> > something like that. Because showing it over an dover again is not
> > helpful.
> > 
> > Added the people who signed off on the changes to the affected files,
> > since they hopefully know why this happens and can fix it..
> 
> Sorry for the late reply.
> 
> I think this was actually caused by some changes from Ben Greear
> "optimising" stuff in net/mac80211/work.c and keeping the wrong channel,
> Stanislaw was also looking at this at some point I think. I agree that
> it would be good to change to WARN_ON_ONCE(), will do that.
> 
> The warning itself has been around forever, but the fact that it
> triggers now is probably related to the channel work & band switches.

I think this problem is related with linuxcon :-) and it is not current
regression, i.e. Ben's off-channel code was already committed in 3.0.
I have also RHEL6 - 2.6.32 bug report about that:
https://bugzilla.redhat.com/show_bug.cgi?id=749125

Probably there was something special on linuxcon wireless network (i.e.
big contention) what cause people start to see this warning. Eventually
nobody use wireless except conferences :-/

I have one pending patch which fix other instance of the warning (started
at ieee80211_tx_status()). I'll post it today. As Ben mentioned, two
fixes are pending in wireless-testing tree:

http://git.kernel.org/?p=linux/kernel/git/linville/wireless-testing.git;a=commitdiff;h=682ba5a44516529b29fc780c055e06104d36e31e
http://git.kernel.org/?p=linux/kernel/git/linville/wireless-testing.git;a=commitdiff;h=776308dd5fa8a41e8bbb79818a66bd68a7db757e 

However, I'm not sure if that cover all possible situations when
warning can be triggered. We need to do a careful review of channel
switching in mac80211.

Stanislaw

From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: Top kernel oopses/warnings for the week of October 7th, 2008
Date: Wed, 8 Oct 2008 14:43:16 +0200
Message-ID: <200810081443.17852.rjw@sisk.pl>
References: <48EBBE15.9030905@linux.intel.com> <200810081106.55730.rjw@sisk.pl> <20081008092136.GA22387@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, alan@lxorguk.ukuu.org.uk,
	arjan@linux.intel.com, linux-kernel@vger.kernel.org,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-acpi@vger.kernel.org, tglx@tglx.de,
	tytso@mit.edu, linux-ide@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-ide-owner@vger.kernel.org>
In-Reply-To: <20081008092136.GA22387@elte.hu>
Content-Disposition: inline
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday, 8 of October 2008, Ingo Molnar wrote:
> 
> * Rafael J. Wysocki <rjw@sisk.pl> wrote:
> 
> > On Wednesday, 8 of October 2008, David Miller wrote:
> > > From: Alan Cox <alan@lxorguk.ukuu.org.uk>
> > > Date: Tue, 7 Oct 2008 23:58:33 +0100
> > > 
> > > > > This should have been fixed by:
> > > > > http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=f5a6d958b5d0a10e7e7a9dee1862fb31d08c6d26
> > > > 
> > > > You mean - hidden by - that change should IMHO be reverted
> > > 
> > > Grrr... I totally agree.
> > 
> > Even though they are false positives in many cases?
> > 
> > (Yes, they are).
> 
> it's your judgement call i guess - i just wanted to challenge the 
> terminology of calling it a fix ;-)

Well, since I added the WARN_ON() and then reallized it did more harm than
good, I consider it as a fix. :-)

> Can you think of any good way of reintroducing the good aspect of the 
> WARN(), without the false positives? [ If not, and if the WARN()s do 
> more harm than good then it's the right change. ]

Unfortunately not.  In particular, the MMC subsystem is known to trigger this
WARN_ON() which in turn is not related to any functional problem (it's a design
issue in this case) and it's not going to be fixed any time soon IMO.

USB used to trigger it too, but that has been fixed already.

> But generally the trend is the opposite direction: we try to add as many 
> WARN()s as possible, and we need even more good WARN()s in the kernel. 
> When we meet false positives we try to improve the quality/yield of the 
> warning, not eliminate it.
> 
> Granted, they are a bit embarrassing when they show up in the top 10 but 
> they are also very helpful and are tracked very nicely and lead to 
> actual bugfixes that _matter_.
> 
> Kerneloops.org is a wonderful tool: it enables a broad spectrum of users 
> to help us out with their feedback, without them being forced into any 
> manual work, and without them having to understand the kernel bug 
> reporting workflow. Its scale is already enormous: 3000+ bugs reported 
> per week. (many kudos Arjan!)
> 
> Once its growth stabilizes (all the large distros have it either enabled 
> today or have the client in their pipeline) we can even observe 
> long-term trends and estimate release-to-release suckiness. That was 
> impossible before and maintainers were left largely to imprecise 
> intuitive guesses about where we stand wrt. kernel quality.

While I agree with all that, I also think that it's not really reasonable to
use WARNs causing people to waste their time for reporting issues that actually
don't need to be reported.

IMO it will make sense to add this WARN_ON() back again in future, but not at
the moment.

Thanks,
Rafael

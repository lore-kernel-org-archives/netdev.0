From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [TCP]: TCP_DEFER_ACCEPT causes leak sockets
Date: Wed, 18 Jun 2008 22:08:06 +0200
Message-ID: <20080618200805.GA18756@elte.hu>
References: <20080617083220.GA11393@elte.hu>
	<20080617.020840.169830916.davem@davemloft.net>
	<20080617092706.GB20621@elte.hu>
	<20080617.022909.173003136.davem@davemloft.net>
	<20080617093929.GA10334@elte.hu> <48595910.8000905@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: vgusev@openvz.org, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org, rjw@sisk.pl,
	mcmanus@ducksong.com, ilpo.jarvinen@helsinki.fi,
	kuznet@ms2.inr.ac.ru, Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>, xemul@openvz.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <48595910.8000905@intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


* Kok, Auke <auke-jan.h.kok@intel.com> wrote:

> > Any ideas about what i should try next?
> 
> have you tried e1000e?

will try it.

But even it if solves the problem it's a nasty complication: given how 
many times i have to bisect back into the times when there was only 
e1000 around, how do i handle the transition? I have automated bisection 
tools, etc. and i bisect very frequently.

It's a real practical problem for me: if i have E1000E=y in my .config 
and go back to an older kernel, i lose that .config setting in 'make 
oldconfig'. Then when the bisection run happens to go back into the 
E1000E times, 'make oldconfig' picks up E1000E with a default-off 
setting - and things break or work differently.

no other Linux driver i'm using forces me to do that and i rely on many 
of them and i rely on proper 'make oldconfig' behavior on a daily basis. 
Until now i was able to do automatic bisection back for _years_, to the 
v2.6.19 times. You broke that.

And that's just one driver out of thousands of Linux drivers. Imagine 
what happened to bisectability and migration quality if every driver 
version update was this careless about its installed base as 
e1000/e1000e.

The e1000 -> e1000e migration it was not only done in an incompetent, 
amateurish way, you also ignored real feedback and that combined 
together is totally lame and inacceptable behavior in my book. You 
should not expect praise and roses from me as long as you do stupid 
things like that.

	Ingo

-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php

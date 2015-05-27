From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: tcp: Fix a PTO timing granularity issue
Date: Wed, 27 May 2015 07:56:25 -0700
Message-ID: <1432738585.4060.392.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1432663992.4060.286.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1432671437-19140-1-git-send-email-ido@wizery.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1CB40A1A@AcuExch.aculab.com>
	 <1432734077.4060.382.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150527144029.GA558@WorkStation.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Nandita Dukkipati <nanditad@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Ido Yariv <idox.yariv@intel.com>
To: Ido Yariv <ido@wizery.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150527144029.GA558@WorkStation.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-05-27 at 10:40 -0400, Ido Yariv wrote:

> HZ=100 is used on some embedded platforms, so it's still something we
> have to deal with unfortunately..
> 
> Since the '2' here is a lower bound, and msecs_to_jiffies(10) will
> return values greater than 2 for HZ>100 anyway, always ensuring the
> 2 jiffies lower bound shouldn't impact the behavior when HZ=1000.
> 
> However, as far as I can tell, comparing msecs_to_jiffies(10) to 2, or
> comparing the whole timeout to 2 doesn't make much difference, since
> msecs_to_jiffies isn't inlined.
> 
> In other words, keeping the #if shouldn't make much difference in behavior,
> but will save the small comparison.

Yes, I guess David point is to have a macro in include/linux/tcp.h so
that we can have a nice comment, and not having #if ... in a C file.

Maybe other timers in TCP need the same care (I am not asking you to
find them, but having a macro would ease things perhaps)

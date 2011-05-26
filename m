From: Joe Perches <joe@perches.com>
Subject: Re: [patch] net/core/filter.c: Fix build error
Date: Thu, 26 May 2011 08:31:06 -0700
Message-ID: <1306423866.16087.10.camel@Joe-Laptop>
References: <cover.1305999731.git.joe@perches.com>
	 <efa062542c692c3f7743bf2d97b5987ab989e27e.1305999731.git.joe@perches.com>
	 <20110526123153.GA16002@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110526123153.GA16002@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2011-05-26 at 14:31 +0200, Ingo Molnar wrote:
> * Joe Perches <joe@perches.com> wrote:
> > A mis-configured filter can spam the logs with lots of stack traces.
> > Rate-limit the warnings and add printout of the bogus filter information.
> > Original-patch-by: Ben Greear <greearb@candelatech.com>
> > Signed-off-by: Joe Perches <joe@perches.com>
> > ---
> >  net/core/filter.c |    4 +++-
> >  1 files changed, 3 insertions(+), 1 deletions(-)
> > 
> > diff --git a/net/core/filter.c b/net/core/filter.c
> > index 0eb8c44..0e3622f 100644
> > --- a/net/core/filter.c
> > +++ b/net/core/filter.c
> > @@ -350,7 +350,9 @@ load_b:
> >  			continue;
> >  		}
> >  		default:
> > -			WARN_ON(1);
> > +			WARN_RATELIMIT(1, "Unknown code:%u jt:%u tf:%u k:%u\n",
> > +				       fentry->code, fentry->jt,
> > +				       fentry->jf, fentry->k);
> >  			return 0;
> >  		}
> This change (now upstream) fails to build in about 20% of all 
> randconfigs. Fix is below.

We've had problems with ratelimit uses in the past
as well.

There's a logical separation issue with the #includes
of bug.h, printk.h, ratelimit.h kernel.h and the
spinlock includes.

My suggestion would be to see about again adding
#include <linux/ratelimit.h> somehow
back to kernel.h which commit 3fff4c42bd0a removed
in 2009 because of the spinlock issues.

Any suggestion on how best to fix it generically?

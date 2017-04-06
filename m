From: Mike Galbraith <efault@gmx.de>
Subject: Re: net/sched: latent livelock in dev_deactivate_many() due to
 yield() usage
Date: Thu, 06 Apr 2017 03:28:34 +0200
Message-ID: <1491442114.4718.35.camel@gmx.de>
References: <1491107321.13631.33.camel@gmx.de>
         <20170405173105.7f41d7fc@plumbers-lap.home.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Peter Zijlstra <peterz@infradead.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170405173105.7f41d7fc@plumbers-lap.home.lan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-04-05 at 17:31 -0700, Stephen Hemminger wrote:
> On Sun, 02 Apr 2017 06:28:41 +0200
> Mike Galbraith <efault@gmx.de> wrote:
> 
> > Livelock can be triggered by setting kworkers to SCHED_FIFO, then
> > suspend/resume.. you come back from sleepy-land with a spinning
> > kworker.  For whatever reason, I can only do that with an enterprise
> > like config, my standard config refuses to play, but no matter, it's
> > "Typical broken usage".
> > 
> > (yield() should be rendered dead)
> 
> The kernel is not normally built to have kworkers run at SCHED_FIFO.
> The user has do some action to alter the process priorities.
> 
> I classify this as user error. We don't support killing kworker threads
> either.

We'll have to agree to disagree on that.  I assert that any thread that
must run as SCHED_OTHER in order to be safe is in fact broken.

	-Mike

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: net/sctp: vmalloc allocation failure in
 sctp_setsockopt/xt_alloc_table_info
Date: Wed, 30 Nov 2016 17:21:45 -0200
Message-ID: <20161130192145.GB13169@localhost.localdomain>
References: <CAAeHK+wecw6ST_DWJQBLFNwVsOVgderGE-EEJiN0-kf796XHtw@mail.gmail.com>
 <20161128141340.GA29839@hmsreliant.think-freely.org>
 <CAAeHK+xJmwF6hddS-sO-y3HQkRicwQN=ZceFWTZT2M_0h4E2hQ@mail.gmail.com>
 <20161128143931.GB29839@hmsreliant.think-freely.org>
 <20161128151312.GA13172@localhost.localdomain>
 <20161128174647.GC29839@hmsreliant.think-freely.org>
 <20161128174710.GE28510@breakpoint.cc>
 <20161128175626.GD29839@hmsreliant.think-freely.org>
 <20161128180925.GF28510@breakpoint.cc>
 <20161128181803.GA13159@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Horman <nhorman@tuxdriver.com>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        netfilter-devel@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161128181803.GA13159@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 28, 2016 at 04:18:03PM -0200, Marcelo Ricardo Leitner wrote:
> On Mon, Nov 28, 2016 at 07:09:25PM +0100, Florian Westphal wrote:
> > Neil Horman <nhorman@tuxdriver.com> wrote:
> > 
> > [ trimming CCs ]
> > 
> > > On Mon, Nov 28, 2016 at 06:47:10PM +0100, Florian Westphal wrote:
> > > > Neil Horman <nhorman@tuxdriver.com> wrote:
> > > > > I'm not sure I agree with that.  Generally speaking it seems like the right
> > > > > thing to do, if you want to avoid filling logs with warnings, but this is the
> > > > > sort of error that is going to be accompanied by severe service interruption.
> > > > > I'd rather see a reason behind that in the logs, than just have it occur
> > > > > silently.
> > > > 
> > > > Its not silent -- the setsockopt call will fail and userspace should
> > > > display an error.
> > > > 
> > > Thats not true.  If the OOM succedes in freeing enough memory to fulfill the
> > > request the setsockopt may complete without error, you're just left with a
> > > killed process...somewhere.  Thats seems a bit dodgy to me
> > 
> 
> __GFP_NOWARN is about allocation failures only and it won't disable OOM
> kill messages.  oom_kill_process() has no idea on GFP_NOWARN when doing
> the logging.
> 
> > We should prevent OOM killer from running in first place (GFP_NORETRY should work).
> 
> Oh. Really?
> 

Now I see why. Then we're basically saying that's better to fail this
operation than to kill some random process around.
And kmalloc() is already using GFP_NORETRY in this same place.

  Marcelo

From: Jesse Barnes <jbarnes@engr.sgi.com>
Subject: Re: [PATCH 2.6.11-rc4-mm1] connector: Add a fork connector
Date: Wed, 2 Mar 2005 09:48:26 -0800
Message-ID: <200503020948.27263.jbarnes@engr.sgi.com>
References: <1109240677.1738.196.camel@frecb000711.frec.bull.fr> <1109753292.8422.117.camel@frecb000711.frec.bull.fr> <20050302065152.79d9fba2.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Guillaume Thouvenin <guillaume.thouvenin@bull.net>, akpm@osdl.org,
        linux-kernel@vger.kernel.org, johnpol@2ka.mipt.ru,
        elsa-devel@lists.sourceforge.net, jlan@engr.sgi.com, gh@us.ibm.com,
        efocht@hpce.nec.com, netdev@oss.sgi.com, kaigai@ak.jp.nec.com
To: Paul Jackson <pj@sgi.com>
In-Reply-To: <20050302065152.79d9fba2.pj@sgi.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wednesday, March 2, 2005 6:51 am, Paul Jackson wrote:
> Guillaume wrote:
> >   I also run the lmbench and results are send in response to another
> > thread "A common layer for Accounting packages". When fork connector is
> > turned off the overhead is negligible.
>
> Good.
>
> If I read this code right:
> > +static inline void fork_connector(pid_t parent, pid_t child)
> > +{
> > + static DEFINE_SPINLOCK(cn_fork_lock);
> > + static __u32 seq;   /* used to test if message is lost */
> > +
> > + if (cn_fork_enable) {
>
> then the code executed if the fork connector is off is a call to an
> inline function that tests an integer, finds it zero, and returns.
>
> This is sufficiently little code that I for one would hardly
> even need lmbench to be comfortable that fork() wasn't impacted
> seriously, in the case that the fork connector is disabled.

But if it *is* enabled, it takes a global lock on every fork.  That can't 
scale on a big multiprocessor if lots of CPUs are doing lots of forks...

Jesse

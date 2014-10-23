From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: localed stuck in recent 3.18 git in copy_net_ns?
Date: Thu, 23 Oct 2014 08:33:33 -0700
Message-ID: <20141023153333.GA19278@linux.vnet.ibm.com>
References: <CAHA+R7OUHy8XFPoip5gPvr1uqwkxgKxoSMf_pSgB1aFx=XCs8g@mail.gmail.com>
 <8738aghtyj.fsf@x220.int.ebiederm.org>
 <20141022181135.GH4977@linux.vnet.ibm.com>
 <87d29kezby.fsf@x220.int.ebiederm.org>
 <20141022185511.GI4977@linux.vnet.ibm.com>
 <CA+5PVA56ajrBQ-C9orSb9-_qhMKe994QL2x0FcKbe6BYmaWFBw@mail.gmail.com>
 <20141022224032.GA1240@declera.com>
 <20141022232421.GN4977@linux.vnet.ibm.com>
 <1414044566.2031.1.camel@declera.com>
 <20141023122750.GP4977@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Josh Boyer <jwboyer@fedoraproject.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Cong Wang <cwang@twopensource.com>,
	Kevin Fenzi <kevin@scrye.com>, netdev <netdev@vger.kernel.org>,
	"Linux-Kernel@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>
To: Yanko Kaneti <yaneti@declera.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141023122750.GP4977@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 23, 2014 at 05:27:50AM -0700, Paul E. McKenney wrote:
> On Thu, Oct 23, 2014 at 09:09:26AM +0300, Yanko Kaneti wrote:
> > On Wed, 2014-10-22 at 16:24 -0700, Paul E. McKenney wrote:
> > > On Thu, Oct 23, 2014 at 01:40:32AM +0300, Yanko Kaneti wrote:
> > > > On Wed-10/22/14-2014 15:33, Josh Boyer wrote:
> > > > > On Wed, Oct 22, 2014 at 2:55 PM, Paul E. McKenney
> > > > > <paulmck@linux.vnet.ibm.com> wrote:
> > > 
> > > [ . . . ]
> > > 
> > > > > > Don't get me wrong -- the fact that this kthread appears to 
> > > > > > have
> > > > > > blocked within rcu_barrier() for 120 seconds means that 
> > > > > > something is
> > > > > > most definitely wrong here.  I am surprised that there are no 
> > > > > > RCU CPU
> > > > > > stall warnings, but perhaps the blockage is in the callback 
> > > > > > execution
> > > > > > rather than grace-period completion.  Or something is 
> > > > > > preventing this
> > > > > > kthread from starting up after the wake-up callback executes.  
> > > > > > Or...
> > > > > > 
> > > > > > Is this thing reproducible?
> > > > > 
> > > > > I've added Yanko on CC, who reported the backtrace above and can
> > > > > recreate it reliably.  Apparently reverting the RCU merge commit
> > > > > (d6dd50e) and rebuilding the latest after that does not show the
> > > > > issue.  I'll let Yanko explain more and answer any questions you 
> > > > > have.
> > > > 
> > > > - It is reproducible
> > > > - I've done another build here to double check and its definitely 
> > > > the rcu merge
> > > >   that's causing it.
> > > > 
> > > > Don't think I'll be able to dig deeper, but I can do testing if 
> > > > needed.
> > > 
> > > Please!  Does the following patch help?
> > 
> > Nope, doesn't seem to make a difference to the modprobe ppp_generic 
> > test
> 
> Well, I was hoping.  I will take a closer look at the RCU merge commit
> and see what suggests itself.  I am likely to ask you to revert specific
> commits, if that works for you.

Well, rather than reverting commits, could you please try testing the
following commits?

11ed7f934cb8 (rcu: Make nocb leader kthreads process pending callbacks after spawning)

73a860cd58a1 (rcu: Replace flush_signals() with WARN_ON(signal_pending()))

c847f14217d5 (rcu: Avoid misordering in nocb_leader_wait())

	For whatever it is worth, I am guessing this one.

a53dd6a65668 (rcutorture: Add RCU-tasks tests to default rcutorture list)

	If any of the above fail, this one should also fail.

Also, could you please send along your .config?

							Thanx, Paul

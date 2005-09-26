From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: ipvs_syncmaster brings cpu to 100%
Date: Sun, 25 Sep 2005 21:34:00 -0700
Message-ID: <20050926043400.GD5079@us.ibm.com>
References: <68559cef050908090657fc2599@mail.gmail.com> <498263350509081605956a771@mail.gmail.com> <68559cef05092207022f1f0df4@mail.gmail.com> <498263350509230815eb08a73@mail.gmail.com> <20050926032807.GI18357@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Roger Tsang <roger.tsang@gmail.com>, Luca Maranzano <liuk001@gmail.com>,
        "LinuxVirtualServer.org users  mailing list." <lvs-users@LinuxVirtualServer.org>,
        Dave Miller <davem@davemloft.net>,
        Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>,
        netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20050926032807.GI18357@verge.net.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 26.09.2005 [12:28:08 +0900], Horms wrote:
> On Fri, Sep 23, 2005 at 11:15:31AM -0400, Roger Tsang wrote:
> > As I've said before in this thread, you might want to try changing all the
> > ssleep() calls to schedule_timeout().
> > 
> > Roger
> > 
> > 
> > On 9/22/05, Luca Maranzano <liuk001@gmail.com> wrote:
> > >
> > > Hello all,
> > >
> > > here again trying to discover the reason ot the CPU hog for
> > > ipvs_sync{master,backup}.
> > >
> > > I've digged in the sources for ip_vs_sync.c and the main differences
> > > between kernel 2.6.8 and 2.6.12 is the use of ssleep() instead of
> > > schedule_timeout().
> > >
> > > The oddity I've seen is that in the header of both files, the version
> > > is always like this:
> > >
> > > * Version: $Id: ip_vs_sync.c,v 1.13 2003/06/08 09:31:19 wensong Exp $
> > > *
> > > * Authors: Wensong Zhang <wensong@linuxvirtualserver.org>
> > >
> > > Is Wensong still the maintainer for this code?
> 
> Yes, although he is kind of quiet.
> 
> > > Furthermore, if I make an "rgrep" in the source tree of kernel 2.6.12
> > > the function schedule_timeout() is more used than the ssleep() (517
> > > occurrencies vs. 43), so why in ip_vs_sync.c there was this change?
> > >
> > > The other oddity is that Horms reported on this list that on non Xeon
> > > CPU the same version of kernel of mine does not present the problem.
> > >
> > > I'm getting crazy :-)
> 
> I've prepared a patch, which reverts the change which was introduced
> by Nishanth Aravamudan in February.

Was the 100% cpu utilization only occurring on Xeon processors?

Care to try to use msleep_interruptible() instead of ssleep(), as
opposed to schedule_timeout()?

In your patch, you do not need to set the state back to TASK_RUNNING,
btw.

Thanks,
Nish

From: margitsw@t-online.de (Margit Schubert-While)
Subject: Re: [PATCH 2.6.9-rc2 17/38] net/islpci_dev: replace
 schedule_timeout() with msleep()
Date: Fri, 24 Sep 2004 09:43:10 +0200
Sender: prism54-devel-bounces@prism54.org
Message-ID: <5.1.0.14.2.20040924074745.00b1cd40@pop.t-online.de>
References: <20040923221303.GB13244@us.ibm.com>
	<20040923221303.GB13244@us.ibm.com> <20040923225507.GI30131@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Cc: netdev@oss.sgi.com, mcgrof@studorgs.rutgers.edu,
	prism54-devel@prism54.org, hvr@gnu.org,
	kernel-janitors@lists.osdl.org, jgarzik@pobox.com
Return-path: <prism54-devel-bounces@prism54.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
In-Reply-To: <20040923225507.GI30131@ruslug.rutgers.edu>
References: <20040923221303.GB13244@us.ibm.com>
	<20040923221303.GB13244@us.ibm.com>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org

Hi Nish,
At 18:55 23.09.2004 -0400, Luis scribeth:
>On Thu, Sep 23, 2004 at 03:13:03PM -0700, Nishanth Aravamudan wrote:
> > Any comments would be appreciated.
> >
> > Description: Use msleep() instead of schedule_timeout()
> > to guarantee the task delays as expected. Also set_current_state() is
> > inserted before schedule_timeout(). If the for-loop were to execute
> > twice, the second time would not set the state before sleeping in the
> > current code; this causes schedule_timeout() to return immediately.
> >
> > Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
> >
> > --- 
> 2.6.9-rc2-vanilla/drivers/net/wireless/prism54/islpci_dev.c 
> 2004-09-13 17:15:41.000000000 -0700
> > +++ 
> 2.6.9-rc2/drivers/net/wireless/prism54/islpci_dev.c       2004-09-23 
> 13:58:42.000000000 -0700
> > @@ -436,8 +436,7 @@ prism54_bring_down(islpci_private *priv)
> >       wmb();
> >
> >       /* wait a while for the device to reset */
> > -     set_current_state(TASK_UNINTERRUPTIBLE);
> > -     schedule_timeout(50*HZ/1000);
> > +     msleep(50);
> >
> >       return 0;
> >  }
> > @@ -489,6 +488,7 @@ islpci_reset_if(islpci_private *priv)
> >               /* The software reset acknowledge needs about 220 msec here.
> >               * Be conservative and wait for up to one second. */
> >
> > +             set_current_state(TASK_UNINTERRUPTIBLE);
> >               remaining = schedule_timeout(HZ);
> >
> >               if(remaining > 0) {
>
>
>Looks good to me. IIRC Margit had something to say about this last time
>this popped around -- CC'ing her to see if there are any outstanding
>comments.

You bet she has.

The patch has wrong line numbers. Doesn't take into account the stacked up
netdev changes. (Therefore CC'ing Jeff Garzik)

This breaks 2.4 compatibility.
So either backport to 2.4 or Nish can take over prism54 2.4 maintenance ;-)

Don't say a backport is not possible/reasonable, it happened with 
netdev_priv().
(In 2.4.27; At least there, we have HAVE_NETDEV_PRIV).

If this is going to be forced, can we at least have a
define HAVE_MSLEEP in delay.h ?

I am somewhat confused by the second part of the patch.
What has that got to do with msleep ?
Actually, the fix would appear to be correct, but that is a seperate issue
and nothing to do with msleep.
(Prims54 developers -> I'll take a look over the weekend)

I am sceptical about the whole msleep patchset as, by their own admission,
the janitors have/can not (no hardware) test the majority of the changes.
Even more worrying is that incorrect code has directly appeared in
mainline kernel BK.

Margit

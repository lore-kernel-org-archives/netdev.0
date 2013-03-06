From: anil dahiya <anildahiya80@gmail.com>
Subject: Re: igb_down from bottom half context
Date: Thu, 7 Mar 2013 00:18:07 +0530
Message-ID: <CAHGPgw0EV3-U+h5S0SFdEweUVcT68h5tdRkZbAwRqrNG5z2P+w@mail.gmail.com>
References: <CAGZFCEHrzDDtO8HGaUhuUb_vNddKyiXPzasnkvTqLOqS9SwaDw@mail.gmail.com>
	<1362591486.3126.1.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4481052004879087128=="
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-newbie <linux-newbie@vger.kernel.org>,
	ratheesh kannoth <ratheesh.ksz@gmail.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1362591486.3126.1.camel@bwh-desktop.uk.solarflarecom.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

--===============4481052004879087128==
Content-Type: multipart/alternative; boundary=14dae9cc9fbee8ac7b04d746073d

--14dae9cc9fbee8ac7b04d746073d
Content-Type: text/plain; charset=ISO-8859-1

You know, you are doing wrong thing i.e sleeping in interrupt context.

As suggested by Ben, move code work queue or somewhere else. Other option
is dont sleep here.

--Anil
On Wed, Mar 6, 2013 at 11:08 PM, Ben Hutchings <bhutchings@solarflare.com>wrote:

> On Wed, 2013-03-06 at 09:38 +0530, ratheesh kannoth wrote:
> > I  have kernel timer which  check for flag.
> >
> > if(flag ) {
> >           igb_down(adapter);
> >  } else {
> >          igb_up(adapter);
> >  }
> >
> >
> > I could see a kernel crash; because  there are a lot of  msleep() in
> > igb_down function.
> >
> > #define msleep(x)    do { set_current_state(TASK_UNINTERRUPTIBLE); \
> >                                 schedule_timeout((x * HZ)/1000 + 2); \
> >                               } while (0)
> >
> > sleep() is called from bottom half context; this is the cause of kernel
> crash.
> >
> > 1) Since timer call back dont have process context associated with it;
> > i think , "current" points to the last preempted task ?
> > 2) How can i introduce delays in interrupt context to avoid the kernel
> > crash. mdelay()  will work ?
> > 3) is there any better mechanism to do this job ?
>
> Use a work item and schedule_work().
>
> Ben.
>
> --
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-newbie" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at http://www.linux-learn.org/faqs
>

--14dae9cc9fbee8ac7b04d746073d--


--===============4481052004879087128==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Symantec Endpoint Protection 12 positioned as A LEADER in The Forrester  
Wave(TM): Endpoint Security, Q1 2013 and "remains a good choice" in the  
endpoint security space. For insight on selecting the right partner to 
tackle endpoint security challenges, access the full report. 
http://p.sf.net/sfu/symantec-dev2dev
--===============4481052004879087128==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============4481052004879087128==--

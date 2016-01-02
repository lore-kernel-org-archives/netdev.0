From: Julia Lawall <julia.lawall-L2FTfq7BK8M@public.gmane.org>
Subject: Re: [PATCH] net-libertas: Better exception handling in
 if_spi_host_to_card_worker()
Date: Sat, 2 Jan 2016 09:21:37 +0100 (CET)
Message-ID: <alpine.DEB.2.02.1601020914100.2063@localhost6.localdomain6>
References: <566ABCD9.1060404@users.sourceforge.net> <5686F0B2.5000000@users.sourceforge.net> <56870866.7020000@cogentembedded.com> <568785B3.5000905@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>,
	libertas-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: SF Markus Elfring <elfring-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <568785B3.5000905-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On Sat, 2 Jan 2016, SF Markus Elfring wrote:

> >> Move the jump label directly before the desired log statement
> >> so that the variable "err" will not be checked once more
> >> after it was determined that a function call failed.
> >> Use the identifier "report_failure" instead of the label "err".
> > 
> >    Why?
> 
> I suggest to reconsider the places with which such a jump label
> is connected.
> 
> 
> > The code was smart enough
> 
> Which action should really be performed after a failure was detected
> and handled a bit already?
> 
> * Another condition check
> 
> * Just additional error logging
> 
> 
> > and you're making it uglier that it needs to be.
> 
> I assume that a software development taste can evolve, can't it?

So far, you have gotten several down votes for this kind of change, and no 
enthusiasm.

Admittedly, this is a trivial case, because there are no local variables, 
but do you actually know the semantics in C of a jump into a block?  And 
if you do know, do you think that this semantics is common knowledge?  And 
do you really think that introducing poorly understandable code is really 
worth saving an if test of a single variable on a non-critical path?

Most of the kernel code is not performance critical at the level of a 
single if test.  So the goal should be for the code to be easy to 
understand and robust to change.  The code that is performance critical, 
you should probably not touch, ever.  The people who wrote it knew what 
was important and what was not.

julia
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

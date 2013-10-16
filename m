From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] DomU's network interface will hung when Dom0 running
 32bit
Date: Wed, 16 Oct 2013 14:47:40 +0100
Message-ID: <20131016134740.GG16371@zion.uk.xensource.com>
References: <20131014111958.GE11739@zion.uk.xensource.com>
 <525CAC21.5040202@oracle.com>
 <1381826609.24708.135.camel@kazak.uk.xensource.com>
 <525D0C41.2080407@oracle.com>
 <20131015100624.GB29436@zion.uk.xensource.com>
 <525D2667.6040102@oracle.com>
 <20131015125802.GR11739@zion.uk.xensource.com>
 <525E41CF.7090008@oracle.com>
 <525E5EDF.4030904@oracle.com>
 <525E8FB3.8000606@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: annie li <annie.li@oracle.com>, Wei Liu <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	<netdev@vger.kernel.org>
To: jianhai luan <jianhai.luan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:41850 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934197Ab3JPNrm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Oct 2013 09:47:42 -0400
Content-Disposition: inline
In-Reply-To: <525E8FB3.8000606@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 16, 2013 at 09:08:03PM +0800, jianhai luan wrote:
[...]
> >>>
> >>>    expires   now   next_credit
> >>>    ----time increases this direction--->
> >>>
> >>>* time_after_eq(now, next_credit) -> false
> >>>* time_before(now, expires) -> false
> >>>
> >>>Then it's stuck again. You're merely narrowing the window, not fixing
> >>>the real problem.
> >>
> >>The above environment isn't stack again. The netback will
> >>pending one timer to process the environment.
> >>
> >>The attachment program will prove if !(time_after_eq(now,
> >>next_credit) || time_before(now, vif->credit_timeout.expires)),
> >>now will only be placed in above environment [ expires
> >>next_credit),  and the above environment will be processed by
> >>timer in soon.
> >
> >Or check following to see what the if condition really do,
> >
> >----------expires-------now-------credit----------    is the only
> >case where we need to add a timer.
> >
> >Other cases like following would match the if condition above,
> >then no timer is added.
> >----------expires----------credit------now------
> >-----now-----expires----------credit----------
> >
> >Or we can consider the extreme condition, when the rate control
> >does not exist, "credit_usec" is zero, and "next_credit" is equal
> >to "expires". The above if condition would cover all conditions,
> >and no rate control really happens. If credit_usec is not zero,
> >the "if condition" would cover the range outside of that from
> >expires to next_credit.
> >
> >Even if "now" is wrapped again into the range from "expires" to
> >"next_credit", the "next_credit" that is set in __mod_timer is
> >reasonable value(this can be gotten from credit_usec), and the
> >timer would be hit soon.
> 
> Thanks Annie's express, my option is consistent with Annie.
> 

OK, thanks for the explanation. I think I get the idea.

In any case, could you use !time_in_range / !time_in_range_open instead
of open coded one-liner? Though I presume one-liner open coding would
not hurt.

Wei.

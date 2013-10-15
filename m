From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: DomU's network interface will hung when Dom0 running 32bit
Date: Tue, 15 Oct 2013 13:58:03 +0100
Message-ID: <20131015125802.GR11739@zion.uk.xensource.com>
References: <52590DFE.6080203@oracle.com>
 <20131014111958.GE11739@zion.uk.xensource.com>
 <525CAC21.5040202@oracle.com>
 <1381826609.24708.135.camel@kazak.uk.xensource.com>
 <525D0C41.2080407@oracle.com>
 <20131015100624.GB29436@zion.uk.xensource.com>
 <525D2667.6040102@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	ANNIE LI <annie.li@oracle.com>
To: jianhai luan <jianhai.luan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:65523 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757696Ab3JOM6F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Oct 2013 08:58:05 -0400
Content-Disposition: inline
In-Reply-To: <525D2667.6040102@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 15, 2013 at 07:26:31PM +0800, jianhai luan wrote:
[...]
> >>>Can you propose a patch?
> >>Because credit_timeout.expire always after jiffies, i judge the
> >>value over the range of time_after_eq() by time_before(now,
> >>vif->credit_timeout.expires). please check the patch.
> >I don't think this really fix the issue for you. You still have chance
> >that now wraps around and falls between expires and next_credit. In that
> >case it's stalled again.
> 
> if time_before(now, vif->credit_timeout.expires) is true, time wrap
> and do operation. Otherwise time_before(now,
> vif->credit_timeout.expires) isn't true, now -
> vif->credit_timeout.expires should be letter than ULONG_MAX/2.
> Because next_credit large than vif->credit_timeout.expires
> (next_crdit = vif->credit_timeout.expires +
> msecs_to_jiffies(vif->credit_usec/1000)), the delta between now and
> next_credit should be in range of time_after_eq().  So
> time_after_eq() do correctly judge.
> 

Not sure I understand you. Consider "now" is placed like this:

   expires   now   next_credit
   ----time increases this direction--->

* time_after_eq(now, next_credit) -> false
* time_before(now, expires) -> false

Then it's stuck again. You're merely narrowing the window, not fixing
the real problem.

Wei.

> Jason
> >
> >Wei.

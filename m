From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: [RFT] pcnet32 NAPI changes
Date: Tue, 20 Jun 2006 08:53:55 -0500
Message-ID: <20060620135355.GB7922@us.ibm.com>
References: <20060616191154.GA6227@us.ibm.com> <20060619204140.GC10036@us.ibm.com> <20060619204933.GH26952@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Don Fry <brazilnut@us.ibm.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:26273 "EHLO e4.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1750862AbWFTNth (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2006 09:49:37 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k5KDnaO5028753
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 20 Jun 2006 09:49:36 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5KDnawm256136
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 20 Jun 2006 09:49:36 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5KDnZrB002311
	for <netdev@vger.kernel.org>; Tue, 20 Jun 2006 09:49:36 -0400
To: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Content-Disposition: inline
In-Reply-To: <20060619204933.GH26952@csclub.uwaterloo.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 19, 2006 at 04:49:33PM -0400, Lennart Sorensen wrote:
> On Mon, Jun 19, 2006 at 03:41:40PM -0500, Jon Mason wrote:
> > I believe it is preferred to be a compile option for non-gigabit
> > drivers, given that it will be eating a lot of cycles for infrequent
> > packets (especially for the 10Mb).  I believe there was a thread about
> > this last year when e100 was having NAPI problems.
> 
> How does NAPI eat cycles?  It goes back to interrupt mode when the queue
> is empty, and only on RX interrupt does it turn on polling again.

The amount of polls per received packet is very low, thus removing the
benefit of NAPI.  A compile time option would allow those users who know
better to DTRT.

> It is certainly possible that there are bugs in a NAPI conversion, which
> I guess could be a reason to have the option to stick with the old
> method, although then again not having the option ensures the bugs get
> found sooner.
> 
> > A general nit.  There are ALOT of magic numbers in the code, most
> > existing prior to this patch.  The driver would benefit from a little
> > clean-up.
> > 
> > Also nothing to do with this patch, but I noticed it when the code was
> > moved.  A comment about why the following is necessary might be nice:
> > lp->rx_ring[i].buf_length = le16_to_cpu(2 - PKT_BUF_SZ);
> 
> I suspect many drivers are in need of some cleanup.

Yup, but the "everyone else is doing it" argument never worked with my
parents. All it takes is one brave soul to determine the reasoning
behind the magic numbers and convert them into #define's.  Shouldn't be
more than one day's work.

> 
> Len Sorensen
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

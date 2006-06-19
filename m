From: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Subject: Re: [RFT] pcnet32 NAPI changes
Date: Mon, 19 Jun 2006 16:49:33 -0400
Message-ID: <20060619204933.GH26952@csclub.uwaterloo.ca>
References: <20060616191154.GA6227@us.ibm.com> <20060619204140.GC10036@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.uwaterloo.ca ([129.97.134.17]:7845 "EHLO
	caffeine.csclub.uwaterloo.ca") by vger.kernel.org with ESMTP
	id S932293AbWFSUte (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jun 2006 16:49:34 -0400
To: Don Fry <brazilnut@us.ibm.com>, netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060619204140.GC10036@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 19, 2006 at 03:41:40PM -0500, Jon Mason wrote:
> I believe it is preferred to be a compile option for non-gigabit
> drivers, given that it will be eating a lot of cycles for infrequent
> packets (especially for the 10Mb).  I believe there was a thread about
> this last year when e100 was having NAPI problems.

How does NAPI eat cycles?  It goes back to interrupt mode when the queue
is empty, and only on RX interrupt does it turn on polling again.

It is certainly possible that there are bugs in a NAPI conversion, which
I guess could be a reason to have the option to stick with the old
method, although then again not having the option ensures the bugs get
found sooner.

> A general nit.  There are ALOT of magic numbers in the code, most
> existing prior to this patch.  The driver would benefit from a little
> clean-up.
> 
> Also nothing to do with this patch, but I noticed it when the code was
> moved.  A comment about why the following is necessary might be nice:
> lp->rx_ring[i].buf_length = le16_to_cpu(2 - PKT_BUF_SZ);

I suspect many drivers are in need of some cleanup.

Len Sorensen

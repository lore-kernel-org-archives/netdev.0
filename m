From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [Bug #42707] Hang deconfiguring network interface (in
 shutdown) on 3.3-rc1
Date: Mon, 27 Feb 2012 17:24:08 -0800
Message-ID: <20120228012408.GA29622@mcarlson.broadcom.com>
References: <y44pDJ8xoDC.A.08E.h8rRPB@chimera>
 <qCQH7HfZS8E.A.x6F.98rRPB@chimera>
 <1330386274.2822.105.camel@dabdike.int.hansenpartnership.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	"Kernel Testers List" <kernel-testers@vger.kernel.org>,
	"Maciej Rutecki" <maciej.rutecki@gmail.com>,
	"Florian Mickler" <florian@mickler.org>,
	"Matt Carlson" <mcarlson@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>,
	"Ben Hutchings" <bhutchings@solarflare.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: "James Bottomley" <James.Bottomley@HansenPartnership.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3091 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965212Ab2B1BZH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Feb 2012 20:25:07 -0500
In-Reply-To: <1330386274.2822.105.camel@dabdike.int.hansenpartnership.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 27, 2012 at 05:44:34PM -0600, James Bottomley wrote:
> On Thu, 2012-02-23 at 23:55 +0100, Rafael J. Wysocki wrote:
> > This message has been generated automatically as a part of a summary report
> > of recent regressions.
> > 
> > The following bug entry is on the current list of known regressions
> > from 3.2.  Please verify if it still should be listed and let the tracking team
> > know (either way).
> > 
> > 
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=42707
> > Subject		: Hang deconfiguring network interface (in shutdown) on 3.3-rc1
> > Submitter	: James Bottomley <James.Bottomley@hansenpartnership.com>
> > Date		: 2012-01-28 19:56 (27 days old)
> > Message-ID	: <1327780565.2924.24.camel@dabdike.int.hansenpartnership.com>
> > References	: http://marc.info/?l=linux-kernel&m=132778076214873&w=2
> 
> Still present in 3.3-rc4; I've bisected it back to this commit:
> 
> commit 92feeabf3f673767c6ee4cfc7fc224098446c1c1
> Author: Matt Carlson <mcarlson@broadcom.com>
> Date:   Thu Dec 8 14:40:14 2011 +0000
> 
>     tg3: Save stats across chip resets
> 
> and sure enough, just reverting this single commit on 3.3-rc4 fixes the
> problem.
> 
> James

I don't see anything incorrect about the patch.  I'm guessing the patch
just changes the timing somehow.

tg3_reset_chip() does not take any driver-internal spinlocks.  That
happens at tg3_close().  I'm guessing the spinlock in the trace is coming
from synchronize_irq().

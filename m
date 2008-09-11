From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 1/1] tg3: Avoid Send BD corruption
Date: Thu, 11 Sep 2008 15:55:58 -0700
Message-ID: <1221173758.12785.32.camel@HP1>
References: <20080911051244.GA27384@xw6200.broadcom.net>
 <20080910.224618.113269063.davem@davemloft.net>
 <20080911165913.GA27725@xw6200.broadcom.net>
 <20080911.145154.112457696.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"andy@greyhouse.net" <andy@greyhouse.net>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3717 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752819AbYIKW5Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Sep 2008 18:57:24 -0400
In-Reply-To: <20080911.145154.112457696.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 2008-09-11 at 14:51 -0700, David Miller wrote:
> From: "Matt Carlson" <mcarlson@broadcom.com>
> Date: Thu, 11 Sep 2008 09:59:13 -0700
> 
> > On Wed, Sep 10, 2008 at 10:46:18PM -0700, David Miller wrote:
> > > Are users really hitting this or was this discovered by your own
> > > internal testing and verification?
> >
> > The bug was discovered by our own internal testing, but this bug is
> > severe enough to warrant submission to the net-2.6 kernel.  I'll be
> > sending a patch to stable as well.
> >
> > These chips are relatively new so there isn't a whole lot of opportunity
> > for users to experience the problem yet.  As the chips are distributed,
> > the likelyhood that users will encounter this problem is pretty high.
> 
> That doesn't matter.  That isn't the criteria for inclusion outside of
> the merge window, or into -stable.

Send BD corruption is quite serious as it can cause tg3_tx() to crash.
We've seen a number of similar crashes over the years caused by
re-ordered IOs and the nr_frags getting modified by HTB.

Since regression/security/oops fixes are allowed, shouldn't this qualify
since it prevents a crash in tg3_tx()?

> 
> You should read postings such as the following one and the other ones
> in it's thread so that you can become familiar with the criteria:
> 
>         http://marc.info/?l=linux-netdev&m=122048757705315&w=2
> 
> And by those descriptions, this patch is not appropriate and I'm
> therefore not going to try and submit it for 2.6.27 and risk getting
> my head chopped off by Linus again in public.
> 
> 
> 
> 
> 



From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 1/1] tg3: Avoid Send BD corruption
Date: Thu, 11 Sep 2008 16:19:28 -0700
Message-ID: <1221175168.12785.40.camel@HP1>
References: <20080911165913.GA27725@xw6200.broadcom.net>
 <20080911.145154.112457696.davem@davemloft.net>
 <1221173758.12785.32.camel@HP1>
 <20080911.160117.118147467.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"andy@greyhouse.net" <andy@greyhouse.net>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1613 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754502AbYIKXUu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Sep 2008 19:20:50 -0400
In-Reply-To: <20080911.160117.118147467.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 2008-09-11 at 16:01 -0700, David Miller wrote:
> From: "Michael Chan" <mchan@broadcom.com>
> Date: Thu, 11 Sep 2008 15:55:58 -0700
> 
> > Send BD corruption is quite serious as it can cause tg3_tx() to crash.
> > We've seen a number of similar crashes over the years caused by
> > re-ordered IOs and the nr_frags getting modified by HTB.
> >
> > Since regression/security/oops fixes are allowed, shouldn't this qualify
> > since it prevents a crash in tg3_tx()?
> 
> It's at best borderline, since tg3_tx() has reordering detection logic
> which will reset and recover the card.

The re-ordering detection logic will allow corruption to happen once
only.  It will then enable flushing of IOs and if it detects corruption
again, it will hit BUG().  That's why it wasn't able to prevent the
crash caused by HTB.

> 
> Until I see a real user trigger this I'm still leaning towards no.
> 
> Otherwise any driver maintainer can give me this spiel to get their
> changes installed outside of the merge window, and that subverts the
> entire purpose of the rules.
> 

OK, we'll resubmit this for net-next then.  But I still think this one
should qualify.  We do internal testing to find as many problems as
possible so that real users don't see too many of them.



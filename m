From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH 1/2] net: dsa: mv88e6xxx: sleep in _mv88e6xxx_stats_wait
Date: Fri, 10 Jul 2015 11:36:23 -0700
Message-ID: <20150710183623.GB19854@roeck-us.net>
References: <1436547449-26927-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <20150710171027.GB6585@groeck-UX31A>
 <1055594065.210272.1436552447158.JavaMail.zimbra@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, David <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	kernel <kernel@savoirfairelinux.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:59905 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933068AbbGJSg0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 14:36:26 -0400
Content-Disposition: inline
In-Reply-To: <1055594065.210272.1436552447158.JavaMail.zimbra@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vivien,

On Fri, Jul 10, 2015 at 02:20:47PM -0400, Vivien Didelot wrote:
> > 
> > is this really beneficial and/or needed ?
> 
> Except using existing generic code, no.
> 
> > It adds at least 1ms delay to a loop which did not have any delay at
> > all unless the register read itself was sleeping.
> 
> I must have missed where is the benefit from spin reading 10 times this
> register, rather than sleeping 1ms between tests. Does this busy bit
> behaves differently from the phy, atu, scratch, or vtu busy bits?
> 
Benefit is reaction time, mostly. If the result isn't ready after the
first spin, the new code path adds a mandatory 1-2ms delay. This could
add up to a lot if that kind of retry is seen a lot.

I don't now if there is a specific time limit for this busy bit,
and/or if it behaves differently than the others in terms of timing.

> > Is the original function seen to return a timeout error under some
> > circumstances ?
> 
> I didn't experience it myself, but I guess it may happen. In addition to
> that, the current implementation doesn't check eventual read error.
> That's why I saw a benefit in using _mv88e6xxx_wait().

Checking for a read error (or a timeout) is definitely a good thing.
I could also imagine that, for example, a "clear statistics" request
takes more time than currently supported. This is why I asked if you
had seen a timeout with the old code.

Personally I'd rather leave the wait loop alone and only introduce
error checking unless there is a reason to introduce a sleep,
but I'd like to hear Andrew's and/or Florian's opinion.

Thanks,
Guenter

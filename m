From: Guenter <linux@roeck-us.net>
Subject: Re: [PATCH 1/2] net: dsa: mv88e6xxx: sleep in _mv88e6xxx_stats_wait
Date: Fri, 10 Jul 2015 13:05:15 -0700
Message-ID: <20150710200514.GA9469@groeck-UX31A>
References: <1436547449-26927-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <20150710171027.GB6585@groeck-UX31A>
 <1055594065.210272.1436552447158.JavaMail.zimbra@savoirfairelinux.com>
 <20150710183623.GB19854@roeck-us.net>
 <645518234.216003.1436556107630.JavaMail.zimbra@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	David <davem@davemloft.net>, Andrew Lunn <andrew@lunn.ch>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	kernel <kernel@savoirfairelinux.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33541 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932641AbbGJUFT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 16:05:19 -0400
Content-Disposition: inline
In-Reply-To: <645518234.216003.1436556107630.JavaMail.zimbra@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vivien,

On Fri, Jul 10, 2015 at 03:21:47PM -0400, Vivien Didelot wrote:
> Hi Guenter,
> >> I must have missed where is the benefit from spin reading 10 times this
> >> register, rather than sleeping 1ms between tests. Does this busy bit
> >> behaves differently from the phy, atu, scratch, or vtu busy bits?
> >> 
> > Benefit is reaction time, mostly. If the result isn't ready after the
> > first spin, the new code path adds a mandatory 1-2ms delay. This could
> > add up to a lot if that kind of retry is seen a lot.
> 
> To me, it looks like if this mandatory 1-2ms delay is an issue, then
> _mv88e6xxx_wait must be fixed. Maybe reducing this delay is an option?
> 
Good point. The timeout is most definitely quite large and for sure on
the safe side. It might make sense to add some statistics gathering to
see how long the maximum observed delay actually is.

Guenter

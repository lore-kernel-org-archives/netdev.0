From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 2.6.22] TCP: Make TCP_RTO_MAX a variable (take 2)
Date: Fri, 13 Jul 2007 07:29:45 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0707130726550.30150@kivilampi-30.cs.helsinki.fi>
References: <20070712.161510.26510093.noboru.obata.ar@hitachi.com>
 <20070712.023710.36923635.davem@davemloft.net> <20070712.225950.12335719.noboru.obata.ar@hitachi.com>
 <20070712.132448.115910193.davem@davemloft.net>
 <20070712141203.7350429a@freepuppy.rosehill.hemminger.net> <46969CA9.8030406@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	noboru.obata.ar@hitachi.com, David Miller <davem@davemloft.net>,
	yoshfuji@linux-ipv6.org, Netdev <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:43790 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750825AbXGME3r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jul 2007 00:29:47 -0400
In-Reply-To: <46969CA9.8030406@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 12 Jul 2007, Rick Jones wrote:

> > One question is why the RTO gets so large that it limits failover?
> > 
> > If Linux TCP is working correctly,  RTO should be srtt + 2*rttvar
> > 
> > So either there is a huge srtt or variance, or something is going
> > wrong with RTT estimation.  Given some reasonable maximums of
> > Srtt = 500ms and rttvar = 250ms, that would cause RTO to be 1second.
> 
> I suspect that what is happening here is that a link goes down in a trunk
> somewhere for some number of seconds, resulting in a given TCP segment being
> retransmitted several times, with the doubling of the RTO each time.

But that's a back-off for the retransmissions, the doubling is 
temporary... Once you return to normal conditions, the accumulated backoff 
multiplier will be immediately cut back to normal. So you should then be 
back to 1 second (like in the example or whatever) again...

-- 
 i.

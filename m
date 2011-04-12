From: Jan =?ISO-8859-1?Q?L=FCbbe?= <jluebbe@debian.org>
Subject: Re: Kernel panic when using bridge
Date: Tue, 12 Apr 2011 17:13:53 +0200
Message-ID: <1302621233.30934.44.camel@polaris.local>
References: <4D9E62D9.5010400@scotdoyle.com>
	 <20110408121700.0aad53fe@nehalam>	<4D9FE5BE.6060600@scotdoyle.com>
	 <20110409161908.a2aca120.shimoda.hiroaki@gmail.com>
	 <4DA39330.2030102@scotdoyle.com> <20110411183105.46e86684@nehalam>
	 <4DA3CB4B.9090506@scotdoyle.com> <1302581384.3603.14.camel@edumazet-laptop>
	 <1302582172.3603.18.camel@edumazet-laptop> <4DA3E074.5090603@scotdoyle.com>
	 <1302587490.3603.22.camel@edumazet-laptop> <4DA3F909.5020609@scotdoyle.com>
	 <1302608951.3233.33.camel@edumazet-laptop>
	 <1302613353.30934.22.camel@polaris.local>
	 <1302614145.3233.47.camel@edumazet-laptop>
	 <1302617968.30934.34.camel@polaris.local>
	 <1302619749.3233.56.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Scot Doyle <lkml@scotdoyle.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sirius.lasnet.de ([78.47.116.19]:60969 "EHLO sirius.lasnet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755701Ab1DLPOA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Apr 2011 11:14:00 -0400
In-Reply-To: <1302619749.3233.56.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-04-12 at 16:49 +0200, Eric Dumazet wrote: 
> Of course, this might be a complete shot in the dark, but a
> stackprotector fault in icmp_send() really sounds like a problem in
> ip_options_echo() [ or bad input data given to this function ]

It was my understanding that all IP options given to ip_options_echo are
either from local sources or have gone through ip_options_compile, which
seems to verify that the sum of the individual option lengths do not
exceed the ip header. So there wouldn't need to be additional checks in
ip_options_echo.

If this is not the case, we need size checks in ip_options_echo before
copying over each option.

> Other related changes (but as old as v2.6.22) :
> 
> commit 11a03f78fbf15a866ba
> ([NetLabel]: core network changes)

When investigating the problem I had with timestamps, i found that most
of the lines in ip_options_echo and _compile have not been changed since
before 2.2 (some even before 2.0). The newer changes have all been
updates for changed API elsewhere in the stack.

Regards,
Jan


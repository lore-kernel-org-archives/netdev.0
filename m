From: TJ <linux@tjworld.net>
Subject: Re: Problem with implementation of TCP_DEFER_ACCEPT?
Date: Fri, 24 Aug 2007 10:31:27 +0100
Message-ID: <1187947887.6976.18.camel@bagoas.tjworld.net>
References: <1187914105.26866.41.camel@bagoas.tjworld.net>
	 <20070824071530.GB26447@xi.wantstofly.org>
	 <20070824084048.GA8346@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [66.6.122.20] ([66.6.122.20]:44764 "EHLO tjworld.net"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1761936AbXHXJbb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Aug 2007 05:31:31 -0400
In-Reply-To: <20070824084048.GA8346@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-08-24 at 12:40 +0400, Alexey Kuznetsov wrote:

> There is no protocol violation here, ACK from client is considered as lost,
> it is quite normal and happens all the time. Handshake is not complete,
> server remains in SYN-RECV state and continues to retransmit SYN-ACK.
> If client tried to cheat and is not going to send its request,
> connection will time out.

Thanks for the responses.

Do we have any authoritative references on this? Who implemented it
originally?

Right now Juniper are claiming the issue that brought this to the
surface (the bug linked to in my original post) is a problem with the
implementation of TCP_DEFER_ACCEPT.

My position so far is that the Juniper DX OS is not following the HTTP
standard because it doesn't send a request with the connection, and as I
read the end of section 1.4 of RFC2616, an HTTP connection should be
accompanied by a request.

Can anyone confirm my interpretation or provide references to firm it
up, or refute it?

There is also a very real practical problem here:

Since version 2.1.5 apache enables TCP_DEFER_ACCEPT *by default* without
mention of it in the configuration file.

As time goes on the number of apache v2.1.5+ deployments is only going
to rise, and I'd hate for anyone else to go through the 5+ weeks of pain
the system admins at the e-commerce operation I was helping went
through, not to mention the last 2 weeks feeling like I was chasing
ghosts - it's an absolute pain to track down and identify!

Therefore, anyone deploying apache web servers in a web-farm behind the
Juniper DX load-balanders and using TCP multiplexing (for which they pay
a hefty licence fee!) is liable to suffer the random drop effects
described in my bug report.

Because several other HTTP load-balancers deploy similar methods of
holding open connections to the servers and pipe-lining requests, this
could affect more than just Juniper.

Any other suggestions/reactions on the Linux kernel side? I'm intending
posting a comment to the apache-dev mailing list once I've gathered the
strands together.

Thanks again.

TJ.
Ubuntu ACPI Kernel Team.


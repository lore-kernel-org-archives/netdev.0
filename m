From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP: Support configurable delayed-ack parameters
Date: Fri, 28 Feb 2014 07:49:33 -0800
Message-ID: <1393602573.26794.65.camel@edumazet-glaptop2.roam.corp.google.com>
References: <00e801cf3497$c37255f0$4a5701d0$@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Harout Hedeshian <harouth@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:41652 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752379AbaB1Pte (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Feb 2014 10:49:34 -0500
Received: by mail-pd0-f174.google.com with SMTP id y13so881493pdi.5
        for <netdev@vger.kernel.org>; Fri, 28 Feb 2014 07:49:34 -0800 (PST)
In-Reply-To: <00e801cf3497$c37255f0$4a5701d0$@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-02-28 at 08:14 -0700, Harout Hedeshian wrote:
> Hello David,
> 
> I found a thread from June 2012 (subject matches this email) discussing the
> addition of parameters to manually tune the delayed TCP ACK parameters, and
> add new TCP socket options for application specific tuning. The patch in
> question would multiply the receive mss by some constant exposed in /proc.
> We have experimented with a similar approach and found significant
> improvements in performance when asymmetric links are utilized; specifically
> where the hardware is limited in egress packets/sec (but not raw bandwidth).
> As an example, in one test we saw a 100% improvement when doing rcv_mss*4.

Note that we have some bugs in TCP stack, that might explain the
behavior. Please post pcap so that we can really understand your point,
and eventually pinpoint bugs.

For example TSO should_defer() is known to be problematic, and we have a
patch fixing the issue. I'll post it today.

Other bugs included a problem in TCP Small Queue, that was recently
fixed.

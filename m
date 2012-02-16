From: Neal Cardwell <ncardwell@google.com>
Subject: Re: limited network bandwidth with 3.2.x kernels
Date: Thu, 16 Feb 2012 12:22:29 -0500
Message-ID: <CADVnQykm==YJZbdCbLxgJ236jD2yN0xT99gmeYX-FGnyBvfEGA@mail.gmail.com>
References: <1329399616.9395.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1329400265.3048.178.camel@deadeye>
	<1329404975.10004.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20120216.120149.437368615973561397.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: eric.dumazet@gmail.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org, alekcejk@googlemail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:51832 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753837Ab2BPRWa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2012 12:22:30 -0500
Received: by qadc10 with SMTP id c10so4642146qad.19
        for <netdev@vger.kernel.org>; Thu, 16 Feb 2012 09:22:29 -0800 (PST)
In-Reply-To: <20120216.120149.437368615973561397.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Our team has also run into issues with GRO/LRO "stretch ACKs", and
their negative impact on TCP performance. We have a patch that we've
been working with that deals with the sender-side issues. It turns out
that neither the ABC nor non-ABC byte counting quite fixes the stretch
ACKs issues.

On the receiver side, the approach of changing tcp_grow_window() and
__tcp_grow_window() to adjust things in terms of actual packet size
rather than a fixed 2*MSS sounds great to me as well.

In terms of the original 3.1 vs 3.2 issue report that started this
thread, I didn't see any evidence of LRO or GRO causing stretch ACKs.
(Alexey, would you be able to confim by running "ethtool -k eth0" on
both kernels?) So it seems that probably the original issue is
unrelated to stretch ACKs?

neal

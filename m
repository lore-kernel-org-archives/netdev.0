From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: tcp bw in 2.6
Date: Mon, 1 Oct 2007 19:14:37 -0700 (PDT)
Message-ID: <alpine.LFD.0.999.0710011858400.3579@woody.linux-foundation.org>
References: <20070929142517.EC6AB5FB21@work.bitmover.com>
 <alpine.LFD.0.999.0709290914410.3579@woody.linux-foundation.org>
 <20070929172639.GB7037@bitmover.com> <alpine.LFD.0.999.0709291050200.3579@woody.linux-foundation.org>
 <20071002005917.GB5480@bitmover.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: davem@davemloft.net, wscott@bitmover.com, netdev@vger.kernel.org
To: Larry McVoy <lm@bitmover.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:48085 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751082AbXJBCOl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 22:14:41 -0400
In-Reply-To: <20071002005917.GB5480@bitmover.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Mon, 1 Oct 2007, Larry McVoy wrote:
> 
> but the client looks like
> 
> connect(3, {sa_family=AF_INET, sin_port=htons(31235), sin_addr=inet_addr("10.3.9.1")}, 16) = 0
> read(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 1048576) = 2896
> read(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 1048576) = 1448
> read(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 1048576) = 2896
..

This is exactly what I'd expect if the machine is *not* under excessive 
load.

The system calls are fast enough that the latency for the TCP stack is 
roughly on the same scale as the time it takes to receive one new packet, 
so since a socket read will always return when it has any data (not until 
it has filled the whole buffer), you get exactly that "one or two packets" 
pattern.

If you'd be really CPU-limited or under load from other programs, you'd 
have more packets come in while you're in the read path, and you'd get 
bigger reads.

But do a tcpdump both ways, and see (for example) if the TCP window is 
much bigger going the other way.

		Linus

From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] add a sysctl to disable TCP simultaneous connection opening
Date: Thu, 09 Oct 2008 05:49:30 +0200
Message-ID: <87abdetol1.fsf@basil.nowhere.org>
References: <20081008081109.GA25342@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:49325 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751725AbYJIDtf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 23:49:35 -0400
In-Reply-To: <20081008081109.GA25342@1wt.eu> (Willy Tarreau's message of "Wed, 8 Oct 2008 10:11:09 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Willy Tarreau <w@1wt.eu> writes:
> As a reminder (especially for those who are not aware of this feature),
> it is possible with TCP to connect two clients together if both send
> crossed SYNs, then SYN-ACKs, then ACKs. This implies that each side
> accepts the sequence number of the other one without any ability to
> check that it matches its SYN. So it's trivial for an attacker to
> prevent one client from establishing a connection from a known port
> to a known address/port by sending it a SYN to that port. The client
> will then send a SYN-ACK and will not accept the expected server's
> SYN-ACK because the SYN SEQ will be different. The server might also
> send an RST on the client's SYN-ACK if it's not firewalled. The
> connection will eventually timeout in a SYN-RECV state or simply be
> aborted.

One reasonable tweak for this would be to use a very aggressive
timeout for simultaneously opened connections that didn't get an ACK
yet.

But to be honest it doesn't seem like a very pressing problem to me either.

-Andi

-- 
ak@linux.intel.com

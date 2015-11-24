From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next 0/6] kcm: Kernel Connection Multiplexor (KCM)
Date: Tue, 24 Nov 2015 21:55:37 +0100
Message-ID: <20151124205537.GC23215@breakpoint.cc>
References: <CALx6S34TrGgmH3eZKPLw_xKYfX2dm+fZq6r7ZBe2DBPudBiSzA@mail.gmail.com>
 <20151123.145433.1554000376541433305.davem@davemloft.net>
 <20151124152744.GB20972@breakpoint.cc>
 <20151124.105537.185897620062606312.davem@davemloft.net>
 <20151124162515.GA22266@breakpoint.cc>
 <CALx6S35uHQS1n7GYATZ-3UwLFhdiShdVzTBzEgdkKsQrmdpXZw@mail.gmail.com>
 <20151124171650.GA23215@breakpoint.cc>
 <CALx6S36qHkUhz5VN+xvsMhszTQnCUUhQ+Doja86wLGWJEe_u_A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>, davejwatson@fb.com,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:59942 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753666AbbKXUzm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 15:55:42 -0500
Content-Disposition: inline
In-Reply-To: <CALx6S36qHkUhz5VN+xvsMhszTQnCUUhQ+Doja86wLGWJEe_u_A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert <tom@herbertland.com> wrote:
> Message size limits can be enforced in BPF or we could add a limit
> enforced by KCM. For instance, the message size limit in http/2 is
> 16M. If it's needed, it wouldn't be much trouble to add a streaming
> interface for large messages.

That still won't change the fact that KCM allows eating large
amount of kernel memory (you could just open a lot of sockets...).

For tcp we cannot exceed the total rmem limits, even if I can open
4k sockets.

Why anyone would invest such a huge amount of work in making this
kernel-based framing for single-stream tcp record (de)mux rather than
improving the userspace protocol to use UDP or SCTP or at least
one tcp connection per worker is beyond me.

For TX side, why is writev not good enough?
Is KCM tx just so that userspace doesn't need to handle partial writes?

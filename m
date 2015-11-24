From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next 0/6] kcm: Kernel Connection Multiplexor (KCM)
Date: Tue, 24 Nov 2015 17:25:15 +0100
Message-ID: <20151124162515.GA22266@breakpoint.cc>
References: <CALx6S34TrGgmH3eZKPLw_xKYfX2dm+fZq6r7ZBe2DBPudBiSzA@mail.gmail.com>
 <20151123.145433.1554000376541433305.davem@davemloft.net>
 <20151124152744.GB20972@breakpoint.cc>
 <20151124.105537.185897620062606312.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fw@strlen.de, tom@herbertland.com, hannes@stressinduktion.org,
	netdev@vger.kernel.org, kernel-team@fb.com, davejwatson@fb.com,
	alexei.starovoitov@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:59438 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754002AbbKXQZV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 11:25:21 -0500
Content-Disposition: inline
In-Reply-To: <20151124.105537.185897620062606312.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> From: Florian Westphal <fw@strlen.de>
> Date: Tue, 24 Nov 2015 16:27:44 +0100
> 
> > Aside from Hannes comment -- KCM seems to be tied to the TLS work, i.e.
> > I have the impression that KCM without ability to do TLS in the kernel
> > is pretty much useless for whatever use case Tom has in mind.
> 
> I do not get this impression at all.
> 
> Tom's design document in the final patch looks legitimately what the
> core use case is.

You mean
https://patchwork.ozlabs.org/patch/547054/ ?

Its a well-written document, but I don't see how moving the burden of
locking a single logical tcp connection (to prevent threads from
reading a partial record) from userspace to kernel is an improvement.

If you really have 100 threads and must use a single tcp connection
to multiplex some arbitrarily complex record-format in atomic fashion,
then your requirements suck.

Now, arguably, maybe the requirements of Toms use case are restricted
/cannot be avoided.

But that still begs the question: Why should mainline care?

Once its in, next step will be 'my single tcp connection that I use
for multiplexing via KCM now has requirement to use TLS'.

How far are you willing to take the KCM concept?

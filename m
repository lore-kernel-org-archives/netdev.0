From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next 0/6] kcm: Kernel Connection Multiplexor (KCM)
Date: Tue, 24 Nov 2015 18:16:50 +0100
Message-ID: <20151124171650.GA23215@breakpoint.cc>
References: <CALx6S34TrGgmH3eZKPLw_xKYfX2dm+fZq6r7ZBe2DBPudBiSzA@mail.gmail.com>
 <20151123.145433.1554000376541433305.davem@davemloft.net>
 <20151124152744.GB20972@breakpoint.cc>
 <20151124.105537.185897620062606312.davem@davemloft.net>
 <20151124162515.GA22266@breakpoint.cc>
 <CALx6S35uHQS1n7GYATZ-3UwLFhdiShdVzTBzEgdkKsQrmdpXZw@mail.gmail.com>
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
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:59570 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752238AbbKXRQ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 12:16:57 -0500
Content-Disposition: inline
In-Reply-To: <CALx6S35uHQS1n7GYATZ-3UwLFhdiShdVzTBzEgdkKsQrmdpXZw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert <tom@herbertland.com> wrote:
> No one is being forced to use any of this.

Right.  But it will need to be maintained.
Lets ignore ktls for the time being and focus on KCM.

I'm currently trying to figure out how memory handling in KCM
is supposed to work.

say we have following record framing:

struct record {
	u32 len;
	char data[];
};

And I have a epbf filter that returns record->len within KCM.
Now this program says 'length 128mbyte' (or whatever).

If this was userspace, things are simple, userspace can either
decide to hang up or start to read this in chunks as data arrives.

AFAICS, with KCM, the kernel now has to keep 128mb of allocated
memory around, rmem limits are ignored.

Is that correct?  What if next record claims 4g in size?
I don't really see how we can make any guarantees wrt.
kernel stability...

Am I missing something?

Thanks,
Florian

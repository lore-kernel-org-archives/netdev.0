From: Willy Tarreau <w@1wt.eu>
Subject: Re: Major network performance regression in 3.7
Date: Sun, 6 Jan 2013 00:29:13 +0100
Message-ID: <20130105232913.GQ16031@1wt.eu>
References: <20130105214958.GA19814@1wt.eu> <1357427926.1678.4771.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:37505 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755898Ab3AEX3S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Jan 2013 18:29:18 -0500
Content-Disposition: inline
In-Reply-To: <1357427926.1678.4771.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Sat, Jan 05, 2013 at 03:18:46PM -0800, Eric Dumazet wrote:
> Hi Willy, another good finding during the week end ! ;)

Yes, I wanted to experiment with TFO and stopped on this :-)

> 1) This looks like interrupts are spreaded on multiple cpus, and this
> give Out Of Order problems with TCP stack.

No, I forgot to mention this, I have tried to bind IRQs to a single
core, with the server either on the same or another one, but the
problem remained.

Also, the loopback is much more affected and doesn't use IRQs. And
BTW tcpdump on the loopback shouldn't drop that many packets (up to
90% even at low rate). I just noticed something, transferring data
using netcat on the loopback doesn't affect tcpdump. So it's likely
only the spliced data that are affected.

> 2) Another possibility would be that Myri card/driver doesnt like very
> well high order pages.

It looks like it has not changed much since 3.6 :-/ I really suspect
something is wrong with memory allocation. I have tried reverting many
patches affecting the mm/ directory just in case but I did not come to
anything useful yet.

I'm continuing to dig.

Thanks,
Willy

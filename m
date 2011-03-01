From: Albert Cahalan <acahalan@gmail.com>
Subject: Re: txqueuelen has wrong units; should be time
Date: Tue, 1 Mar 2011 01:54:09 -0500
Message-ID: <AANLkTi=eDQh9Kvr9N_dTC5Cnbcfb+DbO-6tLxkZiEp9v@mail.gmail.com>
References: <20110228165501.GC2515@tuxdriver.com>
	<AANLkTinj5szpStmA+fZ1xggdyTS+sd8Y9jXaYquDNEjs@mail.gmail.com>
	<AANLkTinFZu5AgfhO6PoA7C1NTGSfD8HH0KXq_o-mHEJF@mail.gmail.com>
	<20110228.201852.193726064.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: johnwheffner@gmail.com, linville@tuxdriver.com,
	eric.dumazet@gmail.com, jussi.kivilinna@mbnet.fi, swmike@swm.pp.se,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110228.201852.193726064.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 28, 2011 at 11:18 PM, David Miller <davem@davemloft.net> wrote:
> From: Albert Cahalan <acahalan@gmail.com>
> Date: Mon, 28 Feb 2011 23:11:13 -0500
>
>> It sounds like you need a callback or similar, so that TCP can be
>> informed later that the drop has occurred.
>
> By that point we could have already sent an entire RTT's worth
> of data, or more.
>
> It needs to be synchronous, otherwise performance suffers.

Ouch. OTOH, the current situation: performance suffers.

In case it makes you feel any better, consider two cases
where synchronous feedback is already impossible.
One is when you're routing packets that merely pass through.
The other is when some other box is doing that to you.
Either way, packets go bye-bye and nobody tells TCP.

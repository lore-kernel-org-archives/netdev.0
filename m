From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Comparison of several congestion control algorithms
Date: Thu, 02 Jun 2005 16:35:12 -0700 (PDT)
Message-ID: <20050602.163512.10298458.davem@davemloft.net>
References: <4298E045.9050009@ev-en.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, shemminger@osdl.org, doug.leith@nuim.ie
Return-path: <netdev-bounce@oss.sgi.com>
To: baruch@ev-en.org
In-Reply-To: <4298E045.9050009@ev-en.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Baruch Even <baruch@ev-en.org>
Date: Sat, 28 May 2005 22:19:01 +0100

> I wanted to point you to a comparison of congestion control algorithm
> done at the Hamilton Institute. These experiments compare Scalable-TCP,
> High-Speed TCP, FAST-TCP, BIC-TCP, H-TCP and Standard TCP. They compared
>   fairness, compatibility with TCP and link utilisation.
> 
> You can find the results and a report at http://hamilton.ie/net/eval/

Nice work, I enjoyed this paper very much.

There is something that none of these papers mention, but is essential
for interpreting results.  Did you use interfaces with TSO enabled?

There is a very serious congestion window growth bug with TSO enabled
in the current 2.6.x tree.  The problem is due to congestion window
validation.  When we build TSO frames, even if we have packets to send,
we may defer a few frames until the full TSO packet can go out.
But this causes the congestion window validation checks in tcp_ack()
to not pass, and thus the congestion window does not grow.

I am going to have this fixed, but for now people should do congestion
window algorithm tests with TSO explicitly disabled on their interfaces.

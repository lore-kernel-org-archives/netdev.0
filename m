From: "David S. Miller" <davem@davemloft.net>
Subject: Re: rcv_wnd = init_cwnd*mss
Date: Thu, 28 Oct 2004 16:56:58 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041028165658.753eee50.davem@davemloft.net>
References: <DB2C167D8FFDEA45B8FC0B1B75E3EE154A3B08@usca1ex-priv1.sanmateo.corp.akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Meda, Prasanna" <pmeda@akamai.com>
In-Reply-To: <DB2C167D8FFDEA45B8FC0B1B75E3EE154A3B08@usca1ex-priv1.sanmateo.corp.akamai.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 27 Oct 2004 23:15:48 -0700
"Meda, Prasanna" <pmeda@akamai.com> wrote:

> Thanks, still it is unclear to me why are we
> downsizing the advertised window(rcv_wnd) to cwnd? 
> To defeat disobeying sender, or something like below?

There is never any reason to advertise a receive window
larger than the initial congestion window of the sender
could ever be.

Setting it properly like this also makes sure that we do
receive window update events at just the right place as
the sender starts sending us the initial data frames.

> And also in the following line,
> if (*rcv_wscale && sysctl_tcp_app_win && space>=mss &&
>                     space - max((space>>sysctl_tcp_app_win), mss>>*rcv_wscale) <
> 65536/2)
> 
> space is actual_space>>rcv_wscale, mss is actual value.
> Why are we checking space>=mss, which are in different
> scales? The second line is doing max on space and mss 
> on same scales, and looks right.

Yep, that space>=mss test looks super buggy for the *rcv_wscale
not zero case.

Good thing we don't have this buggy code in 2.6.x any more.
It's only present in 2.4.x

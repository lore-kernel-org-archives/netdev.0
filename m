From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Unbreak resetting default values for
 tcp_wmem/udp_wmem_min
Date: Mon, 10 Aug 2015 20:46:30 -0700 (PDT)
Message-ID: <20150810.204630.1903301700926701432.davem@davemloft.net>
References: <1438806414-751067-1-git-send-email-calvinowens@fb.com>
	<20150809.224114.818332231954008575.davem@davemloft.net>
	<20150811033406.GA1136819@mail.thefacebook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com, sorin@returnze.ro
To: calvinowens@fb.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150811033406.GA1136819@mail.thefacebook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Calvin Owens <calvinowens@fb.com>
Date: Mon, 10 Aug 2015 20:34:06 -0700

> I'm really questioning the limitation itself: why enforce a minimum of
> SOCK_MIN_SNDBUF here? Why not SK_MEM_QUANTUM?
> 
> Commit 8133534c760d4083 referred to b1cb59cf2efe7971, which choose to
> use the SOCK_MIN constants as the lower limits to avoid nasty bugs. But
> AFAICS, a limit of SOCK_MIN_SNDBUF isn't necessary to do that: the
> BUG_ON cited in the commit message for b1cb59cf2efe7971 seems to have
> happened because unix_stream_sendmsg() expects a minimum of a full page
> (ie SK_MEM_QUANTUM) and the math broke, not because it had less than
> SOCK_MIN_SNDBUF allocated.
> 
> Nothing seems to assume that it has at least SOCK_MIN_SNDBUF to play
> with, so my argument is that enforcing a minimum of SK_MEM_QUANTUM
> avoids the sort of bugs commit 8133534c760d4083 was trying to avoid, and
> it does so without breaking anybody's sysctl configurations. What do you
> think?

The author of said commit argues that too small values lead to really
bad performance, but I guess he should have adjusted the default if he
cared about it so much.

Ok, can you respin your patch with some added details in the commit
message like what you said above?

Thanks.

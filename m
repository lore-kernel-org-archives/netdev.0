From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] PKT_SCHED: remove c99ism
Date: Mon, 17 Jan 2005 12:56:37 +0100
Message-ID: <20050117115637.GB26856@postel.suug.ch>
References: <20050115144010.33182075.akpm@osdl.org> <20050115232554.GS26856@postel.suug.ch> <20050115153202.2f7f81c6.akpm@osdl.org> <20050115234056.GT26856@postel.suug.ch> <20050117090912.GB30371@mail.13thfloor.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Poetzl <herbert@13thfloor.at>
Content-Disposition: inline
In-Reply-To: <20050117090912.GB30371@mail.13thfloor.at>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Herbert Poetzl <20050117090912.GB30371@mail.13thfloor.at> 2005-01-17 10:09
> On Sun, Jan 16, 2005 at 12:40:56AM +0100, Thomas Graf wrote:
> > * Andrew Morton <20050115153202.2f7f81c6.akpm@osdl.org> 2005-01-15 15:32
> > > An uglier but more efficient approach is to whack braces around the whole
> > > thing.
> > 
> > Fine with me as well. The code isn't used that often and not deep in the
> > calling stack which is why I preferred the cleaner way first.
> 
> hmm, please remind me why putting some
> 
> #ifdef CONFIG_NET_CLS_ACT
> 	int err;
> 	struct tc_action *act;
> #endif
> 
> at the _beginning_ of that procedure would
> be a bad choice?

I personally don't think it's a bad choice but the less ifdefs the
better. 2 out of 3 of my latest bugs were related to such ifdefs because
testing gets more error prone. Personally I think the cleanest way
would be to create inlined functions together with a nop macro but
it would hide the mutual exclusiveness of NET_CLS_ACT and NET_CLS_POLICE
in this case which is even worse.

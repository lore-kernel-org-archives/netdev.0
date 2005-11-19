From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [DEBUG INFO]IPv6: sleeping function called from invalid context.
Date: Sat, 19 Nov 2005 22:04:11 +0100
Message-ID: <20051119210411.GE20395@postel.suug.ch>
References: <20051118123557.GD20395@postel.suug.ch> <E1EdRCZ-0007uy-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yoshfuji@linux-ipv6.org, yanzheng@21cn.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750847AbVKSVDw@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1EdRCZ-0007uy-00@gondolin.me.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Herbert Xu <herbert@gondor.apana.org.au> 2005-11-19 22:48
> Thomas Graf <tgraf@suug.ch> wrote:
> > 
> > I did. I think it was right, why would an allocation be necessary on
> > the second call to inet6_dump_fib()? The walker allocated in process
> > context on the first call should be reused from cb->args[0].
> 
> Continued dumps are always called under spin lock (see netlink_dump).
> So we need to use GFP_ATOMIC in dumpers.

The continued dumps wouldn't be the problem, the walker is allocated
on the initial dump call. It was a mistake though, nlk->cb_lock spin
lock is always held for cb->dump() even though it should only be
required during the nlk->cb != NULL check. netlink_dump_start()
guarantees to only allow one dumper per socket at a time.

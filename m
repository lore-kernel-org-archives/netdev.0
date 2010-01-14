From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: linux-next: Tree for January 8 (net/ip.h, BUG=n)
Date: Thu, 14 Jan 2010 07:32:53 -0800
Message-ID: <20100114073253.a87403e8.randy.dunlap@oracle.com>
References: <20100113085418.GB6053@ff.dom.local>
	<201001132121.44763.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Ingo Molnar <mingo@elte.hu>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev@vger.kernel.org, linux-next@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	Arnd Bergmann <arnd@arndb.de>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757250Ab0ANPdY@vger.kernel.org>
In-Reply-To: <201001132121.44763.opurdila@ixiacom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 13 Jan 2010 21:21:44 +0200 Octavian Purdila wrote:

> On Wednesday 13 January 2010 10:54:18 you wrote:
> > Octavian added to cc.
> > 
> > Jarek P.
> > 
> > On 13-01-2010 08:35, Ingo Molnar wrote:
> > > * Randy Dunlap <randy.dunlap@oracle.com> wrote:
> > >> On Fri, 8 Jan 2010 16:42:32 +1100 Stephen Rothwell wrote:
> > >>> Hi all,
> > >>>
> > >>> Changes since 20100107:
> > >>
> > >> When CONFIG_BUG=n, CONFIG_GENERIC_BUG=n:
> > >>
> > >> include/net/ip.h:341: error: implicit declaration of function '__WARN'
> > >>
> > >> This affects:
> > >> make[3]: *** [security/selinux/hooks.o] Error 1
> > >> make[3]: *** [fs/ceph/messenger.o] Error 1
> > >> make[3]: *** [net/core/sock.o] Error 1
> > >> make[4]: *** [drivers/net/benet/be_main.o] Error 1
> > >
> > > FYI, this new build bug is now upstream and triggers in -tip testing as
> > > well.
> > >
> > > 	Ingo
> > 
> 
> Sorry about this bug and the delay. David, here is a patch against net-2.6 to fix this build error.
> 
> [PATCH] net: fix build erros with CONFIG_BUG=n, CONFIG_GENERIC_BUG=n
> 
> Fixed build errors introduced by commit 7ad6848c (ip: fix mc_loop checks for
> tunnels with multicast outer addresses)
> 
> Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
> ---
>  include/net/ip.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/include/net/ip.h b/include/net/ip.h
> index d9a0e74..fb63371 100644
> --- a/include/net/ip.h
> +++ b/include/net/ip.h
> @@ -338,7 +338,7 @@ static inline int sk_mc_loop(struct sock *sk)
>  		return inet6_sk(sk)->mc_loop;
>  #endif
>  	}
> -	__WARN();
> +	WARN_ON(1);
>  	return 1;
>  }
>  
> -- 

Acked-by: Randy Dunlap <randy.dunlap@oracle.com>

Thanks.

---
~Randy

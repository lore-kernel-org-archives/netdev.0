From: Yury Norov <ynorov@caviumnetworks.com>
Subject: Re: next: arm64: LTP sendto01 test causes system crash in ilp32 mode
Date: Wed, 11 Oct 2017 22:43:55 +0300
Message-ID: <20171011194355.n6mb4oe7qt76d6wh@yury-thinkpad>
References: <20171011183522.tm2xxgzbdspjtsax@yury-thinkpad>
 <1507747313.31614.27.camel@edumazet-glaptop3.roam.corp.google.com>
 <1507747717.31614.28.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        netdev@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Westphal <fw@strlen.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1507747717.31614.28.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Eric,

On Wed, Oct 11, 2017 at 11:48:37AM -0700, Eric Dumazet wrote:
> On Wed, 2017-10-11 at 11:41 -0700, Eric Dumazet wrote:
> > On Wed, 2017-10-11 at 21:35 +0300, Yury Norov wrote:
> > > Hi all, 
> > > 
> > > It seems like next-20171009 with ilp32 patches crashes on LTP sendto01 test
> > > in sys_sendto() path, like this:
> > 
> > Thanks for the report.
> > Probably caused by one of my recent patches, so I am taking a look.
> 
> Yes, this was silly.
> 
> Please test this fix :
> 
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 5a95e5886b55e03e4a8bfeac3506c657a4f97dde..15163454174babdcb465904f725b919268dd1bc7 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -1712,6 +1712,7 @@ static inline void tcp_insert_write_queue_before(struct sk_buff *new,
>  
>  static inline void tcp_unlink_write_queue(struct sk_buff *skb, struct sock *sk)
>  {
> +	tcp_skb_tsorted_anchor_cleanup(skb);
>  	__skb_unlink(skb, &sk->sk_write_queue);
>  }

The fix works for me, thanks.

Tested-by: Yury Norov <ynorov@caviumnetworks.com>

From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] NETLINK: Use SKB_MAXORDER to calculate NLMSG_GOODSIZE
Date: Sun, 6 Feb 2005 22:27:12 -0800
Message-ID: <20050206222712.5519bc22.davem@davemloft.net>
References: <20050128230327.GV31837@postel.suug.ch>
	<E1CufRB-0000zf-00@gondolin.me.apana.org.au>
	<20050128234022.GW31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050128234022.GW31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 29 Jan 2005 00:40:22 +0100
Thomas Graf <tgraf@suug.ch> wrote:

> > > Using SKB_MAXORDER solves this potential leak at the cost of
> > > slightly smaller but safer sizes for some architectures.
> > 
> > At first glance it's not clear which of sk_buff or skb_shared_info
> > is bigger.  So it might even end up being bigger :)
> 
> skb_shared_info is 160 bytes and sk_buff is 196 bytes on my box (x86)
> but that's not the point. We need to take SMP_CACHE_BYTES alignment into
> account which tends to be quite big. The original NLMSG_GOODSIZE
> results in 3908 on my box and gets pumped up to 4128 by skb_alloc
> (ALIGN(...,SMP_CACHE_BYTES) + sizeof(struct skb_shared_info)) having
> SMP_CACHE_BYTES at 128. 

Furthermore, it's not sk_buff that's ever the issue.  The SKB data
area size is where the skb_shared_info gets tacked onto, sk_buff's
size is never added to this calculation.

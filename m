From: Patrick McHardy <kaber@trash.net>
Subject: Re: skb_checksum_help
Date: Mon, 24 Jan 2005 05:46:39 +0100
Message-ID: <41F47DAF.5050806@trash.net>
References: <20050124005348.GL23931@postel.suug.ch>	<E1Cst4o-0007bD-00@gondolin.me.apana.org.au>
	<20050123202715.281ac87c.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>,
	Herbert Xu <herbert@gondor.apana.org.au>, david@davidcoulson.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050123202715.281ac87c.davem@davemloft.net>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

David S. Miller wrote:

>Yes.  This backtrace is very strange.  Let me take this
>chance to get on my podium and re-express my distaste
>for x86's inaccurate backtraces.  They make debugging so
>difficult.  It's time for some dwarf2 unwind table support
>the kernel x86 backtracer and a way to enable it during the
>build.
>
>My current guess is that this is some successful exploit
>of some as-yet-unknown issue in netfilter's fragmentation
>handling.  But that's just a guess.  If some code underruns
>skb->data somehow while unfragging/refragging, that's a sure
>fire way to corrupt things such as the skb->ip_summed field.
>
That's what I suspect too. There is still the possibility of skbs
"jumping" through the stack between ip_defrag callers, the same
problem that caused the crashes on conntrack module unload fixed
by Olaf Kirch some time ago. This could theoretically cause skbs
from PRE_ROUTING to show up in POST_ROUTING and continue from
there on if NAT is used. Perhaps we should add a "user"-argument
to ip_defrag and keep fragment queues private to a single user.

Regards
Patrick

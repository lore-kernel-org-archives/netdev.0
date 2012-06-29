From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] fq_codel: report congestion
 notification at enqueue time
Date: Fri, 29 Jun 2012 06:18:59 +0200
Message-ID: <1340943539.13187.193.camel@edumazet-glaptop>
References: <1340903237.13187.151.camel@edumazet-glaptop>
	<CAB_+Fg7x2pV72Wa45QLuokHTVPuzdmrMfwiuLjS_vi02vtasAA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>,
	codel@lists.bufferbloat.net, Matt Mathis <mattmathis@google.com>,
	Neal Cardwell <ncardwell@google.com>, David Miller <davem@davemloft.net>
To: Nandita Dukkipati <nanditad@google.com>
Return-path: <codel-bounces@lists.bufferbloat.net>
In-Reply-To: <CAB_+Fg7x2pV72Wa45QLuokHTVPuzdmrMfwiuLjS_vi02vtasAA@mail.gmail.com>
List-Unsubscribe: <https://lists.bufferbloat.net/options/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=unsubscribe>
List-Archive: <https://lists.bufferbloat.net/pipermail/codel>
List-Post: <mailto:codel@lists.bufferbloat.net>
List-Help: <mailto:codel-request@lists.bufferbloat.net?subject=help>
List-Subscribe: <https://lists.bufferbloat.net/listinfo/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=subscribe>
Sender: codel-bounces@lists.bufferbloat.net
Errors-To: codel-bounces@lists.bufferbloat.net
List-Id: netdev.vger.kernel.org

On Thu, 2012-06-28 at 16:52 -0700, Nandita Dukkipati wrote:
> As you know I really like this idea. My main concern is that the same
> packet could cause TCP to reduce cwnd twice within an RTT - first on
> enqueue and then if this packet is ECN marked on dequeue. I don't
> think this is the desired behavior. Can we avoid it?

I'll work on this.

In my experiences, I found that no drops (or ECN marks) were done at
dequeue time once one NET_XMIT_CN was returned, but its certainly
possible if other flows compete with this one.

Strangely, SFQ has the same behavior and nobody complained yet ;)

Thanks

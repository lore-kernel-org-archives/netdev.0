From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: Fwd: [2.6] ethertap and af_inet.c assertion failures
Date: Sat, 15 Jan 2005 21:20:42 +0100
Message-ID: <41E97B1A.30205@tpack.net>
References: <E1Cpo1q-0007lI-00@gondolin.me.apana.org.au> <41E942AF.3030202@tpack.net> <20050115183023.GA31211@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: simon.roscic@chello.at, netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050115183023.GA31211@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Sat, Jan 15, 2005 at 05:19:59PM +0100, Tommy Christensen wrote:
> 
>>Shouldn't there be a check for skb_shared as well? Or are the
>>callers of netlink_unicast/broadcast supposed to avoid this.
> 
> 
> Had anyone been using shared skb's here before they would've got into
> trouble a long time ago with calls such as skb_orphan in the path.
> 
> Even if they managed to do that and not notice then the pskb_expand_head
> call in netlink_trim would've likely caught it as well.

Well, pskb_expand_head was added recently and isn't even always called.

Have a look at audit_log_drain() in kernel/audit.c. This code does:
   skb_get
   netlink_unicast
   ...
   kfree_skb

This is working just fine - until one day an over-sized skb comes along
and hits the BUG in pskb_expand_head ...

That particular example can easily be solved by re-arranging the code a
bit (I'll send a patch to someone).

Still, regarding netlink, I think the safe approach is to either handle
or disallow shared skb's. Anything in-between could appear to be working,
and then suddenly blow up on your production system. </paranoia>

-Tommy

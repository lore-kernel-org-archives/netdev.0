From: Andi Kleen <ak@muc.de>
Subject: Re: netif_rx packet dumping
Date: 8 Mar 2005 19:18:44 +0100
Message-ID: <20050308181844.GA37392@muc.de>
References: <20050303123811.4d934249@dxpl.pdx.osdl.net> <42278122.6000000@ev-en.org> <20050303133659.0d224e61.davem@davemloft.net> <42278554.2090902@ev-en.org> <20050303135718.2e1a0170.davem@davemloft.net> <422DC7CE.2040800@ev-en.org> <m1y8cykr7i.fsf@muc.de> <20050308100902.24b67b2f.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: baruch@ev-en.org, shemminger@osdl.org, netdev@oss.sgi.com
Date: Tue, 8 Mar 2005 19:18:44 +0100
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050308100902.24b67b2f.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> > You could also use a xor list in theory. But I'm not sure it's worth it.
> > Increasing cb by 4 bytes shouldn't be a very big issue.
> 
> Going from "40" to "44" takes 64-bit platforms onto another cache line
> for struct sk_buff, as I stated in another email.
> 
> And every time I let this happen, I get an email from David Mosberger because
> it shows up in performance tests on ia64. :-)

Ok, then use a XOR list or trim some other field.

There are some other savings possible e.g. from a quick look:
- skb->list is afaik totally unnecessary and probably even unused.
- struct timeval could be an optimized structure using 32bit
for the sub second part. 
(would need moving it somewhere else, otherwise alignment doesn't help)
- Are really three device pointers needed? Perhaps things can
be a bit optimized here.
- Hippi could be finally changed to use skb->cb instead of its
private field.
- is skb->security still needed? It should be obsolete with ->sec_path, no?
Would only help together with the timestamp optimization.

Of course these all wouldn't change the number of cache lines significantly,
but it would possible allow other optimizations that need new fields.

-Andi

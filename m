From: Thomas Graf <tgraf@suug.ch>
Subject: Re: netif_rx packet dumping
Date: Tue, 8 Mar 2005 19:37:59 +0100
Message-ID: <20050308183759.GE31837@postel.suug.ch>
References: <20050303123811.4d934249@dxpl.pdx.osdl.net> <42278122.6000000@ev-en.org> <20050303133659.0d224e61.davem@davemloft.net> <42278554.2090902@ev-en.org> <20050303135718.2e1a0170.davem@davemloft.net> <422DC7CE.2040800@ev-en.org> <m1y8cykr7i.fsf@muc.de> <20050308100902.24b67b2f.davem@davemloft.net> <20050308181844.GA37392@muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, baruch@ev-en.org,
        shemminger@osdl.org, netdev@oss.sgi.com
To: Andi Kleen <ak@muc.de>
Content-Disposition: inline
In-Reply-To: <20050308181844.GA37392@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Andi Kleen <20050308181844.GA37392@muc.de> 2005-03-08 19:18
> There are some other savings possible e.g. from a quick look:
> - skb->list is afaik totally unnecessary and probably even unused.
> - struct timeval could be an optimized structure using 32bit
> for the sub second part. 
> (would need moving it somewhere else, otherwise alignment doesn't help)
> - Are really three device pointers needed? Perhaps things can
> be a bit optimized here.

Likely that real_dev can be moved to cb. I would like to keep indev
though, it really helps at policy routing decisions.

> - Hippi could be finally changed to use skb->cb instead of its
> private field.

Definitely.

> - is skb->security still needed? It should be obsolete with ->sec_path, no?
> Would only help together with the timestamp optimization.

security has been unused for quite some time as far as I can see.

Anyone going for a patch? Otherwise I'll give it a try.

Speaking of it, I see tcp_sock is marginal over 2**10 on 32 bit archs and
Stephen's plans to outsource the cc bits brings us closer to the border.
Would it be worth to try and get it below 2**10? I spotted some places
for optimizations but not enough to really save the needed amount.

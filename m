From: Andi Kleen <ak@muc.de>
Subject: Re: netif_rx packet dumping
Date: 8 Mar 2005 23:16:36 +0100
Message-ID: <20050308221636.GA94879@muc.de>
References: <20050303123811.4d934249@dxpl.pdx.osdl.net> <42278122.6000000@ev-en.org> <20050303133659.0d224e61.davem@davemloft.net> <42278554.2090902@ev-en.org> <20050303135718.2e1a0170.davem@davemloft.net> <422DC7CE.2040800@ev-en.org> <m1y8cykr7i.fsf@muc.de> <20050308100902.24b67b2f.davem@davemloft.net> <20050308181844.GA37392@muc.de> <20050308183759.GE31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, baruch@ev-en.org,
        shemminger@osdl.org, netdev@oss.sgi.com
Date: Tue, 8 Mar 2005 23:16:36 +0100
To: Thomas Graf <tgraf@suug.ch>
Content-Disposition: inline
In-Reply-To: <20050308183759.GE31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Mar 08, 2005 at 07:37:59PM +0100, Thomas Graf wrote:
> * Andi Kleen <20050308181844.GA37392@muc.de> 2005-03-08 19:18
> > There are some other savings possible e.g. from a quick look:
> > - skb->list is afaik totally unnecessary and probably even unused.

I was wrong on that. Removing skb->list would be worthy, but needs
a lot of changes.

[BTW there seems to be large cleanup potential in skb list functions;
lots of cruft and even some unused functions around and the locking
is prehistoric too. In case anybody is interested in a useful cleanup
project]

> > - struct timeval could be an optimized structure using 32bit
> > for the sub second part. 
> > (would need moving it somewhere else, otherwise alignment doesn't help)
> > - Are really three device pointers needed? Perhaps things can
> > be a bit optimized here.
> 
> Likely that real_dev can be moved to cb. I would like to keep indev
> though, it really helps at policy routing decisions.

Moving to cb is useless, you just would need to enlarge it then.


-Andi

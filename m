From: Tomas Szepe <szepe@pinerecords.com>
Subject: Re: 1e918876 breaks r8169 (linux-3.18+)
Date: Sat, 21 Feb 2015 20:05:08 +0100
Message-ID: <20150221190507.GA25687@louise.pinerecords.com>
References: <20150203100816.GA5807@louise.pinerecords.com>
 <20150203104214.GG24751@breakpoint.cc>
 <20150210154536.GB16264@breakpoint.cc>
 <20150221101512.GB17223@louise.pinerecords.com>
 <20150221103104.GA26574@breakpoint.cc>
 <1424535746.5565.42.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Hayes Wang <hayeswang@realtek.com>,
	Eric Dumazet <edumazet@google.com>,
	Tom Herbert <therbert@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Marco Berizzi <pupilla@hotmail.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1424535746.5565.42.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > David, please consider reverting
> > 
> > 1e918876853aa85435e0f17fd8b4a92dcfff53d6
> > (r8169: add support for Byte Queue Limits)
> > 
> > 	and
> > 
> > 0bec3b700d106a8b0a34227b2976d1a582f1aab7
> > (r8169: add support for xmit_more)
> > 
> > I cannot reproduce any hangs (tried for 2days with 40 parallel
> > netperfs using both 100mbit and 1gbit receiver).
> > 
> > And I don't see anything wrong with the change either.
> > Seems like some revisions of the HW are just dodgy?
> > 
> > I hate giving up, but I have no means to diagnose this any further.
> > Even reporter says it doesn't affect all of his r8169 nics.
> > 
> > So I think the change is correct per se, but might be revealing some
> > HW/firmware bug.
> 
> Hold on.
> 
> I believe there is one race in the way you access skb->xmit_more _after_
> 
> txd->opts1 = cpu_to_le32(status);
> 
> After this point, TX might have completed and TX completion already have
> freed skb
> 
> Could Tomas try following fix ?
> 
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index ad0020af2193..f2764366a36c 100644
> ...

Sure, just did.  Unfortunately, 3.19.0 + 0bec3b70 + this patch results
in a driver that retains the problem.

Sorry,
-- 
Tomas Szepe <szepe@pinerecords.com>

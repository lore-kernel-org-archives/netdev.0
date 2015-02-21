From: Florian Westphal <fw@strlen.de>
Subject: Re: 1e918876 breaks r8169 (linux-3.18+)
Date: Sat, 21 Feb 2015 19:32:09 +0100
Message-ID: <20150221183209.GA30167@breakpoint.cc>
References: <20150203100816.GA5807@louise.pinerecords.com>
 <20150203104214.GG24751@breakpoint.cc>
 <20150210154536.GB16264@breakpoint.cc>
 <20150221101512.GB17223@louise.pinerecords.com>
 <20150221103104.GA26574@breakpoint.cc>
 <1424535746.5565.42.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150221174625.GA29681@breakpoint.cc>
 <1424542141.5565.46.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	Tomas Szepe <szepe@pinerecords.com>,
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
In-Reply-To: <1424542141.5565.46.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sat, 2015-02-21 at 18:46 +0100, Florian Westphal wrote:
> > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > > Hold on.
> > > 
> > > I believe there is one race in the way you access skb->xmit_more _after_
> > > 
> > > txd->opts1 = cpu_to_le32(status);
> > > 
> > > After this point, TX might have completed and TX completion already have
> > > freed skb
> > 
> > Hmm, I _thought_ HW would not start xmit of this descriptor/skb until after
> > 
> > RTL_W8(TxPoll, NPQ);
> 
> Note this 'kick' does not provide tail ptr.
> 
> NIC basically looks at TX descriptors to find ones with the DescOwn bit
> set. It stops when if find one TX descriptor _without_ DescOwn.

Makes sense, thanks for explaining this.

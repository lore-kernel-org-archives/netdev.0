From: Holger Eitzenberger <holger@eitzenberger.org>
Subject: Re: [patch 0/6] netfilter: ctnetlink allocation improvement
Date: Tue, 17 Mar 2009 11:03:51 +0100
Message-ID: <20090317100350.GA3526@mail.eitzenberger.org>
References: <20090316220659.756862181@jonathan.eitzenberger.org> <49BF720C.2010603@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <49BF720C.2010603@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 17, 2009 at 10:49:00AM +0100, Pablo Neira Ayuso wrote:

> > Though I haven't got any hard performance numbers yet I think this
> > might introduce a noticable performance gain.
> 
> I'm not sure about this. Instead, I noticed with oprofile that we spend
> more cycles to calculate the message size. I think it's more like a
> trade-off, reducing the message size to what we need reduces the chances
> to hit ENOBUFS.

Hi Pablo,

your patch is a bit different, as you do the message length
calculation on each packet.  Instead I do it once at compile time for
the proto independant part and then later for each protocol helper at
the time it is registered.  At unload time the helper is replaced by
the generic one (which implies =0 always).

Cheers,

 /holger


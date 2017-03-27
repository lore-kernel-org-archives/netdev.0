From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] cfg80211: Fix array-bounds warning in fragment copy
Date: Mon, 27 Mar 2017 13:38:36 +0200
Message-ID: <1490614716.3393.6.camel@sipsolutions.net>
References: <20170325010644.190368-1-mka@chromium.org>
         <1490611679.3393.0.camel@sipsolutions.net>
         <5f290298-a28c-de0c-3fef-642d32b0982d@nbd.name>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Grant Grundler <grundler@chromium.org>
To: Felix Fietkau <nbd@nbd.name>, Matthias Kaehlcke <mka@chromium.org>,
        "David S . Miller" <davem@davemloft.net>,
        Felix Fietkau <nbd@openwrt.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5f290298-a28c-de0c-3fef-642d32b0982d@nbd.name>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> > > -	const skb_frag_t *frag = &sh->frags[-1];
> > > +	const skb_frag_t *frag = &sh->frags[0];
[...]
> > > +	frag--;
> > 
> > Isn't it just a question of time until the compiler will see
> > through this trick and warn about it?
> 
> Frag is incremented again before being accessed, so there is nothing
> for the compiler to see through here.

But by that argument the existing code was already fine. The compiler
flagged it nonetheless, perhaps because it couldn't prove it was
incremented unconditionally/in all branches?

johannes

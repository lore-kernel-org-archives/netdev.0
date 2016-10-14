From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [mac80211] BUG_ON with current -git (4.8.0-11417-g24532f7)
Date: Fri, 14 Oct 2016 17:39:57 +0900
Message-ID: <20161014083957.GA421@swordfish>
References: <20161010150358.GA514@swordfish>
 <20161010153050.GA836@swordfish>
 <1476263106.5271.23.camel@sipsolutions.net>
 <20161012141245.GA436@swordfish>
 <1476282127.5271.30.camel@sipsolutions.net>
 <CALCETrXg9-OpJx5Rqz8afyaug+0DjzxvpdbOV9q6i01=zCZbcQ@mail.gmail.com>
 <1476338524.4904.1.camel@sipsolutions.net>
 <20161013134252.GA583@swordfish>
 <1476366354.4904.31.camel@sipsolutions.net>
 <CALCETrW8imkGTtR9-mFB=e=Gdr1QXVuhXN3GRs2B6wbmPaaGhA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
        "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
        Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
        Network Development <netdev@vger.kernel.org>,
        Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Wireless List <linux-wireless@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>,
        Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CALCETrW8imkGTtR9-mFB=e=Gdr1QXVuhXN3GRs2B6wbmPaaGhA@mail.gmail.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On (10/13/16 14:49), Andy Lutomirski wrote:
[..]
> > >  FAIL: 00004100002cba02 > ffffc900802cba02 || 1 -> (00004100002cba02
> > > >> 39) == 130
> >
> > Yeah, we already know that in this function the aad variable is on the
> > stack, it explicitly is.
> >
> > The question, though, is why precisely that fails in the crypto code.
> > Can you send the Oops report itself?
> >
> 
> It's failing before that.  With CONFIG_VMAP_STACK=y, the stack may not
> be physically contiguous and can't be used for DMA, so putting it in a
> scatterlist is bogus in general, and the crypto code mostly wants a
> scatterlist.
> 
> There are a couple (faster!) APIs for crypto that don't use
> scatterlists, but I don't think AEAD works with them.

given that we have a known issue shouldn't VMAP_STACK be
disabled for now, or would you rather prefer to mark MAC80211
as incompatible: "depends on CFG80211 && !VMAP_STACK"?

	-ss

From: Michael Guntsche <mike@it-loops.com>
Subject: Re: BUG: scheduling while atomic
Date: Mon, 6 Jul 2009 17:28:06 +0200
Message-ID: <11EC5046-5F30-4CB6-BDAF-0DAA2C69929B@it-loops.com>
References: <23AED400-6DA5-462F-94F0-BEE34AC08A7A@it-loops.com> <20090627140643.7140f6a9@lxorguk.ukuu.org.uk> <33C7D336-F062-47B3-9033-D3DC465F793C@it-loops.com> <20090706074333.GA17276@gondor.apana.org.au> <20090706083119.GA17782@gondor.apana.org.au>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752064AbZGFP2T@vger.kernel.org>
In-Reply-To: <20090706083119.GA17782@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Jul 6, 2009, at 10:31, Herbert Xu wrote:

> On Mon, Jul 06, 2009 at 03:43:33PM +0800, Herbert Xu wrote:
>>
>> I think the first backtrace is bogus, this is where the real
>> problem is.  So what see here is that on xmit from the network,
>> PPP will call pty_write from BH context which eventually leads
>> to tty_throttle and the sleep.
>
> Here's the stupidest possible fix for this, changing the mutex
> to a spin lock.  We should also revert the other commit that
> tried to fix this, a6540f731d506d9e82444cf0020e716613d4c46c as
> those unthrottles are really needed
<snip>

Just to confirm.
I reverted the commit and applied the patch on-top of 2.6.31-rc2.
Up to now I was not able to reproduce the crashes I had before on my  
setup here.


Kind regards,
Michael

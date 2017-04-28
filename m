From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH v6 1/5] skbuff: return -EMSGSIZE in skb_to_sgvec to
 prevent overflow
Date: Sat, 29 Apr 2017 00:47:30 +0200
Message-ID: <CAHmME9rt7Ke4-x0+LyxThco4PybBi+eKVw0vRyHpQWuB70BjcA@mail.gmail.com>
References: <20170425155215.4835-1-Jason@zx2c4.com> <20170425184734.26563-1-Jason@zx2c4.com>
 <20170428161840.GA30423@bistromath.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	David Laight <David.Laight@aculab.com>, kernel-hardening@lists.openwall.com,
	David Miller <davem@davemloft.net>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <kernel-hardening-return-7625-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20170428161840.GA30423@bistromath.localdomain>
List-Id: netdev.vger.kernel.org

Hi Sabrina,

On Fri, Apr 28, 2017 at 6:18 PM, Sabrina Dubroca <sd@queasysnail.net> wrote:
> One small thing here: since you're touching this comment, could you
> move it next to skb_to_sgvec, since that's the function it's supposed
> to document?

Done. I'll wait until next week to resubmit, to give some more time
for comments, but my current living copy of this series is here:
https://git.zx2c4.com/linux-dev/log/?h=jd/safe-skb-vec

One thing I'm considering, after discussing with David Laight, is the
potential of just using an explicit stack array for pushing and
popping skbs, rather than using the call stack. While this increases
complexity, which I'm opposed to, David makes the point that on some
architectures, the stack frame is rather large, and 32 function calls
of recursion might not be a good idea. Any opinons on this? Overkill
and simplicity is preferred? Or in fact best practice? (Either way,
I'll do a trial implementation of it to get an idea of how the end
result feels.)

From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH v2] netlink: Replace rhash_portid with bound
Date: Tue, 22 Sep 2015 14:04:33 -0700
Message-ID: <CA+55aFyrctX5UH7Y+0731Tmb-HzjxxFt-c2cv-4iG9aCZPmsaw@mail.gmail.com>
References: <20150920.225521.1063980101511317898.davem@davemloft.net>
	<20150921060636.GA30807@gondor.apana.org.au>
	<20150920.231104.525285577747035896.davem@davemloft.net>
	<20150921133415.GA1740@gondor.apana.org.au>
	<20150921182022.GB13263@mtj.duckdns.org>
	<20150922033856.GA7851@gondor.apana.org.au>
	<20150922161056.GB9761@mtj.duckdns.org>
	<CA+55aFyvPLD5tNsuxFAA4GgOZpamULJe7R90dXf5qSC6aBYzTw@mail.gmail.com>
	<20150922185357.GD17659@mtj.duckdns.org>
	<CA+55aFy3k_NouhizkAkiZkuTYTqEKQZCnz8yOzrSH8o4+vjKUw@mail.gmail.com>
	<20150922195059.GF17659@mtj.duckdns.org>
	<CA+55aFzvp5gGS9jVA2O=vVM3Fd=VpCEfaqw8UKoU_Wk-ZkOgOg@mail.gmail.com>
	<87wpvii42c.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tejun Heo <tj@kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>,
	Tom Herbert <tom@herbertland.com>, kafai@fb.com,
	kernel-team@fb.com,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Thomas Graf <tgraf@suug.ch>, Scott Feldman <sfeldma@gmail.com>
To: =?UTF-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87wpvii42c.fsf@nemi.mork.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 22, 2015 at 1:36 PM, Bj=C3=B8rn Mork <bjorn@mork.no> wrote:
>
> http://download.intel.com/design/archives/processors/pro/docs/2426893=
5.pdf
>
> Says "NoFix" for erratas 66 and 92.

Yeah, 66 and 92 do look like they could cause the apparent ordering of
accesses to be violated. That said, both of them <i>seem</i> to be
"processor had exclusive access to line A, and gave it away but ended
up still reading now-stale data".

And that's not what we use "smp_wmb()" or "smp_rmb()" to protect
against. If we did a write and then wanted to do an ordered read, we'd
use smp_mb(), which always does that barrier.

So I don't know whether either of those really merit our PPRO
workaround. Cache coherency is hard.

There's also errata 41, which looks like it would be a bad situation.

                 Linus

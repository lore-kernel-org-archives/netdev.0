From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: 2.6.12-rc4-mm2 - sleeping function called from invalid context
	at mm/slab.c:2502
Date: Wed, 18 May 2005 18:52:35 +0100
Message-ID: <1116438756.25594.76.camel@localhost.localdomain>
References: <200505171624.j4HGOQwo017312@turing-police.cc.vt.edu>
	 <20050517165528.GB27549@shell0.pdx.osdl.net>
	 <1116349464.23972.118.camel@hades.cambridge.redhat.com>
	 <20050517174300.GE27549@shell0.pdx.osdl.net>
	 <20050518083002.GA30689@gondor.apana.org.au>
	 <20050518170033.GT27549@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com,
        "David S. Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Linux Audit Discussion <linux-audit@redhat.com>
In-Reply-To: <20050518170033.GT27549@shell0.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-05-18 at 10:00 -0700, Chris Wright wrote:
> * Herbert Xu (herbert@gondor.apana.org.au) wrote:
> > Guys, please CC netdev on issues like this.
> 
> Sorry Herbert, we hadn't yet concluded that it's not an issue that we
> need to resolve within audit.

I suspect that it _is_ an issue we can resolve entirely within audit
code. See the patch I posted half an hour or so ago to the linux-audit
list. If we agree on that approach, I'll do the equivalent for the git
tree either later this evening or tomorrow.

I've reverted your recent change to put audit messages directly into
skbs "in order to eliminate the extra copy", on the basis that it
blatantly wasn't having that effect anyway. Now we copy from the
audit_buffer into an optimally-sized skb which netlink_trim() won't have
to mangle. I've also removed the skb_get() immediately before
netlink_send() which always made me unhappy.

-- 
dwmw2

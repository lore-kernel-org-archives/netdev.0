From: "David S. Miller" <davem@redhat.com>
Subject: Re: [NAT-T] NON-IKE encapsulation
Date: Fri, 25 Jun 2004 10:12:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040625101231.6f6b2f12.davem@redhat.com>
References: <20040624123603.GA1241@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: agruen@suse.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040624123603.GA1241@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 24 Jun 2004 22:36:03 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> I'm having trouble understanding why we need to increase alen by
> two bytes for NON-IKE.  As far as I can see it's adding two bytes
> of random data to the end of the packet.  Is there something
> obvious that I'm missing?

I now think it's trying to account for the udpdata32[] header area.
But that's not 2 bytes, it's (2 * sizeof(u32)) or 8 bytes.

The ESP added headers amount to esp->auth.icv_trunc_len + 8 in
this case, so changing the "alen += 2;" into "alen += 8;" seems
more appropriate.

What do you think Herbert?  Does it make sense now?

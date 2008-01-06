From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: sparc oops in ip_fast_csum
Date: Sun, 6 Jan 2008 02:02:14 +0000
Message-ID: <20080106020214.GQ27894@ZenIV.linux.org.uk>
References: <20080105094400.GH27894@ZenIV.linux.org.uk> <E1JBJHA-0000hy-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: m.kozlowski@tuxland.pl, davem@davemloft.net,
	sparclinux@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <sparclinux-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <E1JBJHA-0000hy-00@gondolin.me.apana.org.au>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 06, 2008 at 11:22:04AM +1100, Herbert Xu wrote:
> Actually if you read the code for ip_fast_csum it's obvious what has
> happened.  %o1 == iph->ihl contains the value 2 which is bogus.
> 
> [IPV4] raw: Strengthen check on validity of iph->ihl 
> 
> We currently check that iph->ihl is bounded by the real length and that
> the real length is greater than the minimum IP header length.  However,
> we did not check the caes where iph->ihl is less than the minimum IP
> header length.
> 
> This breaks because some ip_fast_csum implementations assume that which
> is quite reasonable.

Humm...  Point, but that makes me wonder what other callers do...

E.g. what about ipt_REJECT.c::send_reset()?  Or myri10ge_get_frag_header()?

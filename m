From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [XFRM]: Fix ICMP tempsel
Date: Sun, 20 Feb 2005 05:43:51 +1100
Message-ID: <20050219184351.GB10773@gondor.apana.org.au>
References: <4217266F.6090700@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Maillist netdev <netdev@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <4217266F.6090700@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Feb 19, 2005 at 12:43:43PM +0100, Patrick McHardy wrote:
> The selector ports are initialized to fl_ip_sport/fl_ip_dport instead
> of xfrm_flowi_sport(fl)/xfrm_flowi_dport(fl). This is wrong for ICMP,
> type and code should be stored in sport and dport, in struct flowi both
> are contained in fl_ip_sport.

I know this comment is probably a bit late but why didn't we simply put
type/code into sport/dport in struct flowi instead of introducing the
monstrosities of xfrm_flowi_sport/xfrm_flowi_dport?

Something like

struct {
	__u16	type;
	__u16	code;
} icmpt;

would've done (and still would do) the trick, no?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

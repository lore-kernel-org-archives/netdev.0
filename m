From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Replace send_unreach with icmp_send
Date: Wed, 16 Mar 2005 07:40:06 +1100
Message-ID: <20050315204006.GB22349@gondor.apana.org.au>
References: <20050307103536.GB7137@gondor.apana.org.au> <20050308102741.GA23468@gondor.apana.org.au> <20050314102614.GA9610@gondor.apana.org.au> <20050314105313.GA21001@gondor.apana.org.au> <20050314111002.GA29156@gondor.apana.org.au> <20050315091904.GA6256@gondor.apana.org.au> <20050315095837.GA7130@gondor.apana.org.au> <20050315100522.GA7275@gondor.apana.org.au> <20050315102450.0f3f1618.davem@davemloft.net> <42373142.6090902@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
        yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <42373142.6090902@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Mar 15, 2005 at 08:02:26PM +0100, Patrick McHardy wrote:
> 
> I would prefer to keep it seperately. I have planned to remove xrlim
> from ipt_REJECT so it behaves similar for TCP and ICMP. Limits should
> then be handled by the limit match. This can't be done if we switch to
> icmp_send().

Well it isn't terribly difficult to create a new version of icmp_send
that does xrlim conditionally.  icmp_send/ipt_REJECT can then call that
function.

The main reason I'm looking at getting rid of send_unreach is because
having two implementations of the same code often leads to bugs.  In
fact, as it is there are multiple IPsec-related bugs in the ipt_REJECT
code.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

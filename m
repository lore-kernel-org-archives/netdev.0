From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [XFRM] Make XFRM core subsystem af-independent
Date: Sat, 18 Sep 2004 10:10:44 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040918001044.GA24235@gondor.apana.org.au>
References: <E1C8I2m-0005BS-00@gondolin.me.apana.org.au> <20040917.231127.114842301.yoshfuji@linux-ipv6.org> <20040917153536.6acec52e.davem@davemloft.net> <20040918.085003.77842779.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20040918.085003.77842779.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Sep 18, 2004 at 08:50:03AM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:
>
>  3. inlined __ip_route_output_flow() + ip_route_output_flow(), ip_route_output_key
>     - maintenancability will be improved
>     - breaks binary-only modules.
>     - code size.
>  4. migrate completely (my one)
>     - maintenancability will be improved
>     - breaks binary-only modules.
>     - best stack usage, minimum function call, code size.
>     - changes more places.

You missed the more obvious version of 3:

5. inline ip_route_output_key() only

That is exactly the same as 4 except that it doesn't cause ripple
effects all over the place.

However, I really don't think 16 bytes of stack usage is anything
to write home about :)

Actually, there is a solution to that as well:

6. Add an inline version of __ip_route_output_flow() in route.c and
get ip_route_output_flow/ip_route_output_key to use that.

It'll generate code slightly bigger than 2 but is vastly smaller than 4.
Otherwise it has all the advantages of 2 and 4.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

From: AndyLiebman@aol.com
Subject: Re: Frequent Oops on Shutdown 2.6.10
Date: Wed, 23 Feb 2005 09:53:14 EST
Message-ID: <6.3f715fba.2f4df2da@aol.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: terryg@axian.com, netdev@oss.sgi.com, davem@davemloft.net, akpm@osdl.org
To: herbert@gondor.apana.org.au, yoshfuji@linux-ipv6.org
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello, Yoshi

Should I bother to apply  this patch, or should I wait for you to make this 
last change? What did you  think about my comment that the Oops only occurred 
when the Ethernet cable had  been unplugged during operation? 

Regards, 
Andy Liebman


In  a message dated 2/23/2005 4:52:59 A.M. Eastern Standard Time,  
herbert@gondor.apana.org.au writes:
On Wed, Feb 23, 2005 at 06:35:55PM +0900,  YOSHIFUJI Hideaki / ?$B5HF#1QL@ 
wrote:
> 
> What do you think of  this?

Thanks, this looks great.  There is just one technical  detail
to patch up.

> -int snmp6_unregister_dev(struct inet6_dev  *idev)
> +int snmp6_free_dev(struct inet6_dev *idev)
>   {
>      snmp6_mib_free((void  **)idev->stats.icmpv6);
>      return  0;
>  }

You need to check whether icmpv6[0] is NULL either  here or in
snmp6_mib_free.  Otherwise when snmp6_alloc_dev fails  we'll
wind up here and then call free_percpu on a pair of NULL  pointers.

Cheers,
-- 
Visit Openswan at  http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~}  <herbert@gondor.apana.org.au>
Home Page:  http://gondor.apana.org.au/~herbert/
PGP Key:  http://gondor.apana.org.au/~herbert/pubkey.txt  

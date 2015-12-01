From: Stefan Schmidt <stefan-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
Subject: Re: [RFCv3 bluetooth-next 3/4] ipv6: add ipv6_addr_prefix_copy
Date: Tue, 1 Dec 2015 12:38:01 +0100
Message-ID: <565D8699.5090409@osg.samsung.com>
References: <1448796882-316-1-git-send-email-alex.aring@gmail.com>
 <1448796882-316-4-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, mcr-SWp7JaYWvAQV+D8aMU/kSg@public.gmane.org, lukasz.duda-hR+23Fw+YnFSHonuZl5R5Q@public.gmane.org,
	martin.gergeleit-6wGqcYweBVc@public.gmane.org,
	"David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>,
	James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
	Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
To: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1448796882-316-4-git-send-email-alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello.

On 29/11/15 12:34, Alexander Aring wrote:
> This patch adds a static inline function ipv6_addr_prefix_copy which
> copies a ipv6 address prefix(argument pfx) into the ipv6 address prefix.
> The prefix len is given by plen as bits. This function mainly based on
> ipv6_addr_prefix which copies one address prefix from address into a new
> ipv6 address destination and zero all other address bits.
>
> The difference is that ipv6_addr_prefix_copy don't get a prefix from an
> ipv6 address, it sets a prefix to an ipv6 address with keeping other
> address bits. The use case is for context based address compression
> inside 6LoWPAN IPHC header which keeping ipv6 prefixes inside a context
> table to lookup address-bits without sending them.
>
> Cc: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> Cc: Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>
> Cc: James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>
> Cc: Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>
> Cc: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
> Signed-off-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>   include/net/ipv6.h | 15 +++++++++++++++
>   1 file changed, 15 insertions(+)
>
> diff --git a/include/net/ipv6.h b/include/net/ipv6.h
> index e1a10b0..cd3881e6 100644
> --- a/include/net/ipv6.h
> +++ b/include/net/ipv6.h
> @@ -382,6 +382,21 @@ static inline void ipv6_addr_prefix(struct in6_addr *pfx,
>   		pfx->s6_addr[o] = addr->s6_addr[o] & (0xff00 >> b);
>   }
>   
> +static inline void ipv6_addr_prefix_copy(struct in6_addr *addr,
> +					 const struct in6_addr *pfx,
> +					 int plen)
> +{
> +	/* caller must guarantee 0 <= plen <= 128 */
> +	int o = plen >> 3,
> +	    b = plen & 0x7;
> +
> +	memcpy(addr->s6_addr, pfx, o);
> +	if (b != 0) {
> +		addr->s6_addr[o] &= ~(0xff00 >> b);
> +		addr->s6_addr[o] |= (pfx->s6_addr[o] & (0xff00 >> b));
> +	}
> +}
> +
>   static inline void __ipv6_addr_set_half(__be32 *addr,
>   					__be32 wh, __be32 wl)
>   {

Thanks for taking up the review comments. You can add my r-b now:

Reviewed-by: Stefan Schmidt <stefan-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>

regards
Stefan Schmidt

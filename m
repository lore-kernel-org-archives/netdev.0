From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v3] ip6_output: ensure flow saddr actually
 belongs to device
Date: Mon, 14 Nov 2016 09:19:37 -0700
Message-ID: <87012eb2-e52d-7058-4115-a4a3c70a7b4c@cumulusnetworks.com>
References: <27cccef1-06d9-74b3-5b8a-912850119a76@cumulusnetworks.com>
 <20161113232813.28926-1-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Jason A. Donenfeld" <Jason@zx2c4.com>, Netdev <netdev@vger.kernel.org>,
 WireGuard mailing list <wireguard@lists.zx2c4.com>,
 LKML <linux-kernel@vger.kernel.org>,
 YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
 Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <wireguard-bounces@lists.zx2c4.com>
In-Reply-To: <20161113232813.28926-1-Jason@zx2c4.com>
List-Unsubscribe: <http://lists.zx2c4.com/mailman/options/wireguard>,
 <mailto:wireguard-request@lists.zx2c4.com?subject=unsubscribe>
List-Archive: <http://lists.zx2c4.com/pipermail/wireguard/>
List-Post: <mailto:wireguard@lists.zx2c4.com>
List-Help: <mailto:wireguard-request@lists.zx2c4.com?subject=help>
List-Subscribe: <http://lists.zx2c4.com/mailman/listinfo/wireguard>,
 <mailto:wireguard-request@lists.zx2c4.com?subject=subscribe>
Errors-To: wireguard-bounces@lists.zx2c4.com
Sender: "WireGuard" <wireguard-bounces@lists.zx2c4.com>
List-Id: netdev.vger.kernel.org

On 11/13/16 4:28 PM, Jason A. Donenfeld wrote:
> This puts the IPv6 routing functions in parity with the IPv4 routing
> functions. Namely, we now check in v6 that if a flowi6 requests an
> saddr, the returned dst actually corresponds to a net device that has
> that saddr. This mirrors the v4 logic with __ip_dev_find in
> __ip_route_output_key_hash. In the event that the returned dst is not
> for a dst with a dev that has the saddr, we return -EINVAL, just like
> v4; this makes it easy to use the same error handlers for both cases.
> 
> Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
> Cc: David Ahern <dsa@cumulusnetworks.com>
> ---
> Changes from v2:
>     It turns out ipv6_chk_addr already has the device enumeration
>     logic that we need by simply passing NULL.
> 
>  net/ipv6/ip6_output.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> index 6001e78..b3b5cb6 100644
> --- a/net/ipv6/ip6_output.c
> +++ b/net/ipv6/ip6_output.c
> @@ -926,6 +926,10 @@ static int ip6_dst_lookup_tail(struct net *net, const struct sock *sk,
>  	int err;
>  	int flags = 0;
>  
> +	if (!ipv6_addr_any(&fl6->saddr) &&
> +	    !ipv6_chk_addr(net, &fl6->saddr, NULL, 1))
> +		return -EINVAL;
> +
>  	/* The correct way to handle this would be to do
>  	 * ip6_route_get_saddr, and then ip6_route_output; however,
>  	 * the route-specific preferred source forces the
> 

LGTM

Acked-by: David Ahern <dsa@cumulusnetworks.com>

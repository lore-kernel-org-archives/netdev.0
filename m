From: Nikolay Aleksandrov via Bridge <bridge@lists.linux-foundation.org>
Subject: Re: [PATCH v2] net: bridge: allow IPv6 when multicast
 flood is disabled
Date: Wed, 1 Mar 2017 13:06:56 +0200
Message-ID: <a72a5648-a7dc-0989-2b31-4581069ceeef@cumulusnetworks.com>
References: <1488362128-15217-1-git-send-email-mmanning@brocade.com>
Reply-To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Mike Manning <mmanning@brocade.com>, netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	"bridge@lists.linux-foundation.org" <bridge@lists.linux-foundation.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1488362128-15217-1-git-send-email-mmanning@brocade.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 01/03/17 11:55, Mike Manning wrote:
> Even with multicast flooding turned off, IPv6 ND should still work so
> that IPv6 connectivity is provided. Allow this by continuing to flood
> multicast traffic originated by us.
> 
> Fixes: b6cb5ac8331b ("net: bridge: add per-port multicast flood flag")
> Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Signed-off-by: Mike Manning <mmanning@brocade.com>
> ---
>  net/bridge/br_forward.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
> index 6bfac29..902af6b 100644
> --- a/net/bridge/br_forward.c
> +++ b/net/bridge/br_forward.c
> @@ -186,8 +186,9 @@ void br_flood(struct net_bridge *br, struct sk_buff *skb,
>  		/* Do not flood unicast traffic to ports that turn it off */
>  		if (pkt_type == BR_PKT_UNICAST && !(p->flags & BR_FLOOD))
>  			continue;
> +		/* Do not flood if mc off, except for traffic we originate */
>  		if (pkt_type == BR_PKT_MULTICAST &&
> -		    !(p->flags & BR_MCAST_FLOOD))
> +		    !(p->flags & BR_MCAST_FLOOD) && skb->dev != br->dev)
>  			continue;
>  
>  		/* Do not flood to ports that enable proxy ARP */
> 

+CC bridge maintainers

Acked-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 3/4] ipv4: add option to drop gratuitous ARP packets
Date: Fri, 10 Apr 2015 15:56:23 +0300
Message-ID: <5527C877.6040700@cogentembedded.com>
References: <1428652454-1224-1-git-send-email-johannes@sipsolutions.net> <1428652454-1224-3-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: matti.gottlieb-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1428652454-1224-3-git-send-email-johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello.

On 4/10/2015 10:54 AM, Johannes Berg wrote:

> From: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

> In certain 802.11 wireless deployments, there will be ARP proxies
> that use knowledge of the network to correctly answer requests.
> To prevent gratuitous ARP frames on the shared medium from being
> a problem, on such deployments wireless needs to drop them.

> Enable this by providing an option called "drop_gratuitous_arp".

> Signed-off-by: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> ---
>   Documentation/networking/ip-sysctl.txt | 6 ++++++
>   include/uapi/linux/ip.h                | 1 +
>   net/ipv4/arp.c                         | 8 ++++++++
>   net/ipv4/devinet.c                     | 2 ++
>   4 files changed, 17 insertions(+)

[...]
> diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
> index 5f5c674e130a..5487d5e5191e 100644
> --- a/net/ipv4/arp.c
> +++ b/net/ipv4/arp.c
> @@ -715,6 +715,14 @@ static int arp_process(struct sk_buff *skb)
>   	    (!IN_DEV_ROUTE_LOCALNET(in_dev) && ipv4_is_loopback(tip)))
>   		goto out;
>
> + /*
> +  *	For some 802.11 wireless deployments (and possibly other networks),
> +  *	there will be an ARP proxy and gratuitous ARP frames are attacks
> +  *	and thus should not be accepted.
> +  */

    Hm, why this strange indentation?

> +	if (IN_DEV_CONF_GET(in_dev, DROP_GRATUITOUS_ARP) && sip == tip)
> +		goto out;
> +
>   /*
>    *     Special case: We must set Frame Relay source Q.922 address
>    */
[...]

WBR, Sergei

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

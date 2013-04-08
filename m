From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 1/3] if.h: add IFF_BRIDGE_RESTRICTED flag
Date: Mon, 8 Apr 2013 11:58:48 -0700
Message-ID: <CAOaVG17nHuoRsf2Kss6LnpgC-Aojcso_zLYyBa18Vn9CGGY+GA@mail.gmail.com>
References: <1365442863-32394-1-git-send-email-antonio@open-mesh.com>
	<1365442863-32394-2-git-send-email-antonio@open-mesh.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	"David S. Miller" <davem@davemloft.net>
To: Antonio Quartulli <antonio@open-mesh.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1365442863-32394-2-git-send-email-antonio@open-mesh.com>
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

The standard way to do this is to use netfilter. Considering the
additional device flags and skb flag changes, I am not sure that your
method is better.

On Mon, Apr 8, 2013 at 10:41 AM, Antonio Quartulli
<antonio@open-mesh.com> wrote:
> This new flag tells whether a network device has to be
> considered as restricted in the new bridge forwarding logic.
>
> Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
> ---
>  include/uapi/linux/if.h | 1 +
>  net/core/dev.c          | 2 +-
>  2 files changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/include/uapi/linux/if.h b/include/uapi/linux/if.h
> index 1ec407b..5c3a9bd 100644
> --- a/include/uapi/linux/if.h
> +++ b/include/uapi/linux/if.h
> @@ -83,6 +83,7 @@
>  #define IFF_SUPP_NOFCS 0x80000         /* device supports sending custom FCS */
>  #define IFF_LIVE_ADDR_CHANGE 0x100000  /* device supports hardware address
>                                          * change when it's running */
> +#define IFF_BRIDGE_RESTRICTED 0x200000 /* device is bridge-restricted */
>
>
>  #define IF_GET_IFACE   0x0001          /* for querying only */
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 3655ff9..49eafc8 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -4627,7 +4627,7 @@ int __dev_change_flags(struct net_device *dev, unsigned int flags)
>
>         dev->flags = (flags & (IFF_DEBUG | IFF_NOTRAILERS | IFF_NOARP |
>                                IFF_DYNAMIC | IFF_MULTICAST | IFF_PORTSEL |
> -                              IFF_AUTOMEDIA)) |
> +                              IFF_AUTOMEDIA | IFF_BRIDGE_RESTRICTED)) |
>                      (dev->flags & (IFF_UP | IFF_VOLATILE | IFF_PROMISC |
>                                     IFF_ALLMULTI));
>
> --
> 1.8.1.5
>

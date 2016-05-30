From: Julian Calaby <julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v2 03/10] nl80211: Prefer ether_addr_copy
Date: Mon, 30 May 2016 15:21:15 +1000
Message-ID: <CAGRGNgVRJm3zSokQ2wxb8Kwd4UEzx7ZjRCHAmnA02cB89Usy-A@mail.gmail.com>
References: <cover.1464576022.git.kirtika.ruchandani@gmail.com> <49c03996365360077fe7317d108072c30354b555.1464576022.git.kirtika.ruchandani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Tina Ruchandani <ruchandani.tina-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Kirtika Ruchandani <kirtika.ruchandani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <49c03996365360077fe7317d108072c30354b555.1464576022.git.kirtika.ruchandani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi All,

On Mon, May 30, 2016 at 12:52 PM, Kirtika Ruchandani
<kirtika.ruchandani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> This patch fixes the checkpatch,pl to prefer ether_addr_copy
> over memcpy.
>
> Signed-off-by: Kirtika Ruchandani <kirtika.ruchandani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

This looks right to me, but doesn't ether_addr_copy() have alignment
requirements? Could someone more familiar with that review these
changes to ensure they're met?

Thanks,

Julian Calaby

> ---
>  net/wireless/nl80211.c | 9 ++++-----
>  1 file changed, 4 insertions(+), 5 deletions(-)
>
> diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
> index cd422bd..34b8fbe 100644
> --- a/net/wireless/nl80211.c
> +++ b/net/wireless/nl80211.c
> @@ -3194,7 +3194,7 @@ static struct cfg80211_acl_data *parse_acl_data(struct wiphy *wiphy,
>                 return ERR_PTR(-ENOMEM);
>
>         nla_for_each_nested(attr, info->attrs[NL80211_ATTR_MAC_ADDRS], tmp) {
> -               memcpy(acl->mac_addrs[i].addr, nla_data(attr), ETH_ALEN);
> +               ether_addr_copy(acl->mac_addrs[i].addr, nla_data(attr));
>                 i++;
>         }
>
> @@ -5892,8 +5892,8 @@ static int nl80211_parse_random_mac(struct nlattr **attrs,
>         if (!attrs[NL80211_ATTR_MAC] || !attrs[NL80211_ATTR_MAC_MASK])
>                 return -EINVAL;
>
> -       memcpy(mac_addr, nla_data(attrs[NL80211_ATTR_MAC]), ETH_ALEN);
> -       memcpy(mac_addr_mask, nla_data(attrs[NL80211_ATTR_MAC_MASK]), ETH_ALEN);
> +       ether_addr_copy(mac_addr, nla_data(attrs[NL80211_ATTR_MAC]));
> +       ether_addr_copy(mac_addr_mask, nla_data(attrs[NL80211_ATTR_MAC_MASK]));
>
>         /* don't allow or configure an mcast address */
>         if (!is_multicast_ether_addr(mac_addr_mask) ||
> @@ -9405,8 +9405,7 @@ static int nl80211_parse_wowlan_tcp(struct cfg80211_registered_device *rdev,
>                 return -ENOMEM;
>         cfg->src = nla_get_in_addr(tb[NL80211_WOWLAN_TCP_SRC_IPV4]);
>         cfg->dst = nla_get_in_addr(tb[NL80211_WOWLAN_TCP_DST_IPV4]);
> -       memcpy(cfg->dst_mac, nla_data(tb[NL80211_WOWLAN_TCP_DST_MAC]),
> -              ETH_ALEN);
> +       ether_addr_copy(cfg->dst_mac, nla_data(tb[NL80211_WOWLAN_TCP_DST_MAC]));
>         if (tb[NL80211_WOWLAN_TCP_SRC_PORT])
>                 port = nla_get_u16(tb[NL80211_WOWLAN_TCP_SRC_PORT]);
>         else
> --
> 2.8.0.rc3.226.g39d4020
>



-- 
Julian Calaby

Email: julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Profile: http://www.google.com/profiles/julian.calaby/
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

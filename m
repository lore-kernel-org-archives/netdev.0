From: Julian Calaby <julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v2 04/10] nl80211: Fix checkpatch.pl warning about braces
Date: Mon, 30 May 2016 15:22:03 +1000
Message-ID: <CAGRGNgUh3Xc6iPKjOrfxKQdGUbFMKPRGSuMEg2M7U9nf7QaszA@mail.gmail.com>
References: <cover.1464576022.git.kirtika.ruchandani@gmail.com> <aef84fd2cf9f2e8fc81b366c83cb38402513f5b1.1464576022.git.kirtika.ruchandani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Tina Ruchandani <ruchandani.tina-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Kirtika Ruchandani <kirtika.ruchandani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <aef84fd2cf9f2e8fc81b366c83cb38402513f5b1.1464576022.git.kirtika.ruchandani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi All,

On Mon, May 30, 2016 at 12:52 PM, Kirtika Ruchandani
<kirtika.ruchandani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> This patch fixes the following checkpatch,pl warning -
> - braces {} should be used on all arms of this statement.
>
> Signed-off-by: Kirtika Ruchandani <kirtika.ruchandani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Looks right to me.

Reviewed-by: Julian Calaby <julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Thanks,

Julian Calaby


> ---
>  net/wireless/nl80211.c | 23 +++++++++++++++--------
>  1 file changed, 15 insertions(+), 8 deletions(-)
>
> diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
> index 34b8fbe..945405d 100644
> --- a/net/wireless/nl80211.c
> +++ b/net/wireless/nl80211.c
> @@ -870,8 +870,9 @@ nl80211_parse_connkeys(struct cfg80211_registered_device *rdev,
>                         result->def = parse.idx;
>                         if (!parse.def_uni || !parse.def_multi)
>                                 goto error;
> -               } else if (parse.defmgmt)
> +               } else if (parse.defmgmt) {
>                         goto error;
> +               }
>                 err = cfg80211_validate_key_settings(rdev, &parse.p,
>                                                      parse.idx, false, NULL);
>                 if (err)
> @@ -1401,8 +1402,9 @@ static int nl80211_send_wiphy(struct cfg80211_registered_device *rdev,
>                         break;
>         case 2:
>                 if (nl80211_put_iftypes(msg, NL80211_ATTR_SUPPORTED_IFTYPES,
> -                                       rdev->wiphy.interface_modes))
> -                               goto nla_put_failure;
> +                                       rdev->wiphy.interface_modes)) {
> +                       goto nla_put_failure;
> +               }
>                 state->split_start++;
>                 if (state->split)
>                         break;
> @@ -2155,8 +2157,9 @@ static int nl80211_set_wiphy(struct sk_buff *skb, struct genl_info *info)
>                 wdev = NULL;
>                 netdev = NULL;
>                 result = 0;
> -       } else
> +       } else {
>                 wdev = netdev->ieee80211_ptr;
> +       }
>
>         /* end workaround code, by now the rdev is available
>          * and locked, and wdev may or may not be NULL.
> @@ -3403,8 +3406,9 @@ static int nl80211_start_ap(struct sk_buff *skb, struct genl_info *info)
>                 if (!nl80211_valid_auth_type(rdev, params.auth_type,
>                                              NL80211_CMD_START_AP))
>                         return -EINVAL;
> -       } else
> +       } else {
>                 params.auth_type = NL80211_AUTHTYPE_AUTOMATIC;
> +       }
>
>         err = nl80211_crypto_settings(rdev, info, &params.crypto,
>                                       NL80211_MAX_NR_CIPHER_SUITES);
> @@ -3450,8 +3454,9 @@ static int nl80211_start_ap(struct sk_buff *skb, struct genl_info *info)
>                         return err;
>         } else if (wdev->preset_chandef.chan) {
>                 params.chandef = wdev->preset_chandef;
> -       } else if (!nl80211_get_ap_channel(rdev, &params))
> +       } else if (!nl80211_get_ap_channel(rdev, &params)) {
>                 return -EINVAL;
> +       }
>
>         if (!cfg80211_reg_can_beacon_relax(&rdev->wiphy, &params.chandef,
>                                            wdev->iftype))
> @@ -7262,8 +7267,9 @@ static int nl80211_crypto_settings(struct cfg80211_registered_device *rdev,
>                         return -EINVAL;
>                 if (info->attrs[NL80211_ATTR_CONTROL_PORT_NO_ENCRYPT])
>                         settings->control_port_no_encrypt = true;
> -       } else
> +       } else {
>                 settings->control_port_ethertype = cpu_to_be16(ETH_P_PAE);
> +       }
>
>         if (info->attrs[NL80211_ATTR_CIPHER_SUITES_PAIRWISE]) {
>                 void *data;
> @@ -7997,8 +8003,9 @@ static int nl80211_connect(struct sk_buff *skb, struct genl_info *info)
>                 if (!nl80211_valid_auth_type(rdev, connect.auth_type,
>                                              NL80211_CMD_CONNECT))
>                         return -EINVAL;
> -       } else
> +       } else {
>                 connect.auth_type = NL80211_AUTHTYPE_AUTOMATIC;
> +       }
>
>         connect.privacy = info->attrs[NL80211_ATTR_PRIVACY];
>
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

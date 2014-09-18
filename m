From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net v2 1/2] genetlink: add function genl_has_listeners()
Date: Thu, 18 Sep 2014 10:11:38 -0700
Message-ID: <CALnjE+rwpFtfd5PsX+Ohzohvst7xuEndS6tfTdMTbgdTjGntsw@mail.gmail.com>
References: <CALnjE+qqv66Zkh==bJAxBSUEkh8H-9YMnox1yF+4_BwetqERmg@mail.gmail.com>
	<1411029064-15376-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog110.obsmtp.com ([74.125.149.203]:56927 "HELO
	na3sys009aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756296AbaIRRLj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 13:11:39 -0400
Received: by mail-ig0-f176.google.com with SMTP id hn15so2528100igb.3
        for <netdev@vger.kernel.org>; Thu, 18 Sep 2014 10:11:39 -0700 (PDT)
In-Reply-To: <1411029064-15376-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 18, 2014 at 1:31 AM, Nicolas Dichtel
<nicolas.dichtel@6wind.com> wrote:
> This function is the counterpart of the function netlink_has_listeners().
>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Looks good.
Acked-by: Pravin B Shelar <pshelar@nicira.com>

> ---
>
> v2: add patch 1/2
>
>  include/net/genetlink.h | 8 ++++++++
>  1 file changed, 8 insertions(+)
>
> diff --git a/include/net/genetlink.h b/include/net/genetlink.h
> index 93695f0e22a5..af10c2cf8a1d 100644
> --- a/include/net/genetlink.h
> +++ b/include/net/genetlink.h
> @@ -394,4 +394,12 @@ static inline int genl_set_err(struct genl_family *family, struct net *net,
>         return netlink_set_err(net->genl_sock, portid, group, code);
>  }
>
> +static inline int genl_has_listeners(struct genl_family *family,
> +                                    struct sock *sk, unsigned int group)
> +{
> +       if (WARN_ON_ONCE(group >= family->n_mcgrps))
> +               return -EINVAL;
> +       group = family->mcgrp_offset + group;
> +       return netlink_has_listeners(sk, group);
> +}
>  #endif /* __NET_GENERIC_NETLINK_H */
> --
> 2.1.0
>

From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [patch net-next] ipv6: addrconf: implement address generation
 modes
Date: Fri, 11 Jul 2014 18:16:07 +0900
Message-ID: <53BFAB57.10700@miraclelinux.com>
References: <1405066774-11740-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, sfeldma@cumulusnetworks.com,
	arvid.brodin@alten.se, sucheta.chakraborty@qlogic.com,
	hannes@stressinduktion.org
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og111.obsmtp.com ([64.18.2.175]:32867 "HELO
	exprod7og111.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751402AbaGKJQL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2014 05:16:11 -0400
Received: by mail-pd0-f175.google.com with SMTP id v10so1083851pde.20
        for <netdev@vger.kernel.org>; Fri, 11 Jul 2014 02:16:11 -0700 (PDT)
In-Reply-To: <1405066774-11740-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Jiri Pirko wrote:
> This patch introduces a possibility for userspace to set various (so far
> two) modes of generating addresses. This is useful for example for
> NetworkManager because it can set the mode to NONE and take care of link
> local addresses itself. That allow it to have the interface up,
> monitoring carrier but still don't have any addresses on it.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>   include/net/if_inet6.h       |  1 +
>   include/uapi/linux/if_link.h |  6 +++++
>   net/ipv6/addrconf.c          | 56 ++++++++++++++++++++++++++++++--------------
>   3 files changed, 45 insertions(+), 18 deletions(-)
> 
> diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
> index b4956a5..f82b281 100644
> --- a/include/net/if_inet6.h
> +++ b/include/net/if_inet6.h
> @@ -206,6 +206,7 @@ struct inet6_dev {
>   	__u8			rs_probes;
>   
>   	unsigned long		tstamp; /* ipv6InterfaceTable update timestamp */
> +	enum in6_addr_gen_mode	addr_gen_mode;

How about putting this as __u8 after dad_probes?

> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 358edd2..2c75ec1 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -2730,9 +2730,25 @@ static void addrconf_add_linklocal(struct inet6_dev *idev, const struct in6_addr
>   	}
>   }
>   
> +static void addr_conf_addr_gen(struct inet6_dev *idev, bool prefix_route)

s/addr_conf/addrconf/

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION

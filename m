From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next] net: dsa: change tag_protocol to an enum
Date: Thu, 11 Sep 2014 17:46:07 -0700
Message-ID: <5412424F.3050701@gmail.com>
References: <1410461842-15792-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kernel@wantstofly.org
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:58978 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751927AbaILAqJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2014 20:46:09 -0400
Received: by mail-pd0-f172.google.com with SMTP id v10so10940pde.3
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2014 17:46:08 -0700 (PDT)
In-Reply-To: <1410461842-15792-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/11/2014 11:57 AM, Florian Fainelli wrote:
> Now that we introduced an additional multiplexing/demultiplexing layer
> with commit 3e8a72d1dae37 ("net: dsa: reduce number of protocol hooks")
> that lives within the DSA code, we no longer need to have a given switch
> driver tag_protocol be an actual ethertype value, instead, we can
> replace it with an enum: dsa_tag_protocol.
>
> Do this replacement in the drivers, which allows us to get rid of the
> cpu_to_be16()/htons() dance, and remove ETH_P_BRCMTAG since we do not
> need it anymore.
>
> Suggested-by: Alexander Duyck <alexander.duyck@gmail.com>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  drivers/net/dsa/bcm_sf2.c         |  2 +-
>  drivers/net/dsa/mv88e6060.c       |  2 +-
>  drivers/net/dsa/mv88e6123_61_65.c |  4 ++--
>  drivers/net/dsa/mv88e6131.c       |  2 +-
>  include/net/dsa.h                 | 14 ++++++++++----
>  net/dsa/slave.c                   |  8 ++++----
>  net/dsa/tag_brcm.c                |  1 -
>  7 files changed, 19 insertions(+), 14 deletions(-)

[...]

> diff --git a/include/net/dsa.h b/include/net/dsa.h
> index 97712927a9d2..3e88b4ad274f 100644
> --- a/include/net/dsa.h
> +++ b/include/net/dsa.h
> @@ -22,7 +22,13 @@
>  /* Not an official ethertype value, used only internally for DSA
>   * demultiplexing
>   */
> -#define ETH_P_BRCMTAG		(ETH_P_XDSA + 1)
> +enum dsa_tag_protocol {
> +	DSA_TAG_PROTO_NONE = 0,
> +	DSA_TAG_PROTO_DSA,
> +	DSA_TAG_PROTO_TRAILER,
> +	DSA_TAG_PROTO_EDSA,
> +	DSA_TAG_PROTO_BRCM,
> +};
>  
>  #define DSA_MAX_SWITCHES	4
>  #define DSA_MAX_PORTS		12

You might want to either remove or update the comment as well.  Defining
the enum with a comment about ethertype value might be a bit confusing.

Other than that it looks okay to me.

Thanks,

ALex

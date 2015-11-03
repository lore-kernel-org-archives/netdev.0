From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH v2 net-next] net/core: generic support for disabling
 netdev features down stack
Date: Tue, 3 Nov 2015 11:03:09 +0100
Message-ID: <5638865D.2000804@cumulusnetworks.com>
References: <1446486818-26166-1-git-send-email-jarod@redhat.com>
 <1446519359-21400-1-git-send-email-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Nikolay Aleksandrov <razor@blackwall.org>,
	Michal Kubecek <mkubecek@suse.cz>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	netdev@vger.kernel.org
To: Jarod Wilson <jarod@redhat.com>, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:32905 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751266AbbKCKDM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 05:03:12 -0500
Received: by wmeg8 with SMTP id g8so79964400wme.0
        for <netdev@vger.kernel.org>; Tue, 03 Nov 2015 02:03:11 -0800 (PST)
In-Reply-To: <1446519359-21400-1-git-send-email-jarod@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/03/2015 03:55 AM, Jarod Wilson wrote:
[snip]
>  
> +#define for_each_netdev_feature(mask_addr, feature)				\
> +	int bit;								\
> +	for_each_set_bit(bit, (unsigned long *)mask_addr, NETDEV_FEATURE_COUNT)	\
> +		feature = __NETIF_F_BIT(bit);
> +
^
This is broken, it will not work for more than a single feature.

>  /* Features valid for ethtool to change */
>  /* = all defined minus driver/device-class-related */
>  #define NETIF_F_NEVER_CHANGE	(NETIF_F_VLAN_CHALLENGED | \
> @@ -167,6 +172,12 @@ enum {
>   */
>  #define NETIF_F_ALL_FOR_ALL	(NETIF_F_NOCACHE_COPY | NETIF_F_FSO)
>  
> +/*
> + * If upper/master device has these features disabled, they must be disabled
> + * on all lower/slave devices as well.
> + */
> +#define NETIF_F_UPPER_DISABLES	NETIF_F_LRO
> +
[snip]

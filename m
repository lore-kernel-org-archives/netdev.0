From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 3/3] cfg80211: add MPLS and 802.21 classification
Date: Wed, 12 Feb 2014 03:49:43 -0800
Message-ID: <1392205783.1868.5.camel@joe-AO722>
References: <1392202386-8826-1-git-send-email-sw@simonwunderlich.de>
	 <1392202386-8826-4-git-send-email-sw@simonwunderlich.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-wireless@vger.kernel.org,
	mathias.kretschmer@fokus.fraunhofer.de
To: Simon Wunderlich <sw@simonwunderlich.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0001.hostedemail.com ([216.40.44.1]:58695 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751562AbaBLLtr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 06:49:47 -0500
In-Reply-To: <1392202386-8826-4-git-send-email-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-02-12 at 11:53 +0100, Simon Wunderlich wrote:
> MPLS labels may contain traffic control information, which should be
> evaluated and used by the wireless subsystem if present.

trivial notes:

> diff --git a/net/wireless/util.c b/net/wireless/util.c
[]
> @@ -11,6 +11,7 @@
>  #include <net/ip.h>
>  #include <net/dsfield.h>
>  #include <linux/if_vlan.h>
> +#include <uapi/linux/mpls.h>

Please try not to #include uapi files.

> @@ -710,6 +711,29 @@ unsigned int cfg80211_classify8021d(struct sk_buff *skb,
>  			return vlan_priority;
>  	}
>  
> +	if (skb_headlen(skb) >= sizeof(struct ethhdr)) {
> +		struct ethhdr *eh = (struct ethhdr *) skb->data;
> +		struct mpls_label_stack mpls_tmp, *mpls;
> +
> +		switch (eh->h_proto) {
> +		case __constant_htons(ETH_P_MPLS_UC):
> +		case __constant_htons(ETH_P_MPLS_MC):

__constant_ isn't necessary for these labels.

>  	switch (skb->protocol) {
>  	case htons(ETH_P_IP):
>  		dscp = ipv4_get_dsfield(ip_hdr(skb)) & 0xfc;

like this, just case htons(ETH_<FOO>) is enough.

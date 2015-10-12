From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next V15 2/3] Check for vlan ethernet types for 8021.q
 or 802.1ad
Date: Mon, 12 Oct 2015 16:52:07 +0300
Message-ID: <561BBB07.1040202@cogentembedded.com>
References: <1444520433-1958-1-git-send-email-thomasfherbert@gmail.com>
 <1444520433-1958-3-git-send-email-thomasfherbert@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: therbert@redhat.com, dev@openvswitch.org
To: Thomas F Herbert <thomasfherbert@gmail.com>,
	netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:36432 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752262AbbJLNwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 09:52:08 -0400
Received: by lbcao8 with SMTP id ao8so143872079lbc.3
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 06:52:06 -0700 (PDT)
In-Reply-To: <1444520433-1958-3-git-send-email-thomasfherbert@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 10/11/2015 2:40 AM, Thomas F Herbert wrote:

> Signed-off-by: Thomas F Herbert <thomasfherbert@gmail.com>
> ---
>   include/linux/if_vlan.h | 17 +++++++++++++++++
>   1 file changed, 17 insertions(+)
>
> diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
> index 67ce5bd..88d1be4 100644
> --- a/include/linux/if_vlan.h
> +++ b/include/linux/if_vlan.h
> @@ -627,6 +627,23 @@ static inline netdev_features_t vlan_features_check(const struct sk_buff *skb,
>
>   	return features;
>   }
> +/**
> + * eth_type_vlan - check for valid vlan ether type.
> + * @ethertype: ether type to check
> + *
> + * Returns true if the ether type is a vlan ether type.
> + */
> +static inline bool eth_type_vlan(__be16 ethertype)
> +{
> +	switch (ethertype) {
> +	case (htons(ETH_P_8021Q)):
> +		return true;
> +	case (htons(ETH_P_8021AD)):
> +		return true;

    I'm not sure if I've already suggested that or not but why not merge these 
2 cases?

> +	default:
> +		return false;
> +	}
> +}

[...]

MBR, Sergei

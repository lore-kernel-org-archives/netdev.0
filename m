From: Albino B Neto <bino@bino.us>
Subject: Re: [PATCH net-next V17 2/3] Check for vlan ethernet types for 8021.q
 or 802.1ad
Date: Mon, 26 Oct 2015 10:14:43 -0200
Message-ID: <CAMu38xJ4UhALjFn05emEZSA0pBHtqsA13YyR7N2J0VeytO6sUw@mail.gmail.com>
References: <1445818286-4870-1-git-send-email-thomasfherbert@gmail.com>
	<1445818286-4870-3-git-send-email-thomasfherbert@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, pshelar@nicira.com, therbert@redhat.com,
	dev@openvswitch.org
To: Thomas F Herbert <thomasfherbert@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway30.websitewelcome.com ([50.116.126.1]:51178 "EHLO
	gateway30.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753664AbbJZMgd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 08:36:33 -0400
Received: from ham07.websitewelcome.com (unknown [192.185.81.79])
	by gateway30.websitewelcome.com (Postfix) with ESMTP id 61FBD37F06C40
	for <netdev@vger.kernel.org>; Mon, 26 Oct 2015 07:14:44 -0500 (CDT)
Received: from br538.hostgator.com.br (br538.hostgator.com.br [108.179.252.175])
	by ham07.websitewelcome.com (Postfix) with ESMTP id 1E263660006
	for <netdev@vger.kernel.org>; Mon, 26 Oct 2015 07:14:44 -0500 (CDT)
Received: from [209.85.192.51] (port=34780 helo=mail-qg0-f51.google.com)
	by br538.hostgator.com.br with esmtpsa (TLSv1.2:AES128-GCM-SHA256:128)
	(Exim 4.85)
	(envelope-from <bino@bino.us>)
	id 1Zqgfj-0003bd-VM
	for netdev@vger.kernel.org; Mon, 26 Oct 2015 07:14:44 -0500
Received: by qgem9 with SMTP id m9so116915846qge.1
        for <netdev@vger.kernel.org>; Mon, 26 Oct 2015 05:14:43 -0700 (PDT)
In-Reply-To: <1445818286-4870-3-git-send-email-thomasfherbert@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-10-25 22:11 GMT-02:00 Thomas F Herbert <thomasfherbert@gmail.com>:
> Signed-off-by: Thomas F Herbert <thomasfherbert@gmail.com>
> ---
>  include/linux/if_vlan.h | 16 ++++++++++++++++
>  1 file changed, 16 insertions(+)
>
> diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
> index 67ce5bd..d2494b5 100644
> --- a/include/linux/if_vlan.h
> +++ b/include/linux/if_vlan.h
> @@ -627,6 +627,22 @@ static inline netdev_features_t vlan_features_check(const struct sk_buff *skb,
>
>         return features;
>  }
> +/**
> + * eth_type_vlan - check for valid vlan ether type.
> + * @ethertype: ether type to check
> + *
> + * Returns true if the ether type is a vlan ether type.
> + */
> +static inline bool eth_type_vlan(__be16 ethertype)
> +{
> +       switch (ethertype) {
> +       case htons(ETH_P_8021Q):
> +       case htons(ETH_P_8021AD):
> +               return true;
> +       default:
> +               return false;
> +       }
> +}
>
>  /**
>   * compare_vlan_header - Compare two vlan headers

Description ?

   Albino

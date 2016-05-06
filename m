From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH v9 net-next 7/7] openvswitch: use ipgre tunnel rather
 than gretap tunnel
Date: Fri, 6 May 2016 11:15:11 +0200
Message-ID: <20160506111511.5eecb505@griffin>
References: <1462347393-22354-1-git-send-email-simon.horman@netronome.com>
	<1462347393-22354-8-git-send-email-simon.horman@netronome.com>
	<CAOrHB_BAFuZjoUgza9n8g1pborjCsYAC0DU4cXsff_9q9Cp+Fg@mail.gmail.com>
	<20160506065400.GA15277@penelope.isobedori.kobe.vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pravin shelar <pshelar@ovn.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	ovs dev <dev@openvswitch.org>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39006 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751874AbcEFJPQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 May 2016 05:15:16 -0400
In-Reply-To: <20160506065400.GA15277@penelope.isobedori.kobe.vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 6 May 2016 15:54:02 +0900, Simon Horman wrote:
> -int ovs_netdev_send_raw_tun(struct sk_buff *skb)
> -{
> -	if (skb->mac_len)
> -		skb->protocol = ntohs(ETH_P_TEB);
> +	if (dev->type != ARPHRD_ETHER && skb->mac_len) {
> +		skb->protocol = htons(ETH_P_TEB);
> +	} else if (dev->type == ARPHRD_ETHER && !skb->mac_len) {
> +		kfree_skb(skb);
> +		return -EINVAL;
> +	}

This was something I was missing in your patches (sorry, did not get to
the full review yet).

You'll also need to enable ARPHRD_NONE and ARPHRD_IPGRE interfaces in
ovs_netdev_link.

 Jiri

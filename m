From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next] vxlan: revert "vxlan: Bypass encapsulation if
 the destination is local"
Date: Fri, 12 Apr 2013 04:05:52 -0400 (EDT)
Message-ID: <1968568728.2717792.1365753952925.JavaMail.root@redhat.com>
References: <1365501445-9712-1-git-send-email-amwang@redhat.com> <1365530913.29336.50.camel@oc1677441337.ibm.com> <1365646215.25993.3.camel@cr0> <516641CF.4020101@us.ibm.com> <1937058599.2214531.1365659704193.JavaMail.root@redhat.com> <1365724799.3563.5.camel@sridhar.usor.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3-phx2.redhat.com ([209.132.183.24]:51586 "EHLO
	mx3-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754541Ab3DLIGt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 04:06:49 -0400
In-Reply-To: <1365724799.3563.5.camel@sridhar.usor.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



----- Original Message -----
> 
> The following patch fixes the issue for me. can you try it out?
> 
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 9a64715..d6509de 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -1013,7 +1013,7 @@ static netdev_tx_t vxlan_xmit_one(struct sk_buff *skb,
> struct net_device *dev,
>  	}
>  
>  	/* Bypass encapsulation if the destination is local */
> -	if (rt->rt_flags & RTCF_LOCAL) {
> +	if (rt->dst.dev->flags & IFF_LOOPBACK) {
>  		struct vxlan_dev *dst_vxlan;
>  
>  		ip_rt_put(rt);
> 

It almost surely can fix the problem, but do you really just want to bypass
encap for loopback devcie? Not all local devices?

The title of your original commit "vxlan: Bypass encapsulation if the destination is local"
is confusing...

(Sorry for the delay, I am on vacation.)

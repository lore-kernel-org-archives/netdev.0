From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH net 5/6] openvswitch: Fix vport_send double free
Date: Wed, 24 Dec 2014 04:16:01 +0100
Message-ID: <549A2FF1.2080300@gmx.de>
References: <1419380432-1665-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.19]:53733 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751667AbaLXDQH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Dec 2014 22:16:07 -0500
In-Reply-To: <1419380432-1665-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 24.12.2014 01:20, Pravin B Shelar wrote:
l_hlen = ip_gre_calc_hlen(tun_key->tun_flags);
>  
> @@ -183,8 +185,9 @@ static int gre_tnl_send(struct vport *vport, struct sk_buff *skb)
>  
>  	/* Push Tunnel header. */
>  	skb = __build_header(skb, tunnel_hlen);
> -	if (unlikely(!skb)) {
> -		err = 0;
> +	if (IS_ERR(skb)) {
> +		err = PTR_ERR(rt);

Shouldn't be it

err = PTR_ERR(skb); ?

Regards,
Lino

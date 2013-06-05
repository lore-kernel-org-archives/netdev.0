From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next 02/10] vxlan: handle skb_clone failure
Date: Wed, 5 Jun 2013 06:59:56 +0000 (UTC)
Message-ID: <komnlc$ma8$2@ger.gmane.org>
References: <1370406254-6341-1-git-send-email-stephen@networkplumber.org>
 <1370406254-6341-2-git-send-email-stephen@networkplumber.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:52310 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752388Ab3FEHAO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jun 2013 03:00:14 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1Uk7hc-0003XB-MI
	for netdev@vger.kernel.org; Wed, 05 Jun 2013 09:00:12 +0200
Received: from 60.160.70.221 ([60.160.70.221])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 05 Jun 2013 09:00:12 +0200
Received: from xiyou.wangcong by 60.160.70.221 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 05 Jun 2013 09:00:12 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 05 Jun 2013 at 04:24 GMT, Stephen Hemminger <stephen@networkplumber.org> wrote:
>  		skb1 = skb_clone(skb, GFP_ATOMIC);
> -		rc1 = vxlan_xmit_one(skb1, dev, rdst, did_rsc);
> -		if (rc == NETDEV_TX_OK)
> -			rc = rc1;
> +		if (skb1) {
> +			rc1 = vxlan_xmit_one(skb1, dev, rdst, did_rsc);
> +			if (rc == NETDEV_TX_OK)
> +				rc = rc1;
> +		}

If OOM, shouldn't we exit immediately instead of continue handle the
next one?

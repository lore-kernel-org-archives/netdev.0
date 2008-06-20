From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 6/8] ipv4: Check return of dev_set_allmulti
Date: Thu, 19 Jun 2008 19:09:21 -0700 (PDT)
Message-ID: <20080619.190921.177438602.davem@davemloft.net>
References: <485B0004.9020108@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33161
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751135AbYFTCJW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 22:09:22 -0400
In-Reply-To: <485B0004.9020108@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Fri, 20 Jun 2008 08:55:32 +0800

> @@ -435,7 +436,10 @@ static int vif_add(struct vifctl *vifc, int mrtsock)
>  	if ((in_dev = __in_dev_get_rtnl(dev)) == NULL)
>  		return -EADDRNOTAVAIL;
>  	IPV4_DEVCONF(in_dev->cnf, MC_FORWARDING)++;
> -	dev_set_allmulti(dev, +1);
> +	/* Check whether allmulti overflow */
> +	err = dev_set_allmulti(dev, 1);
> +	if (err)
> +		return err;

Please delete comment.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] veth: Configurable nterface MTU
Date: Fri, 27 Feb 2009 02:49:16 -0800 (PST)
Message-ID: <20090227.024916.184944062.davem@davemloft.net>
References: <m1ljrtkavi.fsf@fess.ebiederm.org>
	<m1fxi1kasv.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.osdl.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33859
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751978AbZB0Ktf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 05:49:35 -0500
In-Reply-To: <m1fxi1kasv.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Wed, 25 Feb 2009 21:49:04 -0800

> @@ -249,6 +253,19 @@ static int veth_close(struct net_device *dev)
>  	return 0;
>  }
>  
> +static int is_valid_veth_mtu(int new_mtu)
> +{
> +	return (new_mtu >= MIN_MTU && new_mtu <= MAX_MTU);
> +}
> +
> +static int veth_change_mtu(struct net_device *dev, int new_mtu)
> +{
> +	if (is_valid_veth_mtu(new_mtu))
> +		return -EINVAL;
> +	dev->mtu = new_mtu;
> +	return 0;
> +}
> +

This validity test seems to be reversed?


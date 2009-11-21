From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 3/3] netxen : fix BOND_MODE_TLB/ALB mode.
Date: Fri, 20 Nov 2009 21:48:20 -0800 (PST)
Message-ID: <20091120.214820.259339697.davem@davemloft.net>
References: <1258765774-27068-1-git-send-email-amit@netxen.com>
	<1258765774-27068-4-git-send-email-amit@netxen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com,
	narender.kumar@qlogic.com, amit.salecha@qlogic.com
To: amit@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33486
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750796AbZKUFsD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2009 00:48:03 -0500
In-Reply-To: <1258765774-27068-4-git-send-email-amit@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit@netxen.com>
Date: Fri, 20 Nov 2009 17:09:34 -0800

> @@ -437,6 +437,7 @@ netxen_read_mac_addr(struct netxen_adapter *adapter)
>  		netdev->dev_addr[i] = *(p + 5 - i);
>  
>  	memcpy(netdev->perm_addr, netdev->dev_addr, netdev->addr_len);
> +	memcpy(adapter->mac_addr, netdev->dev_addr, netdev->addr_len);
>  
>  	/* set station address */
>  

I don't think this is correct.

You have to maintain a valid netdev->perm_addr even if you don't use
that value later on internally.  This is how the permanent, probed,
MAC address of the card is made available to the user.

Second of all, it is not clear at all why you need to maintain this
value internally.  Why does it not work to simply use
netdev->dev_addr?

Whatever the reason, you need to explain the details of this in your
commit message.

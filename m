From: Jim Baxter <jim_baxter@mentor.com>
Subject: Re: [PATCH net-next v3 1/1] net: fec: Enable imx6 enet checksum acceleration.
Date: Thu, 18 Apr 2013 11:18:46 +0100
Message-ID: <516FC886.7040303@mentor.com>
References: <jim_baxter@mentor.com> <1366229278-7528-1-git-send-email-jim_baxter@mentor.com> <20130417224526.GA15093@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Fugang Duan <B38611@freescale.com>, <netdev@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.mentorg.com ([192.94.38.131]:65528 "EHLO
	relay1.mentorg.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030295Ab3DRKSv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 06:18:51 -0400
In-Reply-To: <20130417224526.GA15093@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thank you for you comments, I will fix the issues.
One question below:

On 17/04/13 23:45, Francois Romieu wrote:
>> +static int fec_set_features(struct net_device *netdev,
>> +	netdev_features_t features)
>> +{
>> +	struct fec_enet_private *fep = netdev_priv(netdev);
>> +	netdev_features_t changed = features ^ netdev->features;
>> +	bool restart_required = false;
>> +
>> +	netdev->features = features;
>> +
>> +	/* Receive checksum has been changed */
>> +	if (changed & NETIF_F_RXCSUM) {
>> +		restart_required = true;
>> +		if (features & NETIF_F_RXCSUM)
>> +			fep->csum_flags |= FLAG_RX_CSUM_ENABLED;
>> +		else
>> +			fep->csum_flags &= ~FLAG_RX_CSUM_ENABLED;
> 
> ---(snip)----8<------------------------------------------------
> 
>> +	}
>> +
>> +	/* Restart the network interface */
>> +	if (true == restart_required) {
> 
> ---(snip)--------------------------------------->8-------------
> 
> Then remove the "restart_required" variable ?
> 
What you mean by remove the "restart_required" variable, I only want a
restart in certain situations? Am I misunderstanding you comment?

Jim

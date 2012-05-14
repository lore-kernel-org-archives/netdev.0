From: "Shimoda, Yoshihiro" <yoshihiro.shimoda.uh@renesas.com>
Subject: Re: [PATCH v2 4/5] net: sh_eth: add support for
 set_ringparam/get_ringparam
Date: Mon, 14 May 2012 15:13:50 +0900
Message-ID: <4FB0A29E.1070709@renesas.com>
References: <4FACD005.3010800@renesas.com>
 <1336750030.2874.65.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	SH-Linux <linux-sh@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-reply-to: <1336750030.2874.65.camel@bwh-desktop.uk.solarflarecom.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2012/05/12 0:27, Ben Hutchings wrote:
> On Fri, 2012-05-11 at 17:38 +0900, Shimoda, Yoshihiro wrote:
>> This patch supports the ethtool's set_ringparam() and get_ringparam().
> [...]
>> +static int sh_eth_set_ringparam(struct net_device *ndev,
>> +				struct ethtool_ringparam *ring)
>> +{
< snip >
>> +	if (netif_running(ndev)) {
>> +		/* Disable interrupts by clearing the interrupt mask. */
>> +		sh_eth_write(ndev, 0x0000, EESIPR);
>> +		/* Stop the chip's Tx and Rx processes. */
>> +		sh_eth_write(ndev, 0, EDTRR);
>> +		sh_eth_write(ndev, 0, EDRRR);
> 
> You'll also need to call netif_tx_disable() and synchronize_irq().

Thank you for the point. I will fix it.

>> +	sh_eth_ring_init(ndev);
>> +	sh_eth_dev_init(ndev);
> 
> And what if either of these fails?

Oh, I should have added error handling.
I checked this driver, and I found that the driver should change
the value of the pointer to NULL. So, I will submit such a patch first.

>> +	if (netif_running(ndev)) {
>> +		sh_eth_write(ndev, mdp->cd->eesipr_value, EESIPR);
>> +		/* Setting the Rx mode will start the Rx process. */
>> +		sh_eth_write(ndev, EDRRR_R, EDRRR);
> 
> You'll need to call netif_wake_queue().

I will fix it.

>> +	}
>> +
>> +	return 0;
>> +}
> [...]
> 
> Ben.
> 

Best regards,
Yoshihiro Shimoda

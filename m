From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 6/8] net: ethernet: annapurna: add wol helpers to
 the Alpine driver
Date: Mon, 6 Feb 2017 15:02:52 +0300
Message-ID: <b83bc8ad-7f16-5757-b629-be296046ca1e@cogentembedded.com>
References: <20170203181216.30214-1-antoine.tenart@free-electrons.com>
 <20170203181216.30214-7-antoine.tenart@free-electrons.com>
 <08b62752-8bb2-4633-c44f-74eb585e7e52@cogentembedded.com>
 <063D6719AE5E284EB5DD2968C1650D6DB027C6C3@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "tsahee@annapurnalabs.com" <tsahee@annapurnalabs.com>,
        "rshitrit@annapurnalabs.com" <rshitrit@annapurnalabs.com>,
        "saeed@annapurnalabs.com" <saeed@annapurnalabs.com>,
        "barak@annapurnalabs.com" <barak@annapurnalabs.com>,
        "talz@annapurnalabs.com" <talz@annapurnalabs.com>,
        "thomas.petazzoni@free-electrons.com"
        <thomas.petazzoni@free-electrons.com>,
        "arnd@arndb.de" <arnd@arndb.de>
To: David Laight <David.Laight@ACULAB.COM>,
        Antoine Tenart <antoine.tenart@free-electrons.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:36754 "EHLO
        mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751617AbdBFMC5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 07:02:57 -0500
Received: by mail-lf0-f50.google.com with SMTP id z134so43338995lff.3
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 04:02:56 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB027C6C3@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/06/2017 02:35 PM, David Laight wrote:

>>> Implement the get_wol() and set_wol() helpers in the Annapurna Labs
>>> Alpine Ethernet driver.
>>> ---
>>>  drivers/net/ethernet/annapurna/al_eth.c | 44 +++++++++++++++++++++++++++++++++
>>>  1 file changed, 44 insertions(+)
>>>
>>> diff --git a/drivers/net/ethernet/annapurna/al_eth.c b/drivers/net/ethernet/annapurna/al_eth.c
>>> index 8dd84f66b5d1..d06a75a49ce5 100644
>>> --- a/drivers/net/ethernet/annapurna/al_eth.c
>>> +++ b/drivers/net/ethernet/annapurna/al_eth.c
>>> @@ -2519,10 +2519,54 @@ static u32 al_eth_get_rxfh_indir_size(struct net_device *netdev)
>>>  	return AL_ETH_RX_RSS_TABLE_SIZE;
>>>  }
>>>
>>> +static void al_eth_get_wol(struct net_device *netdev,
>>> +			   struct ethtool_wolinfo *wol)
>>> +{
>>> +	struct al_eth_adapter *adapter = netdev_priv(netdev);
>>> +	struct phy_device *phydev;
>>> +
>>> +	wol->wolopts = adapter->wol;
>>> +
>>> +	if ((adapter) && (adapter->phy_exist) && (adapter->mdio_bus)) {
>>
>>     Now that's somewhat stupid looking... does the whole driver use this "style"?
>
> Not only that, in one of the two functions it is followed by:
>
> +	device_set_wakeup_enable(&adapter->pdev->dev, adapter->wol);

> Which assumes that 'adapter' is not NULL.
> Some verifiers will detect that as a possible NULL pointer dereference.

    I only meant unneeded parens. :-)

[...]

> 	David

MBR, Sergei

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] nfp: add VLAN filtering support
Date: Thu, 15 Jun 2017 10:46:45 -0400 (EDT)
Message-ID: <20170615.104645.2226445663454733772.davem@davemloft.net>
References: <20170615062307.10153-1-jakub.kicinski@netronome.com>
        <BLUPR0701MB2004A321103E707B6F6A63918DC00@BLUPR0701MB2004.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: jakub.kicinski@netronome.com, netdev@vger.kernel.org,
        oss-drivers@netronome.com, pablo.cascon@netronome.com
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53668 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751677AbdFOOqt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 10:46:49 -0400
In-Reply-To: <BLUPR0701MB2004A321103E707B6F6A63918DC00@BLUPR0701MB2004.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Date: Thu, 15 Jun 2017 12:50:57 +0000

>> From: Pablo Cascón <pablo.cascon@netronome.com>
>> 
>> Add general use per-vNIC mailbox area and use it for VLAN filtering support.
>> Initially proto is hardcoded to 802.1q.
>> 
> ...
>> +static int
>> +nfp_net_vlan_rx_add_vid(struct net_device *netdev, __be16 proto, u16
>> +vid) {
>> +	struct nfp_net *nn = netdev_priv(netdev);
>> +
>> +	/* Priority tagged packets with vlan id 0 are processed by the
>> +	 * NFP as untagged packets
>> +	 */
>> +	if (!vid)
>> +		return 0;
>> +
>> +	nn_writew(nn, NFP_NET_CFG_VLAN_FILTER_VID, vid);
>> +	nn_writew(nn, NFP_NET_CFG_VLAN_FILTER_PROTO, ETH_P_8021Q);
> 
> If it's hard-coded, don't you want to fail the request in case proto is different?

Agreed.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 5/7] Driver: Vmxnet3: Add support for
 get_coalesce, set_coalesce ethtool operations
Date: Sat, 07 May 2016 13:41:29 -0400 (EDT)
Message-ID: <20160507.134129.1982381481875075081.davem@davemloft.net>
References: <1462576336-83513-1-git-send-email-skhare@vmware.com>
	<1462576336-83513-6-git-send-email-skhare@vmware.com>
	<1462622686.19332.33.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: skhare@vmware.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, pv-drivers@vmware.com,
	sunk@vmware.com, tammalim@vmware.com
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34610 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750884AbcEGRlb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2016 13:41:31 -0400
In-Reply-To: <1462622686.19332.33.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ben Hutchings <ben@decadent.org.uk>
Date: Sat, 07 May 2016 13:04:46 +0100

> On Fri, 2016-05-06 at 16:12 -0700, Shrikrishna Khare wrote:
> [...]
>> +static int
>> +vmxnet3_set_coalesce(struct net_device *netdev, struct ethtool_coal=
esce *ec)
>> +{
> [...]
>> +	switch (ec->rx_coalesce_usecs) {
>> +	case VMXNET3_COALESCE_DEFAULT:
>> +	case VMXNET3_COALESCE_DISABLED:
>> +	case VMXNET3_COALESCE_ADAPT:
>> +		if (ec->tx_max_coalesced_frames ||
>> +		=A0=A0=A0=A0ec->tx_max_coalesced_frames_irq ||
>> +		=A0=A0=A0=A0ec->rx_max_coalesced_frames_irq) {
>> +			return -EINVAL;
>> +		}
>> +		memset(adapter->coal_conf, 0, sizeof(*adapter->coal_conf));
>> +		adapter->coal_conf->coalMode =3D ec->rx_coalesce_usecs;
>> +		break;
>> +	case VMXNET3_COALESCE_STATIC:
> [...]
>=20
> I don't want to see drivers introducing magic values for fields that
> are denominated in microseconds (especially not for 0, which is the
> correct way to specify 'no coalescing'). =A0If the current
> ethtool_coalesce structure is inadequate, propose an extension.

Agreed.

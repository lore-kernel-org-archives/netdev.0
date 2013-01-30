From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: disallow drivers with buggy VLAN accel
 to register_netdevice()
Date: Tue, 29 Jan 2013 22:56:57 -0500 (EST)
Message-ID: <20130129.225657.181728058877634021.davem@davemloft.net>
References: <c7fdfc32f69e7a4c3bfcaa8b2ee842aa9b286c91.1359507017.git.mirq-linux@rere.qmqm.pl>
	<510874B9.5000208@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mirq-linux@rere.qmqm.pl, netdev@vger.kernel.org, kaber@trash.net,
	shemminger@vyatta.com
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35258 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753444Ab3A3D46 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 22:56:58 -0500
In-Reply-To: <510874B9.5000208@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Vlad Yasevich <vyasevic@redhat.com>
Date: Tue, 29 Jan 2013 20:17:45 -0500

> On 01/29/2013 08:14 PM, Micha=A9=A9 Miros=A9=A9aw wrote:
>> Instead of jumping aroung bugs that are easily fixed just don't let
>> them in:
>> affected drivers should be either fixed or have NETIF_F_HW_VLAN_FILT=
ER
>> removed from advertised features.
>>
>> Quick grep in drivers/net shows two drivers that have
>> NETIF_F_HW_VLAN_FILTER
>> but not ndo_vlan_rx_add/kill_vid(), but those are false-positives
>> (features
>> are commented out).
>>
>> OTOH two drivers have ndo_vlan_rx_add/kill_vid() implemented but don=
't
>> advertise NETIF_F_HW_VLAN_FILTER. Those are:
>=20
> I am a bit hesitant to completely disable drivers, but I guess it
> would force people to fix their drivers if this is applied.

I think an improperly implemented driver should be BUG trapped as soon
as possible.

I've applied this patch, thanks.

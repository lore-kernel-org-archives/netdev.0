From: Dimitris Michailidis <dm@chelsio.com>
Subject: Re: [PATCH net-next 1/2 RESEND v3] net: use NETIF_F_ALL_TSO for vlan
 features
Date: Thu, 12 May 2011 10:05:54 -0700
Message-ID: <4DCC1372.3040607@chelsio.com>
References: <4DCA2B86.9030205@cn.fujitsu.com> <4DCABABB.9040001@chelsio.com> <4DCBAE3B.3070201@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, eilong@broadcom.com,
	leedom@chelsio.com
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:4769 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757988Ab1ELRGJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 13:06:09 -0400
In-Reply-To: <4DCBAE3B.3070201@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/12/2011 02:54 AM, Shan Wei wrote:
> Dimitris Michailidis wrote, at 2011=E5=B9=B405=E6=9C=8812=E6=97=A5 00=
:35:
>> On 05/10/2011 11:24 PM, Shan Wei wrote:
>>> As Dimitris Michailidis suggested, use NETIF_F_ALL_TSO for vlan_fea=
tures,
>>> which is a mask, but not hw_features.
>>>
>>> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
>> While these changes aren't wrong I don't see a good reason to make t=
hem.  I am also curious why you're changing only these three drivers.
>=20
> A personal reason to quickly know what device supports ALL TSO,
> not to search one by one. :;)

But vlan_features doesn't indicate by itself what the device supports, =
and it=20
is because of this that you can use NETIF_F_ALL_TSO in vlan_features wi=
thout=20
much future breakage risk.  There's still the potential that in the fut=
ure some=20
additional TSO variant will be added that some of the drivers you're ch=
anging=20
support, but not over VLANs, and then they'll need to undo you change.

If you want to know which drivers support all TSOs you really need to l=
ook at=20
their features and hw_features.  One could set NETIF_F_ALL_TSO in vlan_=
features=20
of a driver that doesn't support any form of TSO.  The way you're check=
ing=20
you'd be misled into thinking that driver supports all TSO.


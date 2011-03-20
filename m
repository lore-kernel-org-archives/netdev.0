From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: oops / kernel panic in bonding.
Date: Sun, 20 Mar 2011 22:19:21 +0100
Message-ID: <4D866F59.5070703@gmail.com>
References: <4D8660EC.6080102@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:48653 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750837Ab1CTVT0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Mar 2011 17:19:26 -0400
Received: by wwa36 with SMTP id 36so6707934wwa.1
        for <netdev@vger.kernel.org>; Sun, 20 Mar 2011 14:19:24 -0700 (PDT)
In-Reply-To: <4D8660EC.6080102@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 20/03/2011 21:17, Nicolas de Peslo=FCan a =E9crit :
> Hi Jiri,
>
> I suspect we have a race condition somewhere in the new
> bond_handle_frame function:
>
> The following commands produce one of the following errors:
>
> modprobe bonding max_bonds=3D0
> echo +bond0>/sys/class/net/bonding_masters
> echo +bond1>/sys/class/net/bonding_masters
> echo +eth1>/sys/class/net/bond1/bonding/slaves
>
> This is mostly reproducible, under VirtualBox.
>
> All tests done with 08351fc6a75731226e1112fc7254542bd3a2912e at the t=
op
> commit (current net-next-2.6).

I suspect netdev_rx_handler_register is called too early in bond_enslav=
e.

I think it should be the last thing we do in bond_enslave, if we don't =
want to face the risk to have=20
bond_handle_frame being called before everything is properly setup.

	Nicolas.

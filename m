From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: oops / kernel panic in bonding.
Date: Mon, 21 Mar 2011 07:37:13 +0100
Message-ID: <20110321063712.GB2836@psychotron.redhat.com>
References: <4D8660EC.6080102@gmail.com>
 <4D866F59.5070703@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64301 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751771Ab1CUGhS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Mar 2011 02:37:18 -0400
Content-Disposition: inline
In-Reply-To: <4D866F59.5070703@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Mar 20, 2011 at 10:19:21PM CET, nicolas.2p.debian@gmail.com wrote:
>Le 20/03/2011 21:17, Nicolas de Peslo=FCan a =E9crit :
>>Hi Jiri,
>>
>>I suspect we have a race condition somewhere in the new
>>bond_handle_frame function:
>>
>>The following commands produce one of the following errors:
>>
>>modprobe bonding max_bonds=3D0
>>echo +bond0>/sys/class/net/bonding_masters
>>echo +bond1>/sys/class/net/bonding_masters
>>echo +eth1>/sys/class/net/bond1/bonding/slaves
>>
>>This is mostly reproducible, under VirtualBox.
>>
>>All tests done with 08351fc6a75731226e1112fc7254542bd3a2912e at the t=
op
>>commit (current net-next-2.6).
>
>I suspect netdev_rx_handler_register is called too early in bond_ensla=
ve.
>
>I think it should be the last thing we do in bond_enslave, if we
>don't want to face the risk to have bond_handle_frame being called
>before everything is properly setup.
>
>	Nicolas.

Hmm, Offset 0x280 is big, I suggest dev->master is not set. Will look a=
t
this.

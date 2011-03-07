From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6] net: reinject arps into bonding slave	instead
 of master
Date: Mon, 07 Mar 2011 21:12:48 +0100
Message-ID: <4D753C40.2030502@gmail.com>
References: <1299320969-7951-1-git-send-email-jpirko@redhat.com> <1299320969-7951-7-git-send-email-jpirko@redhat.com> <4D7249BA.8030401@gmail.com> <20110305144314.GC8573@psychotron.redhat.com> <4D724DB4.9020207@gmail.com> <4D737D00.20406@gmail.com> <20110306133413.GB2795@psychotron.redhat.com> <20110307125059.GA6053@psychotron.brq.redhat.com> <20110307143202.GS11864@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:53476 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750925Ab1CGUMv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 15:12:51 -0500
Received: by wyg36 with SMTP id 36so4535566wyg.19
        for <netdev@vger.kernel.org>; Mon, 07 Mar 2011 12:12:49 -0800 (PST)
In-Reply-To: <20110307143202.GS11864@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 07/03/2011 15:32, Andy Gospodarek a =E9crit :
> On Mon, Mar 07, 2011 at 01:51:00PM +0100, Jiri Pirko wrote:
>> Recent patch "bonding: move processing of recv handlers into
>> handle_frame()" caused a regression on following net scheme:
>>
>> eth0 - bond0 - bond0.5
>>
>> where arp monitoring is happening over vlan. This patch fixes it by
>> reinjecting the arp packet into bonding slave device so the bonding
>> rx_handler can pickup and process it.
>>
>> Signed-off-by: Jiri Pirko<jpirko@redhat.com>

Reviewed-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>

> Thanks, Jiri.  I will test and make sure it works correctly now.  I k=
now
> several users who would be quite disappointed if this feature was
> removed.

Andy, while you are testing it, can you ensure it also works for the fo=
llowing setup?

eth0 -> bond0 -> br0 -> br0.100

I think it should, as long as the slave is the first device in the path=
=2E

Can you imagine a bonding setup where the slaves are not first in the p=
ath?

eth0 -> br0 -> bond0?
eth0 -> eth1(macvlan) -> bond0?
eth0 -> eth0.100 -> bond0?

	Nicolas.

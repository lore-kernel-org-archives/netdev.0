From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG] net: cpu offline cause napi stall
Date: Wed, 01 Jun 2011 14:13:19 +0200
Message-ID: <1306930399.3476.1.camel@edumazet-laptop>
References: <20110601103356.GA45482@tuxmaker.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org, heiko.carstens@de.ibm.com
To: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:33063 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756031Ab1FAMNX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2011 08:13:23 -0400
In-Reply-To: <20110601103356.GA45482@tuxmaker.boeblingen.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 01 juin 2011 =C3=A0 12:33 +0200, Frank Blaschka a =C3=A9cri=
t :
> Hi Dave, Eric,
>=20
> during heavy network load we turn off/on cpus.
> Sometimes this causes a stall on the network device.
> Digging into the dump I found out following:
>=20
> napi is scheduled but does not run. From the I/O buffers
> and the napi state I see napi/rx_softirq processing has stopped
> because the budget was reached. napi stays in the
> softnet_data poll_list and the rx_softirq was raised again.
>=20
> I assume at this time the cpu offline comes in.
> the rx softirq is raised/moved to another cpu but napi stays in the p=
oll_list
> of the softnet_data of the now offline cpu.
>=20
> reviewing dev_cpu_callback (net/core/dev.c) I did not find the poll_l=
ist
> is transfered to the new cpu. Do you think this could cause the stall=
 or
> did I miss something?
>=20
> Thx for your help.

Hi Frank

I believe you are right, I cant see where the poll_list transfert from
dead cpu to online cpu is done.

Do you want to prepare a patch ?

Thanks !




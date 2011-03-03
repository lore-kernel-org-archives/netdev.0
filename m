From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bad performance when CUBIC HyStart enabled
Date: Thu, 03 Mar 2011 16:03:00 +0100
Message-ID: <1299164580.2983.99.camel@edumazet-laptop>
References: <20110303142229.GA9262@xanadu.blop.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Sangtae Ha <sha2@ncsu.edu>
To: Lucas Nussbaum <lucas.nussbaum@loria.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:38387 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758190Ab1CCPDG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 10:03:06 -0500
Received: by fxm17 with SMTP id 17so1172816fxm.19
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2011 07:03:04 -0800 (PST)
In-Reply-To: <20110303142229.GA9262@xanadu.blop.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 03 mars 2011 =C3=A0 15:22 +0100, Lucas Nussbaum a =C3=A9crit :
> Hi,
>=20
> I'm experiencing bad performance transferring data over a large BDP
> network with CUBIC when HyStart is enabled. Disabling HyStart fixes t=
he
> problem.
>=20
> Test setup:
> I'm transfering a 2-GB file between two machines using netcat. On bot=
h
> machines, /dev/shm is used to store the data.
> On the sending side, I use:
> /dev/shm# while true; do dd if=3Dfoo bs=3D10M | nc -l -p 2222 -q 0; d=
one
> On the receiving side, I use:
> /dev/shm# /usr/bin/time nc 131.254.203.6 2222 > foo
> Both machines are on Gigabit ethernet networks, and the RTT between t=
hem
> is 11.3ms.
> The default sysctl values are used.
> I use nload -i 1000000 -o 1000000 -u m eth0 to visualize the transfer
> rate.
>=20
> With a 2.6.26 kernel, everything is fine. The bandwidth quickly gets =
to
> ~940 Mbps, and I get the following in nload:
>       ..................................
>      .##################################
>      ###################################
>      ###################################
>      ###################################
>      ####################################
>      ####################################
>      ####################################
>      ####################################
>      ####################################
>      ####################################
>      ####################################
>      ####################################
>      ####################################
> The transfer time is 18.2s, which is reasonable for a 2-GB file.
>=20
> With a 2.6.32 kernel (Debian's) or with a 2.6.37 kernel (on the sendi=
ng
> side only), with the default HyStart parameters, I get the following:
>                            ..........................
>                           |##########################.
>                          |############################
>                         |#############################
>                        |##############################
>                       |###############################
>                     .#################################
>                    |##################################|=20
>                  |#####################################=20
>             ..||#######################################=20
>     ....|##############################################=20
>  .#####################################################=20
> The transfer time is 26.8s. (There's one character every 0.5s on the
> graph above)
>=20
> Disabling hystart on the sending machine with:
> echo 0 > /sys/module/tcp_cubic/parameters/hystart
> Fixes the problem.
>=20
> It seems that waiting for some time (or rebooting) fixes the problem =
for
> some time, so I'm suspecting that the problem is caused by a cache of
> some sort. However, doing:
> echo 1 > /proc/sys/net/ipv4/route/flush
> doesn't fix the problem.
>=20
> Ideas? I could arrange to give access to the testbed if needed.
> (https://www.grid5000.fr/)

eventually, after fresh boot of both sender/receiver, it would be nice
to have "netstat -s" results after one transfert with said problems.




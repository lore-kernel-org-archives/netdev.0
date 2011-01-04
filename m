From: Yann Dupont <Yann.Dupont@univ-nantes.fr>
Subject: possible issue between bridge igmp/multicast  handling & bnx2x on
 kernel 2.6.34 and >
Date: Tue, 04 Jan 2011 14:40:30 +0100
Message-ID: <4D23234E.30709@univ-nantes.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-tls1.univ-nantes.fr ([193.52.101.145]:41993 "EHLO
	smtp-tls.univ-nantes.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751026Ab1ADNuF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jan 2011 08:50:05 -0500
Received: from localhost (debian [127.0.0.1])
	by smtp-tls.univ-nantes.fr (Postfix) with ESMTP id ED1BA953FF
	for <netdev@vger.kernel.org>; Tue,  4 Jan 2011 14:41:37 +0100 (CET)
Received: from smtp-tls.univ-nantes.fr ([127.0.0.1])
	by localhost (smtp-tls1.d101.univ-nantes.fr [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id AC8fjOLFkbtz for <netdev@vger.kernel.org>;
	Tue,  4 Jan 2011 14:41:37 +0100 (CET)
Received: from [172.20.13.9] (tomintoul.cri.univ-nantes.prive [172.20.13.9])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp-tls.univ-nantes.fr (Postfix) with ESMTPSA id D21E7953FE
	for <netdev@vger.kernel.org>; Tue,  4 Jan 2011 14:41:37 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.
I hope this is not a known problem.

We have servers running recent (2.6.36, 2.6.37-rc)  hand compiled=20
vanilla kernels. We are using those servers to run KVM & LXC.
Those servers are DELL poweredge M605 in a M1000e enclosure ; the=20
network cards are 2X BCM5708S, driver bnx2, connected to Power Connect=20
M6220.

Multiples vlans are used, each vlan is connected to a virtual bridge on=
=20
the host.

This setup has been running fine for months.

We just added BCM57711 10G cards (bnx2x driver) on our blade servers=20
(connected to 10G Power Connect M8024).
Since then, we are experiencing random lost of packets.

Symptom : packets are lost on some vlans for a few seconds, then things=
=20
go back to normal (and stops again a few minutes later)

We then noticed that standard debian kernel (2.6.32.xxx) was running=20
fine. Vanilla 2.6.32  kernel is also OK.
So I started a git bissect.

It ended there :

3fe2d7c70b747d5d968f4e8fa210676d49d40059 is the first bad commit
commit 3fe2d7c70b747d5d968f4e8fa210676d49d40059
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Sun Feb 28 00:49:38 2010 -0800

     bridge: Add multicast start/stop hooks

     This patch hooks up the bridge start/stop and add/delete/disable
     port functions to the new multicast module.

     Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
     Signed-off-by: David S. Miller <davem@davemloft.net>


I doubt the problem lies there ; when using bnx2 driver, there is no=20
problem, and the patch itself is quite old now.

I tested turning off ICMP snooping in bridge , and this really resolves=
=20
the problem.
Kernel 2.6.37-rc8 without this option works fine for us with bnx2x.


Does anybody have an explanation ?

Regards

--=20
Yann Dupont - Service IRTS, DSI Universit=E9 de Nantes
Tel : 02.53.48.49.20 - Mail/Jabber : Yann.Dupont@univ-nantes.fr


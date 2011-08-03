From: Eduard Sinelnikov <eduard.sinelnikov@gmail.com>
Subject: Re: [PATCH] net: Fix security_socket_sendmsg() bypass problem.
Date: Wed, 3 Aug 2011 16:37:06 +0300
Message-ID: <CANMAZFVfd_TfAhjJ+L3Qs4ae1KWPsfaG_RpS9MNzhOXFsOVdVA@mail.gmail.com>
References: <20110802.050115.1714327089688495866.davem@davemloft.net>
	<201108022211.BJI69291.QLFFJMOOtOHVSF@I-love.SAKURA.ne.jp>
	<201108030325.p733Pplb030986@www262.sakura.ne.jp>
	<20110802.203836.40056483416201909.davem@davemloft.net>
	<20110803134752.31347b64@kryten>
	<201108032120.CHC60420.OVOFQFHMJLSOtF@I-love.SAKURA.ne.jp>
	<20110803232957.5e7a5d0a@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:60784 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751056Ab1HCNhH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2011 09:37:07 -0400
Received: by wyg8 with SMTP id 8so550081wyg.19
        for <netdev@vger.kernel.org>; Wed, 03 Aug 2011 06:37:06 -0700 (PDT)
In-Reply-To: <20110803232957.5e7a5d0a@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The scenario:
The scenario is:
* Create a bond with 3 interfaces (connect them to switch).
* Change bond's mode to active/backup.
* Physicly remove two cables form interfaces ( not the active interface=
 ).
* Put the cables back
* Change the mode to round robin.
* Try to ping some other computer.

Now only one interface is pinging to remote computer.
Without removing the cables all three interface will ping to remote
computer periodicly.



The problem:
In the kernel 2.6.39.3 ( /drivers/net/bond/bond_main.c).
In the function  =91bond_xmit_roundrobin=92
The code check if the bond is active via
=91bond_is_active_slave(slave)=92 Function call.
Which actually checks if the slave is backup or active
What is the meaning of slave being  backup in round robin mode?
Correct me if I wrong but in round robin every slave should send a
packet, regardless of being active or backup.

Thank you,
           Eduard

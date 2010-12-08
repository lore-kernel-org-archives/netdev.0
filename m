From: Stephen Hemminger <shemminger@vyatta.com>
Subject: tc: show format ABI changed
Date: Wed, 8 Dec 2010 14:51:36 -0800
Message-ID: <20101208145136.1ca3ece4@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58685 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932075Ab0LHWvj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 17:51:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Although well intentioned, the following patch should have not
been applied since it changes the kernel ABI. It broke some scripts
parsing the output format of tc commands.

Before HTB would report bogus zero values, now it reports
nothing and that changes the output format.  Like the empty
fields in /proc, I argue we can't play fast and loose with
netlink responses.

Not a big deal to fix the script in this case, in this case
so don't revert it.

commit d250a5f90e53f5e150618186230795352d154c88
Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Fri Oct 2 10:32:18 2009 +0000

    pkt_sched: gen_estimator: Dont report fake rate estimators
   =20
    Jarek Poplawski a =E9crit :
    >
    >
    > Hmm... So you made me to do some "real" work here, and guess what=
?:
    > there is one serious checkpatch warning! ;-) Plus, this new param=
eter
    > should be added to the function description. Otherwise:
    > Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
    >
    > Thanks,
    > Jarek P.
    >
    > PS: I guess full "Don't" would show we really mean it...
   =20
    Okay :) Here is the last round, before the night !
   =20
    Thanks again
   =20
    [RFC] pkt_sched: gen_estimator: Don't report fake rate estimators
   =20
    We currently send TCA_STATS_RATE_EST elements to netlink users, eve=
n if no estimator
    is running.
   =20
    # tc -s -d qdisc
    qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 =
1 1 1 1 1 1 1 1
     Sent 112833764978 bytes 1495081739 pkt (dropped 0, overlimits 0 re=
queues 0)
     rate 0bit 0pps backlog 0b 0p requeues 0
   =20
    User has no way to tell if the "rate 0bit 0pps" is a real estimatio=
n, or a fake
    one (because no estimator is active)
   =20
    After this patch, tc command output is :
    $ tc -s -d qdisc
    qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 =
1 1 1 1 1 1 1 1
     Sent 561075 bytes 1196 pkt (dropped 0, overlimits 0 requeues 0)
     backlog 0b 0p requeues 0
   =20
    We add a parameter to gnet_stats_copy_rate_est() function so that
    it can use gen_estimator_active(bstats, r), as suggested by Jarek.
   =20
    This parameter can be NULL if check is not necessary, (htb for
    example has a mandatory rate estimator)
   =20
    Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
    Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

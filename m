From: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Subject: Re: ipv4/udp: Verify multicast group is ours in upd_v4_early_demux()
Date: Thu, 30 Jul 2015 22:26:08 +0200
Message-ID: <CA++eYdtOendgSVix0aibj_Ykd=7td4ac3z9Zz1c_p67Xy3bWYw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Yurij.Plotnikov@oktetlabs.ru, David Miller <davem@davemloft.net>,
	=?UTF-8?Q?St=C3=A5le_Kristoffersen?= <stalk@bridgetech.tv>
To: sbohrer@rgmadvisors.com, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:33974 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750865AbbG3U0J convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 16:26:09 -0400
Received: by wibud3 with SMTP id ud3so34594630wib.1
        for <netdev@vger.kernel.org>; Thu, 30 Jul 2015 13:26:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 6e54030 breaks the IP_MULTICAST_ALL socket option. There is
already a check in ip_mc_sf_allow() that should do the filtering you
claim to fix. Was it considered?

Commit message:
421b3885bf6d56391297844f43fb7154a6396e12 "udp: ipv4: Add udp early
demux" introduced a regression that allowed sockets bound to INADDR_ANY
to receive packets from multicast groups that the socket had not joined=
=2E..

man ip(7):
IP_MULTICAST_ALL (since Linux 2.6.31)
This option can be used to modify the delivery policy of
multicast messages to sockets bound to the wildcard INADDR_ANY
address.  The argument is a boolean integer (defaults to 1).
If set to 1, the socket will receive messages from all the
groups that have been joined globally on the whole system.
Otherwise, it will deliver messages only from the groups that
have been explicitly joined=E2=80=A6

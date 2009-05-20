From: Rami Rosen <ramirose@gmail.com>
Subject: Question about /proc/net/netlink mystery
Date: Wed, 20 May 2009 22:22:46 +0300
Message-ID: <eb3ff54b0905201222t6ecc241bq2168538742b48deb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f176.google.com ([209.85.219.176]:49014 "EHLO
	mail-ew0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754904AbZETTWp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2009 15:22:45 -0400
Received: by ewy24 with SMTP id 24so754241ewy.37
        for <netdev@vger.kernel.org>; Wed, 20 May 2009 12:22:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
I tried to figure this out, but something is mysterious here to me.

 cat /proc/net/netlink
shows:
sk       Eth Pid    Groups   Rmem     Wmem     Dump     Locks

Why is the Eth here in the second column title?
It does not seem that this column has anything to do with network
interfaces.

A short look to the code, in netlink_seq_show() , net/netlink/af_netlink.c,
will show that the values in this column are s->sk_protocol.

So it seems that the title should be here different; it should represent
the protocol (since s->sk_protocol is assigned
the number of the protocol of the netlink socket ;
for example, NETLINK_ROUTE is 0, NETLINK_AUDIT is 9, and so on ; (see
include/linux/netfilter.h)

So shouldn't it be something like "Proto"?

Regards,
Rami Rosen

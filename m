From: Petar Bogdanovic <petar@smokva.net>
Subject: drivers/net/tun.c: CAP_NET_ADMIN conditional not reached
Date: Fri, 29 Jul 2011 00:00:27 +0200
Message-ID: <20110728220026.GA25322@pintail.smokva.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from morrison.andev.ch ([78.47.142.202]:65367 "EHLO
	morrison.andev.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755070Ab1G1WHP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 18:07:15 -0400
Received: from pintail.smokva.net (84-73-26-94.dclient.hispeed.ch [84.73.26.94])
	by morrison.andev.ch (Postfix) with ESMTP id 060705D99F
	for <netdev@vger.kernel.org>; Fri, 29 Jul 2011 00:01:06 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

drivers/net/tun.c says:

    1004  if (((tun->owner != -1 && cred->euid != tun->owner) ||
    1005       (tun->group != -1 && !in_egroup_p(tun->group))) &&
    1006      !capable(CAP_NET_ADMIN))
    1007          return -EPERM;

this will skip !capable(CAP_NET_ADMIN) if tun->owner and tun->group are
both -1, which seems to be their default value (see lines 854,855).
ip(8) from iproute2 won't do any TUNSETOWNER/TUNSETGROUP ioctl() if no
uid and/or gid is supplied so when using `ip tuntap' as an unprivileged
user, you'll be unable to create a new tun(4) but won't have any
problems attaching to an existing device created without both user and
group options.

I'm not sure whether this is intentional since it has been around for
years.. although triggering it with tunctl(8) was not possible---tunctl
without `-u' seems to use 0 as the default value for TUNSETOWNER.


		Petar Bogdanovic

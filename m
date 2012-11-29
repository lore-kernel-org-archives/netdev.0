From: Jan Synacek <jsynacek@redhat.com>
Subject: iputils: ping -I <iface>
Date: Thu, 29 Nov 2012 15:12:43 +0100
Message-ID: <50B76D5B.8010804@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26536 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754338Ab2K2OMs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Nov 2012 09:12:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

There seems to be a bug(?) when calling ping with -I lo:

$ ping -I lo kernel.org

PING kernel.org (149.20.4.69) from 192.168.1.10 lo: 56(84) bytes of data.
^C

Note that 192.168.1.10 is my primary interface's address (em1). However, no
replies are coming back.

$ ping -I em1 kernel.org

PING kernel.org (149.20.4.69) from 192.168.1.10 em1: 56(84) bytes of data.
64 bytes from pub2.kernel.org (149.20.4.69): icmp_seq=1 ttl=42 time=202 ms
64 bytes from pub2.kernel.org (149.20.4.69): icmp_seq=2 ttl=42 time=187 ms
^C

Works as expected.

I know that binding to loopback probably doesn't make much sense, but I think
that ping should be able to cope with that.

Also, it would be nice to mention the difference between -I <ip> and -I <iface>
in the manpage.

I don't understand the problem clearly enough to write a patch.

Regards,
-- 
Jan Synacek
Software Engineer, BaseOS team Brno, Red Hat

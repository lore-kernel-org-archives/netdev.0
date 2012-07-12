From: Timo Teras <timo.teras@iki.fi>
Subject: iptables CLAMP MSS to PMTU not working?
Date: Thu, 12 Jul 2012 12:00:21 +0300
Message-ID: <20120712120021.3dc5cd68@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:38599 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932826Ab2GLJAn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 05:00:43 -0400
Received: by lbbgm6 with SMTP id gm6so3865240lbb.19
        for <netdev@vger.kernel.org>; Thu, 12 Jul 2012 02:00:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

We recently noticed that CLAMPMSS to path MTU does not seem to be
working properly. Most recently tested version is linux-3.3.6 which
does not work. linux-2.6.35 works for sure, but I suspect it to have
broken somewhere around 3.0'ish with the inetpeer changes.

In my case, the destination is on gre tunnel (that gets routed to
Internet over IPsec transport mode).

'ip route' command verifies that in both boxes the path-MTU is detected
properly. That, is on both cases the static route MTU is higher. And
after large packets sent, ICMP frag-needed is received and the cache
route is updated properly.

On the new kernel, I get info like:
# ip route get 10.x.x.x
10.x.x.x via 172.16.y.y dev gre1  src 172.16.z.z 
    cache  expires 68sec ipid 0x3153 mtu 1422

And the older kernel:
# ip route get 10.x.x.x
10.x.x.x via 172.16.y.y dev gre1  src 172.16.z.z 
    cache  expires 595sec ipid 0xd241 mtu 1422 advmss 1432 hoplimit 64

For some reason, iptables CLAMPMSS seems to set incorrect MSS for this
route (or maybe it's using the static route instead?).

Any ideas?

Thanks,
 Timo

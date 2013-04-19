From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC 1/2] netmap: infrastructure (in staging)
Date: Fri, 19 Apr 2013 13:31:23 -0700
Message-ID: <1366403483.16391.59.camel@edumazet-glaptop>
References: <20130419120651.4e646976@nehalam.linuxnetplumber.net>
	 <20130419194537.GA1633@kroah.com>
	 <20130419.155859.1092595631804890737.davem@davemloft.net>
	 <20130419131632.31fce894@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, gregkh@linuxfoundation.org,
	netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:50029 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753980Ab3DSUb0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 16:31:26 -0400
Received: by mail-pd0-f171.google.com with SMTP id t12so294868pdi.30
        for <netdev@vger.kernel.org>; Fri, 19 Apr 2013 13:31:25 -0700 (PDT)
In-Reply-To: <20130419131632.31fce894@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-04-19 at 13:16 -0700, Stephen Hemminger wrote:

> I can not get line rate output with pktgen on existing kernels today.

I have no trouble saturating at line rate with pktgen, and using
multiqueue NIC.


> I can get line rate easily with netmap.

Yes, but then, its about bypassing the OS, and reimplementing everything
in user land. TCP/UDP/IP stack, iptables, rate limiting, sharing a NIC
among users of this NIC, adding new hot points (sending tx descriptors
without caring about need_resched or whatever)

But I agree pktgen is kind of limited (it sends UDP packets.), please do
not compare pktgen and netmap.

pktgen was something to avoid spending time in UDP/IP stack, and it was
probably needed years ago or if network researchers want to use a laptop
as a pktgen host.

It reminds me the days linux had http server in kernel.

With 8+ cpus, you can plainly use a user land application.

I really hope we do not use pktgen as an argument for having netmap in
the kernel.

From: "Holger Hoffstaette" <holger.hoffstaette@googlemail.com>
Subject: Re: Network hangs with 2.6.30.5
Date: Tue, 01 Sep 2009 16:17:08 +0200
Message-ID: <pan.2009.09.01.14.17.06.671250@googlemail.com>
References: <7D2F0769-2994-4BB8-B107-DEF2B1346B3A@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:49563 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754334AbZIAOZD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2009 10:25:03 -0400
Received: from list by lo.gmane.org with local (Exim 4.50)
	id 1MiUIC-0007cs-7R
	for netdev@vger.kernel.org; Tue, 01 Sep 2009 16:25:04 +0200
Received: from port-87-234-135-12.dynamic.qsc.de ([87.234.135.12])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 01 Sep 2009 16:25:04 +0200
Received: from holger.hoffstaette by port-87-234-135-12.dynamic.qsc.de with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 01 Sep 2009 16:25:04 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 01 Sep 2009 19:50:38 +1000, Clifford Heath wrote:

> I sent this email last Friday, but received no response.
> 
> As far as I can see, some recent work in the stable Linux kernel has
> broken the TCP stack, at least on my (pretty common) hardware. Can anyone
> confirm that they've seen and perhaps fixed similar symptoms, or at least
> tell me what else I need to do to help them identify the problem?

Unfortunately I can't offer clues but *can* confirm that every kernel
since .30 has also exhibited strange networking regressions, to the point
where I had to give up even trying to understand from the changelogs who
was changing what, when, where and why and what the actual symptom is.

With .29 everything works fine; everything since .30 has trouble with
either samba or squid (both of which are the main purposes of that
particular machine). After all the initial regressions with epoll in .30 I
suspected that and built squid without epoll, but no improvement;
connecting over the network is broken (spurious connections, timeouts,
sometimes partial successes) whereas using squid from localhost (via
loopback) seems to work fine. It also seems to work fine for a friend on
.30 so the software is unlikely to be the problem.

I do have an older Intel Gbit card identified thusly:
00:0b.0 Ethernet controller: Intel Corporation 82545GM Gigabit Ethernet Controller (rev 04)

and enabled all sorts of offloading:

$ethtool -k eth0     
Offload parameters for eth0:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp segmentation offload: on
udp fragmentation offload: off
generic segmentation offload: on

Maybe that is the culprit, as Eric Dumazet suspected in his mail..I will
try the latest .30 stable again without that, but in any case something is
indeed very broken in there.

-h



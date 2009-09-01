From: "Holger Hoffstaette" <holger.hoffstaette@googlemail.com>
Subject: Re: Network hangs with 2.6.30.5
Date: Tue, 01 Sep 2009 17:32:24 +0200
Message-ID: <pan.2009.09.01.15.32.24.613750@googlemail.com>
References: <7D2F0769-2994-4BB8-B107-DEF2B1346B3A@gmail.com> <pan.2009.09.01.14.17.06.671250@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:49520 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754578AbZIAPc4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2009 11:32:56 -0400
Received: from list by lo.gmane.org with local (Exim 4.50)
	id 1MiVLn-0006P1-UQ
	for netdev@vger.kernel.org; Tue, 01 Sep 2009 17:32:51 +0200
Received: from port-87-234-135-12.dynamic.qsc.de ([87.234.135.12])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 01 Sep 2009 17:32:51 +0200
Received: from holger.hoffstaette by port-87-234-135-12.dynamic.qsc.de with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 01 Sep 2009 17:32:51 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 01 Sep 2009 16:17:08 +0200, Holger Hoffstaette wrote:

[network regressions in .30]

> I do have an older Intel Gbit card identified thusly: 00:0b.0 Ethernet
> controller: Intel Corporation 82545GM Gigabit Ethernet Controller (rev 04)
> 
> and enabled all sorts of offloading:
> 
> $ethtool -k eth0
> Offload parameters for eth0:
> rx-checksumming: on
> tx-checksumming: on
> scatter-gather: on
> tcp segmentation offload: on
> udp fragmentation offload: off
> generic segmentation offload: on
> 
> Maybe that is the culprit, as Eric Dumazet suspected in his mail..I will
> try the latest .30 stable again without that, but in any case something is
> indeed very broken in there.

So I just tried .30.5 again. Indeed the offloading seems to play a role:
with everything enabled I cannot even reliably ssh into the machine (only
"sometimes"?); however without any offloading things get "a bit better"
and squid even serves up some pages..for a while. Then it seems to hang,
swallow requests or not finish them. The tested sites reliably work for
the Windows client when it bypasses squid, as does DNS (also served from
the box). It *seems* to affect incoming traffic more than outgoing - e.g.
mail or news polling seemed to kick off and finish just fine.
Rebooting back into .29 fixes everything. Last time I tried
.31rc-something (4 IIRC) it exhibited the same problems.

I'm open to suggestions and willing to help fix this but need this machine
for actual work. :/

-h



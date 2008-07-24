From: Marek Kierdelewicz <marek@piasta.pl>
Subject: Re: TUN/TAP hacking
Date: Thu, 24 Jul 2008 08:50:06 +0200
Message-ID: <20080724085006.1163d122@catlap>
References: <20080723235514.GA8992@zenon.in.qult.net>
	<4887E818.4020305@isomerica.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ignacy Gawedzki <lkml@qult.net>
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from psyche.piasta.pl ([83.175.144.5]:60165 "EHLO psyche.piasta.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750737AbYGXHRn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2008 03:17:43 -0400
In-Reply-To: <4887E818.4020305@isomerica.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ignacy & netdev,

> I thought I'd be able to use the TAP interfaces to create some sort
> of a network emulator.  For a start I just "bridged" two tap
> interfaces, much in the same way as the example of br_select.c from
> http://vtun.sf.net , assigned both interfaces different IPv4
> addresses (both with a /32 prefix),

As far as I understand you're trying to bridge two interfaces of the
same host. It's no good for a test network, because local traffic
(from/to the same host) will always be forwarded locally (via lo?) and
will never reach any ethX or tapX interface (not without kernel
hacking). There's another way... You can use QEMU[1]/KQEMU[2]/KVM[3] for
guest system virtualization with options that create tapX interfaces
on host and ethX on guests. Then you can bridge taps the way you want
(even with eths on your host system) as described in [4][5]. For guest
system I'd recommend openwrt kamikaze[6]. It's small in terms of system
image size and memory consumption so you can build a complex virtual
network of 10+ hosts using only 200MB of disk space and 320MB of ram.

[1] http://bellard.org/qemu/
[2] http://bellard.org/qemu/kqemu-doc.html
[3] http://kvm.qumranet.com/kvmwiki
[4] http://www.fedoraforum.org/forum/showpost.php?p=530775&postcount=1
[5] http://calamari.reverse-dns.net:980/cgi-bin/moin.cgi/bridge
[6] http://openwrt.org/

Cheers,
Marek Kierdelewicz

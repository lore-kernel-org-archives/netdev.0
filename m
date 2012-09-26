From: Dirkjan Ochtman <dirkjan@ochtman.nl>
Subject: Problems with tg3 on BCM5720
Date: Wed, 26 Sep 2012 15:48:22 +0200
Message-ID: <CAKmKYaCBG5hURNomffgp9gRhS7g2BYsNG-LTmBrKsX-iyVzVxg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:48314 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756473Ab2IZNsn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2012 09:48:43 -0400
Received: by qchd3 with SMTP id d3so120152qch.19
        for <netdev@vger.kernel.org>; Wed, 26 Sep 2012 06:48:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I hope this is the right list for this; please let me know if there is
some more appropriate venue for this kind of problem.

We have bought a Dell PowerEdge server recently with Broadcom ethernet
controllers:

01:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5720
Gigabit Ethernet PCIe
01:00.1 Ethernet controller: Broadcom Corporation NetXtreme BCM5720
Gigabit Ethernet PCIe
02:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5720
Gigabit Ethernet PCIe
02:00.1 Ethernet controller: Broadcom Corporation NetXtreme BCM5720
Gigabit Ethernet PCIe

Using the tg3 driver as provided by the 3.4.9 kernel (it's a distro
kernel, but I verified that there are no relevant patches on top of
the vanilla 3.4.9), networking works fine on a small VLAN. However,
we've run into trouble connecting one of the interfaces to switch run
by our data center vendor (the switch side works fine when connecting
with a laptop). The driver keeps erroring out with "transmit timed
out, resetting" (full syslog output is at [1]). This also keeps
happening when I use the latest tg3.{c,h} from torvalds/linux-2.6
(though I've had to revert a few things to make it compile inside the
3.4.9 kernel).

I've also run some tests with ethtool:

djc@jansky ~ $ sudo ethtool --test eth0
The test result is FAIL
The test extra info:
nvram test        (online)       0
link test         (online)       1
register test     (offline)      0
memory test       (offline)      0
mac loopback test (offline)      7
phy loopback test (offline)      7
ext loopback test (offline)      0
interrupt test    (offline)      1

While I'd be happy to do more digging, at this point I'm out of ideas
on how to go about that.

Again, sorry if this is off-topic for this list, any help would be appreciated.

Cheers,

Dirkjan

[1] http://dirkjan.ochtman.nl/files/tg3-fail.txt

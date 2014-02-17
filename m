From: Luigi Rizzo <rizzo@iet.unipi.it>
Subject: netmap, VALE and netmap pipes
Date: Mon, 17 Feb 2014 11:15:28 +0100
Message-ID: <20140217101528.GA37042@onelab2.iet.unipi.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from onelab2.iet.unipi.it ([131.114.59.238]:64385 "EHLO
	onelab2.iet.unipi.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751206AbaBQKWs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 05:22:48 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
we have recently made a few extensions to netmap/VALE and put various
pieces of code on public repositories, so i thought i'd share the
pointers. All the code below runs with equal features and performance
on FreeBSD and Linux, and we are trying to upstream it in the relevant
projects if possible (as an example, QEMU recently added a netmap backend),
at which point some of these clone repositories will become unnecessary.

See http://info.iet.unipi.it/~luigi/netmap for more details.

https://code.google.com/p/netmap/
    The latest netmap code for FreeBSD/Linux. It has native support
    for certain NICs; emulated netmap over unmodified drivers;
    enhanced parallelism in the VALE switch (20 Mpps/source, scaling
    up to ~50Mpps); and a new feature called "netmap pipe" that
    does zero-copy blocking I/O at over 100 Mpps.
        Other features are the ability to allocate tons of extra
    netmap buffers, and configurable sharing of memory among NICs,
    VALE ports and netmap pipes. This increases the opportunity for
    zero copy operation.
        The user API is also greatly simplified, with a naming
    scheme that permits easy access to all types of ports including
    individual NIC queues.

https://code.google.com/p/netmap-libpcap
    a netmap-enabled version of libpcap. With this, basically any
    pcap client can read/write traffic at 10+ Mpps, with zerocopy
    reads and (soon) support for zerocopy writes. Whether applications
    can cope with these packet rates, of course, is another story.

https://code.google.com/p/netmap-click
    a netmap-enabled version of the Click Modular Router.  This
    code matches the current version of netmap, supporting all
    features (including netmap pipes).

https://code.google.com/p/netmap-ipfw
    a netmap-enabled, userspace version of the ipfw firewall and
    dummynet network emulator. This version reaches 7-10 Mpps for
    filtering and over 2.5 Mpps for emulation.


Hope you'll find it useful.

cheers
luigi

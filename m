From: David Boggs <boggs@boggs.palo-alto.ca.us>
Subject: Re: -git: Why is drivers/net/wan/hdlc_generic.c:hdlc_setup() exported?
Date: Tue, 27 Jun 2006 04:09:11 -0700
Message-ID: <200606271109.k5RB9CSO019247@gw.wa3dbj.vix.com>
Cc: Krzysztof Halasa <khc@pm.waw.pl>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from djb-pa.isc.org ([192.5.4.166]:18886 "EHLO gw.wa3dbj.vix.com")
	by vger.kernel.org with ESMTP id S933396AbWF0LJw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2006 07:09:52 -0400
To: Christoph Hellwig <hch@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In March I posted a request for comments on a rewrite of
the LMC wan driver (see ftp.isc.org/pub/other/lmc).
I designed the LMC wan cards.

The new driver works with Linux, FreeBSD, NetBSD, OpenBSD
and BSD/OS.  FreeBSD and NetBSD have adopted it; OpenBSD is
still thinking about it (their principal comments mirrored
the Linux comments: remove the code for other OSs and adopt
their kernel coding style).  Before I resubmit the new driver
for more Linux comments I will do this.  BTW: FreeBSD and
NetBSD did not insist on this  -- an interesting policy
contrast.  Nobody objected to the code for other OSs and
only one person cleared his throat about coding style.

Anyway, the new driver deals with FIVE line protocol stacks:
Generic-HDLC and SyncPPP (Linux), SPPP (FreeBSD, NetBSD, OpenBSD)
Netgraph (FreeBSD), and P2P (BSD/OS).  Linux's SyncPPP stack is
a renamed version of SPPP, with different interfaces to drivers
and the kernel.  SyncPPP implements PPP and Cisco-HDLC.
Generic-HDLC uses the PPP part but implements its own version
of Cisco-HDLC.

The Linux version of my driver, can be configured to use
Generic-HDLC or SyncPPP, or both with the choice made at
run-time.  Configuring only SyncPPP avoids loading the
Generic-HDLC module if all you need is PPP or Cisco-HDLC.
The driver can switch from one line protocol stack to another
at run time.  This requires detaching from the current stack
and attaching to another.  There is a way to detach Generic-HDLC
but there is no way to reattach it because the initialization
code is called from within alloc_hdlcdev() and is not exported.

I have been working around this by duplicating the code in
hdlc_setup() in my driver.  This is ugly and requires that
the driver know "private" things about Generic-HDLC.  While
studying Generic-HDLC, I noticed that register_hdlc_device() had
some redundant code which had been subsumed by register_netdev().
I pointed this out to Krzysztof Halasa, the maintainer of
Generic-HDLC, and at the same time I asked him to export
hdlc_setup() so that I could remove the duplicate code in
my driver, which he graciously did recently.

I've subscribed to the netdev list since March and I've
read the archives back a year or two.  Whenever I see
something relevant to my new driver, I change it to conform.
Right now I'm busy booting Linux on a PPC inside a Xilinx chip
so I haven't done the final testing and documentation updates
necessary before resubmitting the driver to Linux, but I
promise I will do so Real Soon Now -- before mid-August.

	/David Boggs




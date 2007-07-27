From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: sk98lin for 2.6.23-rc1
Date: Fri, 27 Jul 2007 09:13:41 +0100
Message-ID: <20070727091341.15681172@oldman>
References: <46A8BAD4.8020004@akamai.com>
	<20070726201731.03d3f590@oldman>
	<46A8F3EE.3070102@krose.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kyle Rose <krose@krose.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:49320 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755939AbXG0INg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2007 04:13:36 -0400
In-Reply-To: <46A8F3EE.3070102@krose.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If anyone still has hang issues with sky2, please send me the hardware
information (lspci, dmesg output), and capture the debugfs state after hang.

At present the known open skge, sky2 issues are:

1) Skge doesn't work with dual port fiber
2) Sky2 (and vendor sk98lin) don't work on some MSI motherboards
    due to PCI issues
3) Skge and sky2 trigger problems with motherboards that don't
    do >4GB DMA correctly. Not a driver but a PCI quirk problem.
4) Sky2 does polling for lost irq even when interface not up
5) Sky2 polling rate for lost irq maybe greater than TCP timeout so
    connection may be lost even after link recovers
6) Sky2 Yukon extreme support is still experimental and fragile,
    but this hardware isn't in the wild yet
7) Sky2 Yukon EC-U not powering up PHY correctly on some revisions
8) Sky2 suspend to ram not working right on some chips

Hardware nuisances that are being masked:
a) hardware can't DMA to unaligned address
b) polling for lost irq is a hack, but until the root cause
   is found it will have to stay.

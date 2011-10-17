From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: sky2: only 10Mb/s
Date: Mon, 17 Oct 2011 08:56:47 -0700
Message-ID: <20111017085647.346a37cb@nehalam.linuxnetplumber.net>
References: <201110171434.50436.pavel@netsafe.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pavel Mateja <pavel@netsafe.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40913 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753190Ab1JQP4y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Oct 2011 11:56:54 -0400
In-Reply-To: <201110171434.50436.pavel@netsafe.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 17 Oct 2011 14:34:50 +0200
Pavel Mateja <pavel@netsafe.cz> wrote:

> Hi,
> I tested new kernel and I have found out I have only 10Mb/s link instead of 
> 100Mb/s to my router.
> If I did the git bisect right it was caused by commit 
> 4fb99cd6ac4fe6d03a334a6f4ebb2bbfc4b479ed which was submitted by you.
> 
> My card is (lspci -v):
> 05:00.0 Ethernet controller: Marvell Technology Group Ltd. Yukon Optima 
> 88E8059 [PCIe Gigabit Ethernet Controller with AVB] (rev 11)
>         Subsystem: ASUSTeK Computer Inc. Device 8439
>         Flags: bus master, fast devsel, latency 0, IRQ 80
>         Memory at fe6fc000 (64-bit, non-prefetchable) [size=16K]
>         I/O ports at b800 [size=256]
>         Expansion ROM at fe6c0000 [disabled] [size=128K]
>         Capabilities: [48] Power Management version 3
>         Capabilities: [5c] MSI: Enable+ Count=1/1 Maskable- 64bit+
>         Capabilities: [c0] Express Legacy Endpoint, MSI 00
>         Capabilities: [100] Advanced Error Reporting
>         Capabilities: [130] Device Serial Number a5-89-6d-ff-ff-30-cf-20
>         Kernel driver in use: sky2
> 
> I'm quite sure it's related to Yukon Optima because "Ethernet controller: 
> Marvell Technology Group Ltd. 88E8056 PCI-E Gigabit Ethernet Controller" in my 
> work computer has 100Mb/s with the same kernel and driver.
> 
> I got no response on netdev@vger.kernel.org.
> Can you help me?

What is output of dmesg for sky2.
 dmesg | grep sky2

The problem is related to PHY setup. Almost all of that is copied from the
vendor driver. It might take a few steps to fix because I don't think I
have one of those cards handy.

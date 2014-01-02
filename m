From: Julia Lawall <julia.lawall@lip6.fr>
Subject: question about tulip/winbond-840.c
Date: Thu, 2 Jan 2014 15:24:49 +0100 (CET)
Message-ID: <alpine.DEB.2.10.1401021520280.2088@hadrien>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: grundler@parisc-linux.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3-relais-sop.national.inria.fr ([192.134.164.104]:43855
	"EHLO mail3-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750942AbaABOZG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 09:25:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I don't know if you want to bother about this, because it is very old code
and is apparently not hurting anyone, but I don't see the point of the
call to pci_enable_device in the function w840_resume.  The driver had a
call to pci_enable_device in its probe function, but it contains no call
to pci_disable_device, unlike some other tulip drivers.  Perhaps the call
has a small functionality, but it seems like it can at least never return
a value other than 0, because the result of
atomic_inc_return(&dev->enable_cnt) in pci_enable_device_flags should
be greater than 1.

julia

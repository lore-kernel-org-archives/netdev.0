From: "Hong H. Pham" <hong.pham@windriver.com>
Subject: [PATCH 0/1] NIU: fix spurious interrupts
Date: Mon, 11 May 2009 15:00:52 -0400
Message-ID: <1242068453-5124-1-git-send-email-hong.pham@windriver.com>
Cc: "Hong H. Pham" <hong.pham@windriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:39062 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754389AbZEKTAz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 May 2009 15:00:55 -0400
Received: from ALA-MAIL03.corp.ad.wrs.com (ala-mail03 [147.11.57.144])
	by mail.wrs.com (8.13.6/8.13.6) with ESMTP id n4BJ0sSH011651
	for <netdev@vger.kernel.org>; Mon, 11 May 2009 12:00:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I've tracked down a hang on a SPARC64 system (a Netra T5220 with 64 strands)
whenever the NIU is handling lots of receive traffic.  The hang is
reproducible by running iperf with multiple TCP streams (eg. iperf -P16 ...),
with the SPARC box being the listener.

I've found that it's possible for an RX DMA interrupt to be triggered
while NAPI is in progress.  When this happens, spurious interrupts will
keep being regenerated which will cause the CPU to hang.  It's too busy
servicing the spurious interrupts, and the NIU NAPI handler (or anything
else on that CPU) never gets a chance to run.

In niu_schedule_napi(), if the logical device interrupt is unconditionally
masked out by calling __niu_fastpath_interrupt(), the hang goes away.

Regards,
Hong



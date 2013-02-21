From: Jim Baxter <jim_baxter@mentor.com>
Subject: Re: [PATCH 1/1] net: fec: fix miss init spinlock
Date: Thu, 21 Feb 2013 17:07:12 +0000 (UTC)
Message-ID: <loom.20130221T175907-606@post.gmane.org>
References: <1359708986-23634-1-git-send-email-Frank.Li@freescale.com> <kepftg$f3c$1@ger.gmane.org> <CAHrpEqQMZNmzRrNQK60hokR2r5S=U65YdC-5h6aHHHzAVdEWKw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:38077 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754552Ab3BURH3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Feb 2013 12:07:29 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1U8ZcY-0005Vl-VW
	for netdev@vger.kernel.org; Thu, 21 Feb 2013 18:07:47 +0100
Received: from jimbax.plus.com ([81.174.248.107])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 21 Feb 2013 18:07:46 +0100
Received: from jim_baxter by jimbax.plus.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 21 Feb 2013 18:07:46 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Is the general issue in this driver that the fec_probe function:
request_irq(irq, fec_enet_interrupt, IRQF_DISABLED, pdev->name, ndev);

is called before fec_ptp_init() and fec_enet_init() have been called so that 
there is a chance the fec_enet_interrupt can occur before the hardware and data 
structures are fully setup?

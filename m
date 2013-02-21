From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH 1/1] net: fec: fix miss init spinlock
Date: Thu, 21 Feb 2013 14:28:07 -0300
Message-ID: <CAOMZO5AJa7fs+VdA8jGE5mDnxp4ZQ6a9CjbSou5J+RA3uXUjxQ@mail.gmail.com>
References: <1359708986-23634-1-git-send-email-Frank.Li@freescale.com>
	<kepftg$f3c$1@ger.gmane.org>
	<CAHrpEqQMZNmzRrNQK60hokR2r5S=U65YdC-5h6aHHHzAVdEWKw@mail.gmail.com>
	<loom.20130221T175907-606@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Li Frank-B20596 <B20596@freescale.com>
To: Jim Baxter <jim_baxter@mentor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:63220 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754023Ab3BUR2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2013 12:28:09 -0500
Received: by mail-wi0-f172.google.com with SMTP id ez12so7829189wid.17
        for <netdev@vger.kernel.org>; Thu, 21 Feb 2013 09:28:07 -0800 (PST)
In-Reply-To: <loom.20130221T175907-606@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 21, 2013 at 2:07 PM, Jim Baxter <jim_baxter@mentor.com> wrote:
> Is the general issue in this driver that the fec_probe function:
> request_irq(irq, fec_enet_interrupt, IRQF_DISABLED, pdev->name, ndev);
>
> is called before fec_ptp_init() and fec_enet_init() have been called so that
> there is a chance the fec_enet_interrupt can occur before the hardware and data
> structures are fully setup?

The scenario you described is fixed by the patch that Frank proposed at:
http://patchwork.ozlabs.org/patch/222164/

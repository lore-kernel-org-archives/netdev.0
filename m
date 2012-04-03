From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] sky2: fix missing register reset on error path in
 sky2_test_msi()
Date: Tue, 3 Apr 2012 11:55:47 -0700
Message-ID: <20120403115547.799fcc1f@s6510.linuxnetplumber.net>
References: <20120330173616.GC2703@Neptun>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47055 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755245Ab2DCSzv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Apr 2012 14:55:51 -0400
In-Reply-To: <20120330173616.GC2703@Neptun>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 30 Mar 2012 19:36:16 +0200
Lino Sanfilippo <LinoSanfilippo@gmx.de> wrote:

> In sky2_test_msi() the temporarily set SW IRQ in B0 register is not reset in case
> that request_irq() fails.
> With this patch we only set the interrupt mask if request_irq() was successful.
> 
> Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>

Ok, but this is a non-serious error case. If request_irq() fails here,
the driver is going to fail to load and on the failure path of
sky2_probe will reset the chip on the way out.

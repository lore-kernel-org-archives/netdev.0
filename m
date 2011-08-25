From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: cassini driver: Use of uninitialized memory
Date: Thu, 25 Aug 2011 15:58:45 +0200
Message-ID: <201108251558.45290.thomas.jarosch@intra2net.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rs04.intra2net.com ([85.214.66.2]:50463 "EHLO
	rs04.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751561Ab1HYOUK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2011 10:20:10 -0400
Received: from intranator.m.i2n (unknown [172.16.1.99])
	(using TLSv1 with cipher ADH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by rs04.intra2net.com (Postfix) with ESMTP id A3570220129
	for <netdev@vger.kernel.org>; Thu, 25 Aug 2011 15:58:46 +0200 (CEST)
Received: from localhost (intranator.m.i2n [127.0.0.1])
	by localhost (Postfix) with ESMTP id 634982AC54
	for <netdev@vger.kernel.org>; Thu, 25 Aug 2011 15:58:46 +0200 (CEST)
Received: from storm.localnet (storm.m.i2n [172.16.1.2])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: smtp-auth-user)
	by intranator.m.i2n (Postfix) with ESMTPSA id 858BD2AC52
	for <netdev@vger.kernel.org>; Thu, 25 Aug 2011 15:58:45 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

the interrupt routine of the cassini driver
currently looks like this:

----------------------
static irqreturn_t cas_interruptN(int irq, void *dev_id)
{
	struct net_device *dev = dev_id;
	struct cas *cp = netdev_priv(dev);
	unsigned long flags;
	int ring;
	u32 status = readl(cp->regs + REG_PLUS_INTRN_STATUS(ring));
...
----------------------

-> "ring" isn't initialized properly and gets used
in REG_PLUS_INTRN_STATUS. Some lines below there's this:

----------------------
	ring = (irq == cp->pci_irq_INTC) ? 2 : 3;
----------------------

Should that line be moved before the readl() call
or should "ring" be initialized with zero?

Credit for spotting this goes to cppcheck.

Cheers,
Thomas

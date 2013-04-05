From: Werner Almesberger <werner@almesberger.net>
Subject: Re: [Linux-zigbee-devel] [PATCH 2/2] at86rf230: change irq handling
 to prevent lockups with edge type irq
Date: Fri, 5 Apr 2013 07:51:58 -0300
Message-ID: <20130405105158.GD29789@ws>
References: <cover.1365107512.git.sascha@ps.nvbi.de>
 <57c67195742f5e7482dc57f5a05b6d69156b00d2.1365107512.git.sascha@ps.nvbi.de>
 <20130405035949.GC29789@ws>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net
To: Sascha Herrmann <sascha@ps.nvbi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.openmoko.org ([88.198.124.205]:50627 "EHLO
	mail.openmoko.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752141Ab3DEKxG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Apr 2013 06:53:06 -0400
Content-Disposition: inline
In-Reply-To: <20130405035949.GC29789@ws>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I wrote:
> To achieve perfection, at86rf230_probe could try all four
> possible trigger modes, pick one the platform supports, and
> set TRX_CTRL_1.IRQ_POLARITY accordingly.

Thinking of it, probing by trying request_irq has an unpleasant ring
to it. Perhaps a better way would be to leave this decision to the
platform code and do one of these:

1) pass irqflags and the polarity in the platform data, or

2) pass irqflags and extract the polarity from the irqflags, or

3) set up the trigger mode outside the driver and pass only the
   polarity,

where 1) with (irqflags & IRQF_TRIGGER_MASK) == 0 includes
case 3).

- Werner

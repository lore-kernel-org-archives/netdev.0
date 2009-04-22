From: Steve.Glendinning@smsc.com
Subject: Re: [PATCH] smsc911x: add fifo byteswap support
Date: Wed, 22 Apr 2009 16:21:32 +0100
Message-ID: <OFC89C8D8B.9962FD9A-ON802575A0.005335A8-802575A0.00545CBF@smsc.com>
References: <20090422145553.25073.99410.sendpatchset@rx1.opensource.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: davem@davemloft.net, iwamatsu@nigauri.org, lethal@linux-sh.org,
	Magnus Damm <magnus.damm@gmail.com>, netdev@vger.kernel.org,
	Ian.Saturley@smsc.com
To: Magnus Damm <magnus.damm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:2186 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753295AbZDVPVx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Apr 2009 11:21:53 -0400
In-Reply-To: <20090422145553.25073.99410.sendpatchset@rx1.opensource.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Magnus Damm <magnus.damm@gmail.com> wrote on 22/04/2009 15:55:53:

> From: Magnus Damm <damm@igel.co.jp>
> 
> This patch adds fifo byteswap support to the smsc911x driver.
> 
> The smsc911x hardware supports both big and little and endian
> hardware configurations, and the linux smsc911x driver currently
> detects word order.
> 
> For correct operation on big endian platforms lacking swapped
> byte lanes the following patch is needed. Only fifo data is
> swapped, register data does not require any swapping. 
> 
> Signed-off-by: Magnus Damm <damm@igel.co.jp>

I guess this is to work around a problem with hardware that's
already in production?

The best solution would be to swap the byte lanes in hardware,
as the device's endian swapping features only affect registers
(not the FIFOs).  The very latest devices in this family
(such as the LAN9221) can swap both independently, but this
driver has to also support older parts.

Performance will be suboptimal with this software byteswapping,
so I think we should also add a comment to stress that this is
a "last resort" workaround for broken hardware.

Acked-by: Steve Glendinning <steve.glendinning@smsc.com>

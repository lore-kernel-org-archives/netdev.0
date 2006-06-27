From: John Haller <jhaller@lucent.com>
Subject: Re: [PATCH 1/3] mv643xx fixes - Disable interrupts on all ports during
 initialization
Date: Tue, 27 Jun 2006 10:16:28 -0500
Message-ID: <44A14BCC.5060708@lucent.com>
References: <200606270951.59024.bcook@bpointsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ihemail1.lucent.com ([192.11.222.161]:45805 "EHLO
	ihemail1.lucent.com") by vger.kernel.org with ESMTP
	id S1161089AbWF0PQj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 11:16:39 -0400
To: Brent Cook <bcook@bpointsys.com>
In-Reply-To: <200606270951.59024.bcook@bpointsys.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brent Cook wrote:
> This patch disable interrupts on all ports during initialization. The current 
> assumes that the firmware has already disabled all interrupts on all ports. 
> We have encountered some boards that do not always disable interrupts (XES 
> XPedite 6200 for instance) on a soft reset. This patch prevents a kernel 
> panic if a packet is received before the DMA ring buffers are setup for a 
> port on which interrupts are left enabled by the firmware.
You probably have bigger problems than the interrupt being left
enabled.  If the interrupt is left enabled, the DMA engine
is probably left enabled, and if a packet happens
to come in before the driver can properly configure them,
some random part of memory will get overwritten.
The firmware needs to disable this device before transferring
control to the kernel, both the interrupts and the DMA,
there is no way to fix this in the kernel.

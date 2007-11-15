From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH 10/13] tg3: Increase the PCI MRRS
Date: Thu, 15 Nov 2007 14:20:10 -0800
Message-ID: <1195165211.20497.107.camel@teletran1>
References: <1194655141.5745.272.camel@teletran1>
 <20071112.212135.172019737.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mchan@broadcom.com
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2373 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757898AbXKOWT1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2007 17:19:27 -0500
In-Reply-To: <20071112.212135.172019737.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-11-12 at 21:21 -0800, David Miller wrote:
> From: "Matt Carlson" <mcarlson@broadcom.com>
> Date: Fri, 09 Nov 2007 16:39:01 -0800
> 
> > Previous devices hardcoded the PCI Maximum Read Request Size to 4K.  To
> > better comply with the PCI spec, the hardware now defaults the MRRS to
> > 512 bytes.  This will yield poor driver performance if left untouched.
> > This patch increases the MRRS to 4K on driver initialization.
> > 
> > Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> > Signed-off-by: Michael Chan <mchan@broadcom.com>
> 
> I've applied this patch, but...
> 
> I sense that the PCI spec wants devices to use an MRRS value of 512 in
> order to get better fairness on a PCI-E segment amongst multiple
> devices.
> 
> From that perspective, jacking up the MRRS to 4096 unilaterally seems
> like a very bad idea.  If this was necessary for good performance, I'm
> sure the PCI spec folks would have choosen a higher value.
> 
> Or is this some tg3 specific performance issue?

Keeping the MRRS at 512 introduces DMA latencies that effectively
prevent us from achieving linerate.  With a packet size of ~1.5K and the
MRRS at 512 bytes, the DMA will be broken into at least 3 DMA reads.
Each DMA read takes ~1usec to initiate.  It is this overhead that starts
to cut into total throughput.


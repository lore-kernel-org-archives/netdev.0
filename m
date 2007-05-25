From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH] s2io: don't run MSI handlers if device is offline.
Date: Fri, 25 May 2007 13:29:29 -0500
Message-ID: <20070525182929.GB4323@austin.ibm.com>
References: <20070522225029.GS5921@austin.ibm.com> <46560198.9080204@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, linux-pci@atrey.karlin.mff.cuni.cz,
	netdev@vger.kernel.org,
	Ramkrishna Vepa <Ramkrishna.Vepa@neterion.com>,
	Sivakumar Subramani <sivakumar.subramani@neterion.com>,
	Sreenivasa Honnur <sreenivasa.honnur@neterion.com>,
	Rastapur Santosh <santosh.rastapur@neterion.com>,
	Wen Xiong <wenxiong@us.ibm.com>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:50549 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763365AbXEYS3d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 May 2007 14:29:33 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4PHRLH1015321
	for <netdev@vger.kernel.org>; Fri, 25 May 2007 13:27:21 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4PITV2a412444
	for <netdev@vger.kernel.org>; Fri, 25 May 2007 14:29:31 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4PITUR5004453
	for <netdev@vger.kernel.org>; Fri, 25 May 2007 14:29:30 -0400
Content-Disposition: inline
In-Reply-To: <46560198.9080204@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 24, 2007 at 05:20:24PM -0400, Jeff Garzik wrote:
> Linas Vepstas wrote:
> >Don't run any of the MSI handlers if the channel is off;
> >also don't gather device statatistics. Also, netif_wake 
> >not needed, per suggestions from
> >Sivakumar Subramani <sivakumar.subramani@neterion.com>.
> >
> Why are the interrupt handlers being called at all, then?
> 
> This seems to be papering over another bug.

Ahh ... are you suggesting that the arch should be performing 
this check in driver-independent code, and not delivering the
MSI if the pci channel is deemed offline? Yes, right, good point. 

So far, I'd hadn't really given this much thought, and had been 
letting the dev drivers perform this check, but, yes, it is probably 
better to have one common check performed in the generic arch-specific 
code, and the interrupt dropped, if the device is offlined.

I'll look into this.

--linas

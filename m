From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: pci_set_consistent_dma_mask() question
Date: Sun, 25 May 2008 11:59:36 -0700
Message-ID: <20080525115936.7dbf2ecd@infradead.org>
References: <200805250843.47179.mitov@issp.bas.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Marin Mitov <mitov@issp.bas.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:44061 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755814AbYEYS7w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 May 2008 14:59:52 -0400
In-Reply-To: <200805250843.47179.mitov@issp.bas.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 25 May 2008 08:43:47 +0300
Marin Mitov <mitov@issp.bas.bg> wrote:

> Hi all,
> 
> In the file: Documentation/DMA-mapping.txt is written:
> 
> pci_set_consistent_dma_mask() will always be able to set the same or a
> smaller mask as pci_set_dma_mask(). However for the rare case that a
> device driver only uses consistent allocations, one would have to
> check the return value from pci_set_consistent_dma_mask().
> 
> grep-ing drivers/net/* shows that in many drivers 
> the return value of pci_set_consistent_dma_mask() is checked
> in the path where pci_set_dma_mask() was already successfull.
> Sure, this is during driver's initiallysation, so it is not time
> critical.
> 
> My question: Is it worth to remove the unnecessary checks?
> I could prepare patches if you find it worthfull.
> 

I think it would actually be harmful. Checking for errors even if they
shouldn't happen for things like this makes drivers better! If something
weird is going on it gets detected earlier... IN general, defensive
programming makes a lot of sense.

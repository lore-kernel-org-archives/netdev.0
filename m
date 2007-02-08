From: Timur Tabi <timur@freescale.com>
Subject: Re: [PATCH 1/4] ucc_geth: Change private immrbar_virt_to_phys to
 generic iopa
Date: Thu, 08 Feb 2007 07:35:08 -0600
Message-ID: <45CB270C.5090603@freescale.com>
References: <989B956029373F45A0B8AF02970818900D4401@zch01exm26.fsl.freescale.net> <17A046C6-5FD3-46D5-AB96-EAEDF22FA829@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Li Yang-r58472 <LeoLi@freescale.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:41682 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423021AbXBHNfO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Feb 2007 08:35:14 -0500
In-Reply-To: <17A046C6-5FD3-46D5-AB96-EAEDF22FA829@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kumar Gala wrote:

> Right, so when do you know if you'll be using MURAM or normal memory?  
> Why not just keep around a token that is the physical address at the 
> point you make the decision of MURAM vs normal memory.

That's what the original code did, kinda.  It called virt_to_phys() if 
it is main memory, and it called immrbar_virt_to_phys() if it is MURAM. 
  immrbar_virt_to_phys() did pointer math to extract the physical address.

I knew that Leo's patch was calling iopa() on main memory, but since it 
worked, I didn't think much about it.  But it does make some sense that 
since we obtain the physical address when we allocate the BD ring, we 
should store that address and use it.

That's what most drivers do, anyway, and so we should do the same thing. 
  So instead of p_tx_bd_ring[i], we would have p_tx_bd_ring[i].virtual 
and p_tx_bd_ring[i].physical.

Besides, iopa() is slower, because it walks page tables.



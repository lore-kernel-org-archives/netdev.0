From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 3/8] vxge: Align the memory only if it is
 misaligned.
Date: Mon, 29 Mar 2010 16:59:45 -0700 (PDT)
Message-ID: <20100329.165945.157920838.davem@davemloft.net>
References: <Pine.GSO.4.10.11003290409080.4435-100000@guinness>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, support@neterion.com
To: Sreenivasa.Honnur@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37179
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753252Ab0C2X7o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 19:59:44 -0400
In-Reply-To: <Pine.GSO.4.10.11003290409080.4435-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Date: Mon, 29 Mar 2010 04:09:47 -0400 (EDT)

> - Align the memory only if it is misaligned.
> 
> Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
> Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>

Applied, but this vxge_os_dma_malloc code is completely
unnecessary.

If you want to allocate 4K chunks and make sure they are at least 128
byte aligned, you can allocated pages (which are always PAGE_SIZE
aligned) and chop them up into the appropriate block size as needed.

This is exactly how drivers/net/niu.c handles this situation.

See drivers/net/niu.c:niu_rbr_add_page()

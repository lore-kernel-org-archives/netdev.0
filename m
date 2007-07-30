From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] NET_DMA: remove unused dma_memcpy_to_kernel_iovec
Date: Mon, 30 Jul 2007 19:14:51 +0100
Message-ID: <20070730181451.GA28616@infradead.org>
References: <20070725003606.11018.15141.stgit@localhost.localdomain> <20070726.000607.18303016.davem@davemloft.net> <bab433300707300739s283bf15fp9d00235cf39fa08b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, shannon.nelson@intel.com,
	netdev@vger.kernel.org, viro@ftp.linux.org.uk,
	christopher.leech@intel.com, andy.grover@gmail.com
To: pravin <pravin.shelar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:46710 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966576AbXG3SO6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 14:14:58 -0400
Content-Disposition: inline
In-Reply-To: <bab433300707300739s283bf15fp9d00235cf39fa08b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 30, 2007 at 08:09:53PM +0530, pravin wrote:
> comments?


please avoid using plain sendmsg/recvmsg from kernelspace.  Adding these
segment checks is more than a bad hack and not something that should
clutter up fasthpathes.  Add to that problems with kthreads vs blocking
recvmsg and you have a bigger mess than you can handle.


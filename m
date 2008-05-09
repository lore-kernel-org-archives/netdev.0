From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: atl1 64-bit => 32-bit DMA borkage (reproducible, bisected)
Date: Fri, 9 May 2008 23:51:49 +0400
Message-ID: <20080509195149.GA4985@martell.zuzino.mipt.ru>
References: <20080419215444.2d4623f5@osprey.hogchain.net> <20080420111453.GA4902@martell.zuzino.mipt.ru> <20080420060607.2b1be48b@osprey.hogchain.net> <20080420122631.GA4761@martell.zuzino.mipt.ru> <20080420133704.63f5cc10@osprey.hogchain.net> <20080420205500.GA4762@martell.zuzino.mipt.ru> <20080421210821.28053a92@osprey.hogchain.net> <20080425195743.2bfe66ee@osprey.hogchain.net> <20080504211507.GC1040@martell.zuzino.mipt.ru> <20080506110225.31fd61a4@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Luca Tettamanti <kronos.it@gmail.com>,
	Chris Snook <csnook@redhat.com>, Jeff Garzik <jeff@garzik.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Christoph Lameter <clameter@sgi.com>, torvalds@osdl.org
To: Jay Cliburn <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:3405 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763174AbYEIS43 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2008 14:56:29 -0400
Received: by nf-out-0910.google.com with SMTP id d3so759828nfc.21
        for <netdev@vger.kernel.org>; Fri, 09 May 2008 11:56:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080506110225.31fd61a4@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hmmm, there was a wonderful oops on interface stop here when the other end
of atl1 cable was physically unplugged (but there was traffic before):

	atl1_down
	atl1_clean_rx_ring
	swiotlb_unmap_single
	swiotlb_unmap_single_attrs
	memcpy_c


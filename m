From: "Nelson, Shannon" <shannon.nelson@intel.com>
Subject: RE: NET_DMA: where do we ever call dma_skb_copy_datagram_iovec() with NULL pinned_list?
Date: Tue, 24 Jul 2007 11:14:46 -0700
Message-ID: <BAE9DCEF64577A439B3A37F36F9B691C02BBE409@orsmsx418.amr.corp.intel.com>
References: <20070721034829.GL21668@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Leech, Christopher" <christopher.leech@intel.com>,
	"Andrew Grover" <andy.grover@gmail.com>
To: "Al Viro" <viro@ftp.linux.org.uk>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:51673 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764324AbXGXSOt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2007 14:14:49 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20070721034829.GL21668@ftp.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Al Viro:
>
>	AFAICS, all callers of dma_skb_copy_datagram_iovec()
>are either
>	* recursive for fragments, pass pinned_list unchanged or
>	* called from tcp, with pinned_list coming from
>tp->ucopy.pinned_list and only when tp->ucopy.dma_chan is non-NULL.
>
>Now, all non-NULL assignments to ->dma_chan have the same form:
>	if (!tp->ucopy.dma_chan && tp->ucopy.pinned_list)
>		tp->ucopy.dma_chan = get_softnet_dma();
>IOW, if ->ucopy.pinned_list stays NULL, ->ucopy.dma_chan will 
>do the same.
>
>Moreover, any place that resets ->ucopy.pinned_list will also reset
>->ucopy.dma_chan.
>
>IOW, we can't ever get non-NULL tp->ucopy.dma_chan while 
>tp->ucopy.pinned_list
>is NULL.  So how can we ever get to the dma_memcpy_to_kernel_iovec()?

It looks like this is "extra" code.  The history seems to be that it was
thought to be useful for internal copying, perhaps for smbfs or iSCSI,
as the comment suggests.  However, since no one is using it, it can
probably come out.  If there is no argument, I'll post a patch to remove
it.

sln
--
======================================================================
Mr. Shannon Nelson                 LAN Access Division, Intel Corp.
Shannon.Nelson@intel.com                I don't speak for Intel
(503) 712-7659                    Parents can't afford to be squeamish.

From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [ANNOUNCE] new driver ixgbe for Intel(R) 10GbE PCI Express adapters.
Date: Thu, 14 Jun 2007 01:05:13 +0200
Message-ID: <20070613230513.GB22521@electric-eye.fr.zoreil.com>
References: <20070612234417.5102.29147.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jeff@garzik.org, auke-jan.h.kok@intel.com,
	arjan@linux.intel.com, akpm@linux-foundation.org
To: Ayyappan.Veeraiyan@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:59905 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755709AbXFMXJs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2007 19:09:48 -0400
Content-Disposition: inline
In-Reply-To: <20070612234417.5102.29147.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ayyappan.Veeraiyan@intel.com <Ayyappan.Veeraiyan@intel.com> :
[...]
> Please review and provide comments.

o ixgbe_call_func and the ton of wrappers which go along with it
  should go.

o boolean_t duplicates the existing 'bool'

o The options below {should be/are} handled through ethtool:
  - TxDescriptors
  - RxDescriptors
  - XsumRX

o No __iomem annotations ?

o pci_alloc_consistent() returns a zeroed area: no need for memset.

o ixgbe_clean_tx_irq() is issued from the NAPI poll handler (as the
  name suggests...). Its locking will probably cause a deadlock if
  it is interrupted and a call to netpoll_send_skb follows.

-- 
Ueimor

From: tndave <tushar.n.dave@oracle.com>
Subject: i40e: Kernel unaligned access due to 'struct i40e_dma_mem' being
 'packed'
Date: Wed, 27 Jan 2016 17:50:14 -0800
Message-ID: <56A973D6.4060202@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tushar.n.dave@oracle.com
To: netdev@vger.kernel.org,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Nelson, Shannon" <shannon.nelson@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	mitch.a.williams@intel.com, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:18763 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932213AbcA1BuT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2016 20:50:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

i40e driver has 'struct i40e_dma_mem' defined with 'packed' directive
causing kernel unaligned errors on sparc (when 40e_allocate_dma_mem_d()
is being called)

log_unaligned: 1031 callbacks suppressed
Kernel unaligned access at TPC[448ae8] dma_4v_alloc_coherent+0x188/0x2e0
Kernel unaligned access at TPC[448ae8] dma_4v_alloc_coherent+0x188/0x2e0
Kernel unaligned access at TPC[448ae8] dma_4v_alloc_coherent+0x188/0x2e0
Kernel unaligned access at TPC[448ae8] dma_4v_alloc_coherent+0x188/0x2e0

This can be fixed with get_unaligned/put_unaligned(). However I don't
see 'struct i40e_dma_mem' is being directly shoved into NIC hardware.
But instead fields of the struct are being read and used for hardware
(e.g. dma_addr_t pa). For the test, I remove __packed, and i40e driver
and HW works fine. (of course kernel unaligned errors are gone too).
My question is, does 'struct i40e_dma_mem' required to be __packed?

Thanks.

-Tushar

From: "Jay Hernandez" <jay@chelsio.com>
Subject: RE: drivers/net/ethernet/chelsio/cxgb4/t4_hw.c:363:64: sparse: incorrect type in argument 3 (different base types)
Date: Mon, 1 Oct 2012 17:48:55 -0700
Message-ID: <8A71B368A89016469F72CD08050AD3340C527934@maui.asicdesigners.com>
References: <20120928163653.GC5171@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <kernel-janitors@vger.kernel.org>, <netdev@vger.kernel.org>,
	"Jay Hernandez" <jay@chelsio.com>
To: "Fengguang Wu" <fengguang.wu@intel.com>,
	"Vipul Pandya" <vipul@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:31831 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751989Ab2JBBJP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2012 21:09:15 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Fengguang,

Thanks for pointing this out we have a fix which addresses these issues.
What's interesting is I did not see these warnings I tried to reproduce
the errors on my setup. Is there a special flag we can use to reproduce
the sparse warnings.

Thanks for your help,
Jay-

-----Original Message-----
From: Fengguang Wu [mailto:fengguang.wu@intel.com] 
Sent: Friday, September 28, 2012 9:37 AM
To: Vipul Pandya
Cc: kernel-janitors@vger.kernel.org; Jay Hernandez;
netdev@vger.kernel.org
Subject: drivers/net/ethernet/chelsio/cxgb4/t4_hw.c:363:64: sparse:
incorrect type in argument 3 (different base types)

Hi Vipul,

FYI, there are new sparse warnings show up in

commit: 5afc8b84eb7b29e4646d6e8ca7e6d7196031d6f7  cxgb4: Add functions
to read memory via PCIE memory window

  drivers/net/ethernet/chelsio/cxgb4/t4_hw.c:361:33: sparse: incorrect
type in assignment (different base types)
  drivers/net/ethernet/chelsio/cxgb4/t4_hw.c:361:33:    expected
restricted __be32 [usertype] <noident>
  drivers/net/ethernet/chelsio/cxgb4/t4_hw.c:361:33:    got unsigned int
+ drivers/net/ethernet/chelsio/cxgb4/t4_hw.c:363:64: sparse: incorrect
type in argument 3 (different base types)
  drivers/net/ethernet/chelsio/cxgb4/t4_hw.c:363:64:    expected
unsigned int [unsigned] [usertype] val
  drivers/net/ethernet/chelsio/cxgb4/t4_hw.c:363:64:    got restricted
__be32 [usertype] <noident>
  drivers/net/ethernet/chelsio/cxgb4/t4_hw.c:694:31: sparse: incorrect
type in assignment (different base types)
  drivers/net/ethernet/chelsio/cxgb4/t4_hw.c:694:31:    expected
unsigned int [unsigned] [usertype] <noident>
  drivers/net/ethernet/chelsio/cxgb4/t4_hw.c:694:31:    got restricted
__be32 [usertype] <noident>
  drivers/net/ethernet/chelsio/cxgb4/t4_hw.c:898:25: sparse: cast to
restricted __be32
  drivers/net/ethernet/chelsio/cxgb4/t4_hw.c:898:25: sparse: cast to
restricted __be32
  drivers/net/ethernet/chelsio/cxgb4/t4_hw.c:898:25: sparse: cast to
restricted __be32
  drivers/net/ethernet/chelsio/cxgb4/t4_hw.c:898:25: sparse: cast to
restricted __be32
  drivers/net/ethernet/chelsio/cxgb4/t4_hw.c:898:25: sparse: cast to
restricted __be32
  drivers/net/ethernet/chelsio/cxgb4/t4_hw.c:898:25: sparse: cast to
restricted __be32
  drivers/net/ethernet/chelsio/cxgb4/t4_hw.c:2177:25: sparse: incorrect
type in assignment (different base types)
  drivers/net/ethernet/chelsio/cxgb4/t4_hw.c:2177:25:    expected
restricted __be32 [usertype] <noident>
  drivers/net/ethernet/chelsio/cxgb4/t4_hw.c:2177:25:    got unsigned
int
  drivers/net/ethernet/chelsio/cxgb4/t4_hw.c: In function
't4_memory_rw.constprop.6':
  drivers/net/ethernet/chelsio/cxgb4/t4_hw.c:462:1: warning: the frame
size of 2056 bytes is larger than 1024 bytes [-Wframe-larger-than=]

vim +363 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c

5afc8b84 (Vipul Pandya 2012-09-26  347) 
5afc8b84 (Vipul Pandya 2012-09-26  348) 	/*
5afc8b84 (Vipul Pandya 2012-09-26  349) 	 * Setup offset into
PCIE memory window.  Address must be a
5afc8b84 (Vipul Pandya 2012-09-26  350) 	 *
MEMWIN0_APERTURE-byte-aligned address.  (Read back MA register to
5afc8b84 (Vipul Pandya 2012-09-26  351) 	 * ensure that changes
propagate before we attempt to use the new
5afc8b84 (Vipul Pandya 2012-09-26  352) 	 * values.)
5afc8b84 (Vipul Pandya 2012-09-26  353) 	 */
5afc8b84 (Vipul Pandya 2012-09-26  354) 	t4_write_reg(adap,
PCIE_MEM_ACCESS_OFFSET,
5afc8b84 (Vipul Pandya 2012-09-26  355) 		     addr &
~(MEMWIN0_APERTURE - 1));
5afc8b84 (Vipul Pandya 2012-09-26  356) 	t4_read_reg(adap,
PCIE_MEM_ACCESS_OFFSET);
5afc8b84 (Vipul Pandya 2012-09-26  357) 
5afc8b84 (Vipul Pandya 2012-09-26  358) 	/* Collecting data 4
bytes at a time upto MEMWIN0_APERTURE */
5afc8b84 (Vipul Pandya 2012-09-26  359) 	for (i = 0; i <
MEMWIN0_APERTURE; i = i+0x4) {
5afc8b84 (Vipul Pandya 2012-09-26  360) 		if (dir)
5afc8b84 (Vipul Pandya 2012-09-26  361) 			*data++
= t4_read_reg(adap, (MEMWIN0_BASE + i));
5afc8b84 (Vipul Pandya 2012-09-26  362) 		else
5afc8b84 (Vipul Pandya 2012-09-26 @363)
t4_write_reg(adap, (MEMWIN0_BASE + i), *data++);
5afc8b84 (Vipul Pandya 2012-09-26  364) 	}
5afc8b84 (Vipul Pandya 2012-09-26  365) 
5afc8b84 (Vipul Pandya 2012-09-26  366) 	return 0;
5afc8b84 (Vipul Pandya 2012-09-26  367) }
5afc8b84 (Vipul Pandya 2012-09-26  368) 
5afc8b84 (Vipul Pandya 2012-09-26  369) /**
5afc8b84 (Vipul Pandya 2012-09-26  370)  *	t4_memory_rw -
read/write EDC 0, EDC 1 or MC via PCIE memory window
5afc8b84 (Vipul Pandya 2012-09-26  371)  *	@adap: the adapter

---
0-DAY kernel build testing backend         Open Source Technology Centre
Fengguang Wu, Yuanhan Liu                              Intel Corporation

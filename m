From: "J. K. Cliburn" <jcliburn@gmail.com>
Subject: Re: atl1e Ethernet driver not seeing packets sent to
 33:33:00:00:00:01 multicast
Date: Tue, 11 Nov 2008 10:08:16 -0600
Message-ID: <20081111100816.58a7cf09@osprey.hogchain.net>
References: <20081111133108.GA7124@clipper.ens.fr>
	<20081111080611.7f6d4371@osprey.hogchain.net>
	<20081111155908.GA14665@clipper.ens.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing-List <linux-kernel@vger.kernel.org>,
	Linux NetDev Mailing-List <netdev@vger.kernel.org>,
	atl1-devel@lists.sourceforge.net
To: David Madore <david.madore@ens.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.168]:17865 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752743AbYKKQIW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2008 11:08:22 -0500
Received: by wf-out-1314.google.com with SMTP id 27so3249803wfd.4
        for <netdev@vger.kernel.org>; Tue, 11 Nov 2008 08:08:21 -0800 (PST)
In-Reply-To: <20081111155908.GA14665@clipper.ens.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 11 Nov 2008 16:59:08 +0100
David Madore <david.madore@ens.fr> wrote:

> On Tue, Nov 11, 2008 at 08:06:11AM -0600, J. K. Cliburn wrote:
> > Just to verify your system is fitted with the L1e and not the L1
> > chip, can you please provide the output of lspci -vvnn?
> 
> Here goes (adapter in question is at the very end):

Thanks.

Can you please try this patch?

diff --git a/drivers/net/atl1e/atl1e_hw.c b/drivers/net/atl1e/atl1e_hw.c
index 949e753..c0d5f7c 100644
--- a/drivers/net/atl1e/atl1e_hw.c
+++ b/drivers/net/atl1e/atl1e_hw.c
@@ -163,9 +163,6 @@ int atl1e_read_mac_addr(struct atl1e_hw *hw)
  * atl1e_hash_mc_addr
  *  purpose
  *      set hash value for a multicast address
- *      hash calcu processing :
- *          1. calcu 32bit CRC for multicast address
- *          2. reverse crc with MSB to LSB
  */
 u32 atl1e_hash_mc_addr(struct atl1e_hw *hw, u8 *mc_addr)
 {
@@ -174,7 +171,6 @@ u32 atl1e_hash_mc_addr(struct atl1e_hw *hw, u8 *mc_addr)
 	int i;
 
 	crc32 = ether_crc_le(6, mc_addr);
-	crc32 = ~crc32;
 	for (i = 0; i < 32; i++)
 		value |= (((crc32 >> i) & 1) << (31 - i));
 
-- 
1.5.6.5

From: David Miller <davem@davemloft.net>
Subject: Re: [linux-2.6.34-rc3] drivers/net: ks8851 MLL ethernet network
 driver
Date: Wed, 14 Apr 2010 23:38:13 -0700 (PDT)
Message-ID: <20100414.233813.219246642.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David.Choi@Micrel.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37610
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751325Ab0DOGiJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 02:38:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I cannot apply this, there are too many issues:

@@ -378,34 +384,34 @@ union ks_tx_hdr {
 
 /**
  * struct ks_net - KS8851 driver private data
- * @net_device 	: The network device we're bound to
+ * @net_device	: The network device we're bound to
  * @hw_addr	: start address of data register.

Do not mix lots of coding style and functional changes.

If you want to fix coding style, do it later in a seperate
patch after you implement your functional change.

+	if (!reg_data & CCR_ENDIAN) {

This test will never do what you want it to do.

First the compiler will evaluate "!reg_data" which will be either "0"
or "1", then it will and it with the CCR_ENDIAN mask, which is (1 <<
10).  And this can never be true.

I also do not like all of the endian ifdefs peppered all over the
driver.  Try consolidate this by creating a header file that contains
the structure and macro definitions, and in there create helper inline
functions which do the ifdefs.  This way the ks8851_mll.c file can
stay ifdef clean.

Thanks.


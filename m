From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 3/4] net: stmmac: add support for Intel Quark X1000
Date: Wed, 17 Sep 2014 00:55:32 -0400 (EDT)
Message-ID: <20140917.005532.2054822778882237895.davem@davemloft.net>
References: <F54AEECA5E2B9541821D670476DAE19C2B7E99A7@PGSMSX102.gar.corp.intel.com>
	<20140916.150037.1715537913178712290.davem@davemloft.net>
	<F54AEECA5E2B9541821D670476DAE19C2B7E9DCA@PGSMSX102.gar.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, rayagond@vayavyalabs.com,
	vbridgers2013@gmail.com, srinivas.kandagatla@st.com, wens@csie.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	boon.leong.ong@intel.com
To: hock.leong.kweh@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <F54AEECA5E2B9541821D670476DAE19C2B7E9DCA@PGSMSX102.gar.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>
Date: Wed, 17 Sep 2014 02:41:39 +0000

> Thanks for the pointer. I did a quickly checking on the class number to see if
> I could use it for differentiation the ports number. Whereas I found them 
> both have the same class number as well. Below shows the "lspci" dump to 
> all the PCI devices on Quark X1000 Galileo board (Ethernet controllers are
> 00:14.6 and 00:14.7). Very unfortunately we are unlikely to use the class 
> number as well as pci_device_id for the differentiation.
 ...
> 00:14.6 "Class 0200" "8086" "0937" "8086" "0937"
> 00:14.7 "Class 0200" "8086" "0937" "8086" "0937"

Are you kidding me?  It's a perfect way to identify this device, it
properly uses PCI_CLASS_NETWORK_ETHERNET (0x0200) in both cases and
this will not match any other function on this PCI device at all.

Please do as I suggested and use the PCI class for the differentiation
and matching during probing.

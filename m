From: linas@austin.ibm.com (Linas Vepstas)
Subject: ixgb EEH/PCI errors on reset
Date: Fri, 23 Jun 2006 12:09:58 -0500
Message-ID: <20060623170958.GN8866@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:45987 "EHLO e5.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1751781AbWFWRKD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2006 13:10:03 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k5NHA0Ff017541
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Fri, 23 Jun 2006 13:10:01 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5NH9xgq284092
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 23 Jun 2006 13:10:00 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5NH9xi5026061
	for <netdev@vger.kernel.org>; Fri, 23 Jun 2006 13:09:59 -0400
To: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>, cramerj@intel.com,
	jeffrey.t.kirsher@intel.com, auke-jan.h.kok@intel.com,
	ayyappan.veeraiyan@intel.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Hi,

I've got another ixgb driver bug I'm struggling with; clues or hints
appreciated.

I've got a patch for PCI error recovery for the ixgb, which works on 
many older kernels but seems to be broken on linux-2.6.17-rc6-mm2
(which is ixgb version 1.0.109).  After performing a PCI reset on the 
card, I try to re-initialize the cad and the driver, with the following
sequence:

   pci_set_master(pdev);
   netif_carrier_off(netdev);
   netif_stop_queue(netdev);
   ixgb_check_options(adapter);
   ixgb_reset(adapter);

This is only a subset of the ixgb_probe code, since I don't need to 
request regions or do any of the other setup.  However, this code 
fails in an unexpected way.  The last call invokes ixgb_mac_reset()
which writes a reset bit, delays a few millisecs, and reads the reset
bit.  The problem I'm seeing is that the read 

  ctrl_reg = IXGB_READ_REG(hw, CTRL0);

triggers some PCI bus error that off-lines the device. Any hints
about where to look? This doesn't occur on other driver versions,
and doesn't occur on this driver during the ordinary probe() sequence.
Increasing the dealy doesn't seem to help. 

--linas



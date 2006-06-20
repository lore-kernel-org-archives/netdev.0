From: linas@austin.ibm.com (Linas Vepstas)
Subject: Intel ixgb driver bug in linux-2.6.17-rc6-mm2
Date: Tue, 20 Jun 2006 14:35:35 -0500
Message-ID: <20060620193535.GG9200@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-pci@atrey.karlin.mff.cuni.cz, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:19363 "EHLO
	e33.co.us.ibm.com") by vger.kernel.org with ESMTP id S1750813AbWFTTfk
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 15:35:40 -0400
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e33.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k5KJZdYt016921
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 20 Jun 2006 15:35:40 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by westrelay02.boulder.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5KJZGv6266504
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 20 Jun 2006 13:35:16 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5KJZavS011489
	for <netdev@vger.kernel.org>; Tue, 20 Jun 2006 13:35:37 -0600
To: jeffrey.t.kirsher@intel.com, ayyappan.veeraiyan@intel.com,
	john.ronciak@intel.com, jesse.brandeburg@intel.com,
	auke-jan.h.kok@intel.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

I sat down to do some testing of the ixgb driver a few days ago, and
get failures within seconds.  From what I can tell, I'm getting either a
DMA to a bad address or some other PCI bus error, not sure which. 
The problem appears to happen only for the driver that's in
2.6.17-rc6-mm2. As a sanity check, I'm testing the SuSE SLES10 beta,
which is 2.6.16 based, and it doesn't seem to have any problems.

My test is dirt-simple: telnet to the chargen port.  After an eyeblink,
I get the pci bus error, that's that. "eyeblink" is after about 300MBytes
transfered.  That was with a driver with NAPI enabled. I tried again
with NAPI disabled, and got to about 1.8 GB transfered in two eyeblinks.

To make sure that I'm not dealing with faulty hardware, I tried the same
thing w/ SLES10 2.6.16.18-1.8  and have gotten to RX bytes:20889480686
(19921.7 Mb) so far, with no problems. I don't have easy access to a PCI
bus analyzer, otherwise, I'd tell you more. Ideas? Suggestions? 

I could try taking the diff between these two driver versions, and
seeing what change caused the problem, but thought I should email first,
before doing that.

--linas

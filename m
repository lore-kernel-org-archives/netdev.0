From: Henning Fehrmann <henning.fehrmann@aei.mpg.de>
Subject: loosing IPMI-card by loading netconsole
Date: Fri, 14 May 2010 15:45:44 +0200
Message-ID: <20100514134544.GA26674@gretchen.aei.mpg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	John Ronciak <john.ronciak@intel.com>, netdev@vger.kernel.org,
	Matt Mackall <mpm@selenic.com>,
	Carsten Aulbert <carsten.aulbert@aei.mpg.de>,
	Tejun Heo <tj@kernel.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ox1.aei.mpg.de ([194.94.224.6]:54116 "EHLO ox1.aei.mpg.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752324Ab0ENOMA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 May 2010 10:12:00 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

We have SuperMicro PDSM 2+ boards together with 82573E and 82573L Intel NICs.
Additional we have IPMI cards which are tunneled via the 82573E NIC.

We are using the e1000e driver for NICs together with the netconsole driver.
(netconsole netconsole=4444@client_IP/eth1,514@server_IP/server_MAC). Netconsole
is using the NIC which is NOT used by the IPMI card.

Usually we are able to access the IPMI card remotely with ipmitools.

Having the kernel 2.6.27.39 installed everything worked together, the NICs, remotely 
accessing the IPMI cards and netconsole.

The driver version of e1000e is 0.3.3.3-k6. 

Using a more recent kernel: 2.6.32.7 we lost the ability of remotely accessing the IPMI card
when the netconsole driver is loaded. 
The IPMI card is accessible before the netconsole driver is loaded and disappears 
once we use netconsole. Even unloading netconsole does not help then.

We get the IPMI card back when 'removing' eth0:
echo 1 > /sys/devices/pci0000:00/0000:00:1c.4/0000:0d:00.0/remove

0d:00.0 is eth0.


The version of the e1000e driver is 1.0.2-k2.

I compiled and loaded a later version of this driver (1.1.19) without solving this problem.


For eth0 (82573E) we have a firmware version 0.15-4 installed and for eth1 we use the firmware 
version 0.5-7. But this is the same for both kernel versions. 

Do you have an idea? 

Thank you and cheers,
Henning


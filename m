From: "Nelson, Shannon" <shannon.nelson@intel.com>
Subject: RE: [net-next 10/17] i40e: clean up PTP log messages
Date: Thu, 15 Jan 2015 15:01:42 +0000
Message-ID: <FC41C24E35F18A40888AACA1A36F3E418ADD011A@fmsmsx115.amr.corp.intel.com>
References: <1421324368-6860-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1421324368-6860-11-git-send-email-jeffrey.t.kirsher@intel.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CAC9AB0@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>,
	"Keller, Jacob E" <jacob.e.keller@intel.com>
To: David Laight <David.Laight@ACULAB.COM>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:58158 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753988AbbAOPBq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 10:01:46 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CAC9AB0@AcuExch.aculab.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: David Laight [mailto:David.Laight@ACULAB.COM]
> Sent: Thursday, January 15, 2015 4:35 AM
> 
> From: Jeff Kirsher
> > From: Shannon Nelson <shannon.nelson@intel.com>
> >
> > The netdev name at init time often defaults to eth0 but later gets
> changed
> > by UDEV, so printing it here is misleading.
> 
> Without the interface name you stand zero chance of working out which
> one it is.
> With it, and provided all the interface renames get into dmesg, you
> stand
> at least some chance.

The dev_info() messages have the PCI device and function number in the string, so it's really not too hard to track down the resulting netdev port:
Jan 13 15:46:55 snelson3-cup kernel: [621235.401627] i40e 0000:84:00.1: PHC enabled

Later messages use netdev_info() and have both the device number and the netdev name:
Jan 13 15:46:56 snelson3-cup kernel: [621236.508868] i40e 0000:04:00.1 p261p2: NIC Link is Up 10 Gbps Full Duplex, Flow Control: None

Note that the driver name appears in both as well.

sln

From: "Christian Benvenuti (benve)" <benve@cisco.com>
Subject: RE: [patch] enic: fix an endian bug in enic_probe()
Date: Thu, 1 Mar 2012 19:23:45 -0600
Message-ID: <184D23435BECB444AB6B9D4630C8EC8303853051@XMB-RCD-303.cisco.com>
References: <20120301071954.GA7152@elgon.mountain> <20120301.172408.1182768164929080163.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Roopa Prabhu (roprabhu)" <roprabhu@cisco.com>,
	"Neel Patel (neepatel)" <neepatel@cisco.com>,
	"Nishank Trivedi (nistrive)" <nistrive@cisco.com>,
	<netdev@vger.kernel.org>, <kernel-janitors@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>, <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcdn-iport-8.cisco.com ([173.37.86.79]:27632 "EHLO
	rcdn-iport-8.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752091Ab2CBBdW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2012 20:33:22 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20120301.172408.1182768164929080163.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Dan, David.

Just one quick comment...
pci_enable_sriov's 2nd input is declared as type int and we
were using u32 instead (for a non negative 16bit value).
With a quick check I noticed that other pci_enable_sriov callers
do something similar and may need to be taken care too:

driver    |  type used
----------+--------------
mlx4      | int
chelsio   | unsigned int
igb       | unsigned int   
igbxe     | unsigned int
emulex    | u32
vxge      | u32


Another option would have been to make all drivers use int
to match pci_enable_sriov (pci_enable_sriov->sriov_enable checks
against negative values).

(BTW, why is pci_enable_sriov prototype using int?)

Thanks
/Chris

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, March 01, 2012 2:24 PM
> To: dan.carpenter@oracle.com
> Cc: Roopa Prabhu (roprabhu); Christian Benvenuti (benve); Neel Patel
> (neepatel); Nishank Trivedi (nistrive); netdev@vger.kernel.org;
kernel-
> janitors@vger.kernel.org
> Subject: Re: [patch] enic: fix an endian bug in enic_probe()
> 
> From: Dan Carpenter <dan.carpenter@oracle.com>
> Date: Thu, 1 Mar 2012 10:19:54 +0300
> 
> > "num_vfs" is a u32 but we only use the high 16 bits and the low
> 16bits
> > are left as zero.  That isn't a problem for little endian systems
but
> it
> > will break on big endian ones.
> >
> > Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> Applied.

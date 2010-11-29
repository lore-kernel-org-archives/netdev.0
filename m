From: Matt Domsch <Matt_Domsch@dell.com>
Subject: Re: [PATCH net-next] bnx2x: Add Nic partitioning mode (57712 devices)
Date: Mon, 29 Nov 2010 00:01:14 -0600
Message-ID: <20101129060114.GC29904@auslistsprd01.us.dell.com>
References: <1290982177.6066.3.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Eilon Greenstein <eilong@broadcom.com>, narendra_k@dell.com,
	jordan_hargrave@dell.com
To: Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausxippc101.us.dell.com ([143.166.85.207]:41679 "EHLO
	ausxippc101.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751732Ab0K2GBV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Nov 2010 01:01:21 -0500
Content-Disposition: inline
In-Reply-To: <1290982177.6066.3.camel@lb-tlvb-dmitry>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 29, 2010 at 12:09:37AM +0200, Dmitry Kravkov wrote:
> NIC partitioning is another flavor of multi function - having few
> PCI functions share the same physical port. Unlike the currently
> supported mode of multi-function which depends on the switch
> configuration and uses outer-VLAN, the NPAR mode is switch independent
> and uses the MAC addresses to distribute incoming packets to the different
> functions. This patch adds the specific HW setting of the NPAR mode
> and some distinctions between switch dependent (SD) and
> switch independent (SI) multi-function (MF) modes where the configuration
> is not the same.

Just as SR-IOV introduced sysfs pointers between VF and PF devices:
/sys/bus/pci/devices/pci0000:00/0000:00:09.0/0000:05:00.0/virtfn0 ->  ../0000:05:10.0/
/sys/bus/pci/devices/pci0000:00/0000:00:09.0/0000:05:10.0/physfn ->   ../0000:05:00.0/

I would like to see a similar relationship exposed in sysfs for NPAR
partitions and their respective ports.  This will let biosdevname
accurately name NPAR devices according to the scheme:

  pci<slot>#<port>_<virtual function>

just as it does for SR-IOV devices.  Is there one parent partition
that the child partitions could point back to, or other way to group
all the partitions of a single port?

Thanks,
Matt

-- 
Matt Domsch
Technology Strategist
Dell | Office of the CTO

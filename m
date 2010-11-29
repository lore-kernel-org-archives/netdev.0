From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH net-next] bnx2x: Add Nic partitioning mode (57712
 devices)
Date: Mon, 29 Nov 2010 11:33:12 +0200
Message-ID: <1291023192.9770.0.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1290982177.6066.3.camel@lb-tlvb-dmitry>
 <20101129060114.GC29904@auslistsprd01.us.dell.com>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"narendra_k@dell.com" <narendra_k@dell.com>,
	"jordan_hargrave@dell.com" <jordan_hargrave@dell.com>
To: "Matt Domsch" <Matt_Domsch@dell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4863 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752199Ab0K2JeN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Nov 2010 04:34:13 -0500
In-Reply-To: <20101129060114.GC29904@auslistsprd01.us.dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2010-11-28 at 22:01 -0800, Matt Domsch wrote:
> On Mon, Nov 29, 2010 at 12:09:37AM +0200, Dmitry Kravkov wrote:
> > NIC partitioning is another flavor of multi function - having few
> > PCI functions share the same physical port. Unlike the currently
> > supported mode of multi-function which depends on the switch
> > configuration and uses outer-VLAN, the NPAR mode is switch independent
> > and uses the MAC addresses to distribute incoming packets to the different
> > functions. This patch adds the specific HW setting of the NPAR mode
> > and some distinctions between switch dependent (SD) and
> > switch independent (SI) multi-function (MF) modes where the configuration
> > is not the same.
> 
> Just as SR-IOV introduced sysfs pointers between VF and PF devices:
> /sys/bus/pci/devices/pci0000:00/0000:00:09.0/0000:05:00.0/virtfn0 ->  ../0000:05:10.0/
> /sys/bus/pci/devices/pci0000:00/0000:00:09.0/0000:05:10.0/physfn ->   ../0000:05:00.0/
> 
> I would like to see a similar relationship exposed in sysfs for NPAR
> partitions and their respective ports.  This will let biosdevname
> accurately name NPAR devices according to the scheme:
> 
>   pci<slot>#<port>_<virtual function>
> 
> just as it does for SR-IOV devices.  Is there one parent partition
> that the child partitions could point back to, or other way to group
> all the partitions of a single port?

The main difference here is that we are talking about multiple PFs - so
each can be brought up or down independently of the others. So there is
no one master PF that controls the port and once it is brought down, the
port is down too. At any given moment, one of the PFs is acting as the
port master and controls the shared HW - but once this PF is brought
down, another PF is seamlessly taking over.

I think the main difference is that we have real PCI functions and not
virtual ones. On the same PCI bus, we have two physical ports, and 8
physical functions - 4 on each port. I agree that exposing which
functions are using the same port can really help - so I'm open to
suggestions on the "how".

Thanks,
Eilon





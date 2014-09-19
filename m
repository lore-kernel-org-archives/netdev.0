From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [net-next PATCH 00/29] Add support for the Intel FM10000 Ethernet
 Switch Host Interface
Date: Fri, 19 Sep 2014 07:54:38 -0700
Message-ID: <541C43AE.3030402@intel.com>
References: <20140918223242.10373.27403.stgit@ahduyck-bv4.jf.intel.com> <541C0C01.6080708@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: nhorman@redhat.com, netdev@vger.kernel.org,
	john.fastabend@gmail.com, matthew.vick@intel.com,
	jeffrey.t.kirsher@intel.com, sassmann@redhat.com
To: Jamal Hadi Salim <jhs@mojatatu.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:54741 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756553AbaISOyz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Sep 2014 10:54:55 -0400
In-Reply-To: <541C0C01.6080708@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/19/2014 03:57 AM, Jamal Hadi Salim wrote:
> On 09/18/14 18:35, Alexander Duyck wrote:
>> This patch series adds support for the FM10000 Ethernet switch host
>> interface.  The Intel FM10000 Ethernet Switch is a 48-port Ethernet
>> switch
>> supporting both Ethernet ports and PCI Express host interfaces.  The
>> fm10k
>> driver provides support for the host interface portion of the switch,
>> both
>> PF and VF.
>>
>> As the host interfaces are directly connected to the switch this
>> results in
>> some significant differences versus a standard network driver.  For
>> example
>> there is no PHY or MII on the device.  Since packets are delivered
>> directly
>> from the switch to the host interface these are unnecessary. 
>> Otherwise most
>> of the functionality is very similar to our other network drivers such as
>> ixgbe or igb.  For example we support all the standard network offloads,
>> jumbo frames, SR-IOV (64 VFS), PTP, and some VXLAN and NVGRE offloads.
>>
> 
> First off Kudos to the intel folks. Hopefully this is one of many such
> drivers coming - and lets hope this is as landscape-changing as the
> e1000 was ;-> Broadcom smell that Tim Horton's coffee.

Thanks.  Though just to be clear it is just the host interface, not the
entire switch that this driver supports.

> You described this as a switch but then expose it as a glorified nic.
> Assuming more goodstuff(tm) coming?

Since the switch can support up to 9 of these we are treating the host
interface driver as though it is a NIC driver.  We need to usually ship
NIC drivers well ahead of the silicon so that it can make it into the
distributions before the silicon is actually released, thus avoiding the
need for a driver disk to do a network install on a system with one of
these on board.

I don't have any hard dates on when anything else related to the switch
might be released.  That is being managed by another team and I don't
have visibility to that information.

Thanks,

Alex

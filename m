From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [net-next PATCH 00/29] Add support for the Intel FM10000 Ethernet
 Switch Host Interface
Date: Fri, 19 Sep 2014 07:43:04 -0700
Message-ID: <541C40F8.5080802@intel.com>
References: <20140918223242.10373.27403.stgit@ahduyck-bv4.jf.intel.com> <20140919075556.GC1980@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: davem@davemloft.net, nhorman@redhat.com, netdev@vger.kernel.org,
	john.fastabend@gmail.com, matthew.vick@intel.com,
	jeffrey.t.kirsher@intel.com, sassmann@redhat.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:12743 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756766AbaISOnF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Sep 2014 10:43:05 -0400
In-Reply-To: <20140919075556.GC1980@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/19/2014 12:55 AM, Jiri Pirko wrote:
> Fri, Sep 19, 2014 at 12:35:37AM CEST, alexander.h.duyck@intel.com wrote:
>> This patch series adds support for the FM10000 Ethernet switch host
>> interface.  The Intel FM10000 Ethernet Switch is a 48-port Ethernet switch
>> supporting both Ethernet ports and PCI Express host interfaces.  The fm10k
>> driver provides support for the host interface portion of the switch, both
>> PF and VF.
>>
>> As the host interfaces are directly connected to the switch this results in
>> some significant differences versus a standard network driver.  For example
>> there is no PHY or MII on the device.  Since packets are delivered directly
>>from the switch to the host interface these are unnecessary.  Otherwise most
>> of the functionality is very similar to our other network drivers such as
>> ixgbe or igb.  For example we support all the standard network offloads,
>> jumbo frames, SR-IOV (64 VFS), PTP, and some VXLAN and NVGRE offloads.
> 
> I'm very happy to see this patchset in the wind. Great news! I have
> couple of questions:
> 
> Do you also plan to introduce support for FM6000?
> 
> From what I understand, there is one netdev instance for the whole switch (PF).
> How can user get stats and info for particular ports? This topic was
> discussed many times and I believe that general consensus is to have 1
> netdev instance to represent one switch port (that is for example how we
> do it in rocker driver).
> 
> Thanks.
> 

Just to be clear this isn't the entire switch.  This is only the host
interface that this driver supports.  The host interface is essentially
just an embedded NIC on the switch.

In regards to your question about the netdev instances for the ports
that would be up to the switch driver.  We are still debating some of
the implementation details of that.  For example we are still trying to
decide if the switch should be a part of the fm10k driver or if it
should be a separate driver onto itself similar to how the DSA driver
model works.  My preference is the latter, but that isn't my decision as
I am only responsible for the host interface.

As far as the FM6000 goes I can't say.  I don't have visibility into
what the team responsible for that switch plans to do about their host
interface.  It would be nice to have both switches end up following the
same model, but I can't speak for that team.

Thanks,

Alex

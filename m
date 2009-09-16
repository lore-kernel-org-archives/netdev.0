From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: igb bandwidth allocation configuration
Date: Wed, 16 Sep 2009 08:53:48 -0700
Message-ID: <4AB10A0C.5010703@intel.com>
References: <20090910081844.GA5421@verge.net.au>	<15ddcffd0909140142n2a110708ld619177c65f4588b@mail.gmail.com>	<20090915113659.GJ24194@verge.net.au> <4AAF963D.4060708@voltaire.com> <4AAFD690.5040900@intel.com> <4AB0F1BD.4020206@voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <horms@verge.net.au>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Or Gerlitz <ogerlitz@voltaire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:46940 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751430AbZIPPxq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Sep 2009 11:53:46 -0400
In-Reply-To: <4AB0F1BD.4020206@voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Or Gerlitz wrote:
> Alexander Duyck wrote:
>> The interface for all of this would make sense as part of a virtual 
>> ethernet switch control which is the way I am currently leaning on all 
>> this.
> Yes, you can say that out of the per VF <mac, vlan-id, priority, rate> 
> tuple I mentioned, except for the mac, the other parameters actually 
> belong to the egress flow of the virtual switch port this VF is 
> connected to. So the vswitch actually signs the packet with vlan+pbits 
> and enforces the rate. Now vswitch can be software based, or hardware 
> NIC based.

Even something such as MAC address would make sense for a virtual 
ethernet switch configuration in that you could restrict unicast ingress 
traffic for the VF to a specific address much like you would do on a 
regular L2 switch.

> Now, I assume there may be NICs which will let you configure the 
> <vlan-id, priority, rate> as part of the their virtual switch config, 
> but others, e.g
> the 82576 as an example, and following our discussion, will let you do 
> that for the VF, in the VF driver which as you said may run the guest OS 
> where we can't control it...

I think you may be a bit confused.  The configuration for the VFs would 
be part of the PF via the virtual ethernet switch control.  As a result 
it is only the PF which needs to be running on the host.

Thanks,

Alex

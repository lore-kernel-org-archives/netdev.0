From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: Re: igb bandwidth allocation configuration
Date: Wed, 16 Sep 2009 17:10:05 +0300
Message-ID: <4AB0F1BD.4020206@voltaire.com>
References: <20090910081844.GA5421@verge.net.au>	<15ddcffd0909140142n2a110708ld619177c65f4588b@mail.gmail.com>	<20090915113659.GJ24194@verge.net.au> <4AAF963D.4060708@voltaire.com> <4AAFD690.5040900@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <horms@verge.net.au>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:28557 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753111AbZIPOKM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Sep 2009 10:10:12 -0400
In-Reply-To: <4AAFD690.5040900@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexander Duyck wrote:
> The interface for all of this would make sense as part of a virtual 
> ethernet switch control which is the way I am currently leaning on all 
> this.
Yes, you can say that out of the per VF <mac, vlan-id, priority, rate> 
tuple I mentioned, except for the mac, the other parameters actually 
belong to the egress flow of the virtual switch port this VF is 
connected to. So the vswitch actually signs the packet with vlan+pbits 
and enforces the rate. Now vswitch can be software based, or hardware 
NIC based.

Now, I assume there may be NICs which will let you configure the 
<vlan-id, priority, rate> as part of the their virtual switch config, 
but others, e.g
the 82576 as an example, and following our discussion, will let you do 
that for the VF, in the VF driver which as you said may run the guest OS 
where we can't control it...

Or.



From: "Shmulik Ravid" <shmulikr@broadcom.com>
Subject: Re: [PATCH net-next 1/3] dcbnl: adding DCBX engine capability
Date: Wed, 29 Dec 2010 15:59:02 +0200
Message-ID: <1293631142.29378.22.camel@lb-tlvb-shmulik.il.broadcom.com>
References: <1292959963.7142.130.camel@lb-tlvb-shmulik.il.broadcom.com>
 <4D1A7B64.5000402@intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Liu, Lucy" <lucy.liu@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "John Fastabend" <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2875 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753196Ab0L2N7Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Dec 2010 08:59:16 -0500
In-Reply-To: <4D1A7B64.5000402@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 2010-12-28 at 16:05 -0800, John Fastabend wrote:

> I would like to use these bits for guests using a VF as well. The
>  problem is multiple lldp agents advertising dcbx tlvs on the same link
>  is not spec compliant. In the VF case there may or may not be a
>  hardware lldp engine all the VF driver (ie ixgbevf) should need to
>  know is that some other entity is managing the DCB attributes.
> 
> To reflect this I would propose changing DCB_CAP_DCBX_HW and the comments by removing "HW". The two ideas I had were DCB_CAP_DCBX_READONLY or DCB_CAP_DCBX_LLD_MANAGED. Admittedly a bit of a nitpick but its a bit confusing to set the DCBX_HW bit when there really is no HW engine in the 82599 adapter case.
> 
> Otherwise this all looks good to me. I was hoping someone would get around to this. Thanks a lot!
> 
> -- John.
> 

I see your point, I like DCB_CAP_DCBX_LLD_MANAGED better. I will change
it an resubmit the patches. DCB_CAP_DCBX_HW implies 3 things:
1. DCBX negotiation is managed by some other entity.
2. The user can use the 'get' routines to get the negotiation results.
3. The user can use the 'set' routines to set the initial configuration
for the negotiation. 
I think No 3. is irrelevant to VFs, that is you don't want multiple VF
drivers trying to change the initial configuration settings. I can think
of 2 ways to make this distinction, the first is for the VF driver not
to support the 'set' routines (or always return an error value). The
second is to add another attribute flag: DCB_CAP_DCBX_LLD_CFG which will
indicate exactly No 3. while DCB_CAP_DCBX_LLD_MANAGED will indicate No
1. and 2. The VF driver will declare DCB_CAP_DCBX_LLD_MANAGED only and a
driver for an embedded DCBX engine will declare both flags. What do you
think?

Thanks
Shmulik.

 



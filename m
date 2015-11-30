From: "Singhai, Anjali" <anjali.singhai@intel.com>
Subject: RE: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Mon, 30 Nov 2015 21:33:23 +0000
Message-ID: <C40BE8378EF49C44B9184714DBC8EF2993A70423@ORSMSX115.amr.corp.intel.com>
References: <1448312579-159544-1-git-send-email-anjali.singhai@intel.com>
	<1448312579-159544-2-git-send-email-anjali.singhai@intel.com>
	<CALx6S34+_AtjO94znh7vW4py5a8Nj1g6b-sjGPCa4U1Mc6Y6-w@mail.gmail.com>
 <20151129.222138.1582847465760563254.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jesse@kernel.org" <jesse@kernel.org>,
	"Patil, Kiran" <kiran.patil@intel.com>
To: David Miller <davem@davemloft.net>,
	"tom@herbertland.com" <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:56506 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754702AbbK3Vd0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 16:33:26 -0500
In-Reply-To: <20151129.222138.1582847465760563254.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



-----Original Message-----
From: David Miller [mailto:davem@davemloft.net] 
Sent: Sunday, November 29, 2015 7:22 PM
To: tom@herbertland.com
Cc: Singhai, Anjali <anjali.singhai@intel.com>; netdev@vger.kernel.org; jesse@kernel.org; Patil, Kiran <kiran.patil@intel.com>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload

From: Tom Herbert <tom@herbertland.com>
Date: Mon, 23 Nov 2015 13:53:44 -0800

> The bad effect of this model is that it is encourages HW vendors to 
> continue implement HW protocol specific support for encapsulations, we 
> get so much more benefit if they implement protocol generic 
> mechanisms.
Dave, at least Intel parts have a protocol generic model for tunneled packet offloads and hence we are able to extend our support to newer tunnel types. We do  not have protocol specific support in the HW, but since the udp based tunnels do not have a packet type for the tunnel header, the HW needs to know which udp port should be mapped to which specific encapsulation. Otherwise encapsulated types like NVGRE we can identify through packet type and program the HW to account for the header. The newer patches for sure reduce the protocol ossification since in communalizes all the different tunnels into one interface so that any further support to a newer udp tunnel type requires just a type definition and if the driver/HW can support it, minor driver changes to set the right bits for HW. No 
 interface change for sure. And I think that is definitely a step in the right direction.

+1

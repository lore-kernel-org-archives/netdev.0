From: "Shmulik Ravid" <shmulikr@broadcom.com>
Subject: Re: [net-2.6 PATCH 1/2] net: dcbnl: remove redundant
 DCB_CAP_DCBX_STATIC bit
Date: Mon, 24 Jan 2011 17:27:51 +0200
Message-ID: <1295882871.25104.20.camel@lb-tlvb-shmulik.il.broadcom.com>
References: <20110122023512.4239.40379.stgit@jf-dev1-dcblab>
 <4D3A465F.8020809@intel.com>
 <1295801600.25104.13.camel@lb-tlvb-shmulik.il.broadcom.com>
 <4D3D123F.40700@intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "John Fastabend" <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3959 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752843Ab1AXNbX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jan 2011 08:31:23 -0500
In-Reply-To: <4D3D123F.40700@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sun, 2011-01-23 at 21:46 -0800, John Fastabend wrote:
> On 1/23/2011 8:53 AM, Shmulik Ravid wrote:
> > 
> > On Fri, 2011-01-21 at 18:52 -0800, John Fastabend wrote:
> >> On 1/21/2011 6:35 PM, John Fastabend wrote:
> >>> Remove redundant DCB_CAP_DCBX_STATIC bit in DCB capabilities
> >>>
> >>> Setting this bit indicates that no embedded DCBx engine is
> >>> present and the hardware can not be configured. This is the
> >>> same as having none of the DCB capability flags set or simply
> >>> not implementing the dcbnl ops at all.
> >>>
> >>> This patch removes this bit. The bit has not made a stable
> >>> release yet so removing it should not be an issue with
> >>> existing apps.
> >>>
> >>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> >>> CC: Shmulik Ravid <shmulikr@broadcom.com>
> >>> ---
> >>>
> >>
> >> Shmulik, could you ACK this because you added these bits? But
> >> I was adding support for this in lldpad and I see no reason that
> >> we need these?
> >>
> > DCB_CAP_DCBX_STATIC means that the embedded engine will turn the user
> > configuration into the operational configuration without performing the
> > actual negotiation, so it is not equivalent to not having an embedded
> > DCBx engine. This is mostly a debug and integration option as it allows
> > you to do DCB related or dependent testing and development without
> > having a proper DCBx peer.
> > 
> > On second thought, I'm not sure this option is justified although we
> > found it useful during our development. If you think it's not useful
> > enough (or not at all) then by all means remove it.
> 
> We have an advertise bit in userspace that can be set and cleared to
> do something similar for host based agents. I think for pg and application
> data you can get the same behavior by setting the device to not willing.
> 
True, but this requires a proper DCBx peer. The STATIC option is a bit
stronger.

> However for PFC it could potentially be useful. But how would the
> user set this mode? This is a capabilities bit indicating the device
> supports this. Is there a way to subsequently put the device in this
> mode?
You can set this mode by specifying this attribute in the set_dcbx
operation. The input to set_dcbx should be a subset of the advertised
dcbx attributes.

Shmulik 




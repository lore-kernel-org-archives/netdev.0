From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH net] bnx2x: allow adding VLANs while interface is down
Date: Sun, 5 Jun 2016 12:03:25 +0000
Message-ID: <CO2PR11MB0088CFB314E7498E1CC38E71975B0@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1464960738-8541-1-git-send-email-mschmidt@redhat.com>
 <CO2PR11MB00888A27698FB53DB4046D3C975A0@CO2PR11MB0088.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Ariel Elior <Ariel.Elior@qlogic.com>
To: Michal Schmidt <mschmidt@redhat.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0119.outbound.protection.outlook.com ([157.56.110.119]:27008
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750826AbcFEMD3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2016 08:03:29 -0400
In-Reply-To: <CO2PR11MB00888A27698FB53DB4046D3C975A0@CO2PR11MB0088.namprd11.prod.outlook.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Since implementing VLAN filtering in commit 05cc5a39ddb74
> > ("bnx2x: add vlan filtering offload") bnx2x refuses to add a VLAN
> > while the interface is down.
> 
> Hi Michal - thanks; I'll review this one on Sunday.

I'm a bit worried about the fact we're hiding actual issues -
E.g., if for some [unexpected] reason a vlan configuration ramrod would
fail, the only effect it will have is that we'll try [and probably fail] to
change HW into any-vlan mode; We won't propagate the error back to
caller.

Having written that, since we can't really avoid this in some scenarios
 [I.e., if we accept the command while down and configure it later while
up we can't do anything with an error if it occurs], I guess that's the pros
out-weight the cons here.

Thanks.

Acked-by: Yuval Mintz <Yuval.Mintz@qlogic.com>

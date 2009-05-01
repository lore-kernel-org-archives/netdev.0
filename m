From: "Love, Robert W" <robert.w.love@intel.com>
Subject: RE: [PATCH] net: Add the FCoE Initialization Protocol ethertype
Date: Fri, 1 May 2009 15:53:32 -0700
Message-ID: <273D38FBE7C6FE46A1689FCD014A0B8B495C012C@azsmsx505.amr.corp.intel.com>
References: <20090501185532.14602.21059.stgit@fritz>
 <20090501.150454.224636608.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	James Bottomley <James.Bottomley@HansenPartnership.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:2308 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761909AbZEAWxe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2009 18:53:34 -0400
In-Reply-To: <20090501.150454.224636608.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Robert Love <robert.w.love@intel.com>
> Date: Fri, 01 May 2009 11:55:32 -0700
> 
>> FIP is the FCoE Initialization Protocol and this patch
>> adds the protocol ethertype to the kernel's list of ethertypes.
>> 
>> Signed-off-by: Joe Eykholt <jeykholt@cisco.com>
>> Signed-off-by: Robert Love <robert.w.love@intel.com>
> 
> You can add this value, when you add the protocol implementation
> into the upstream sources.

The FIP implementation is upstream, in drivers/scsi/libfcoe.c.
There is a local define in include/scsi/fc/fc_fip.h for ETH_P_FCOE
and I'd rather move it to the propper location.

include/scsi/fc/fc_fip.h:28:#ifndef ETH_P_FIP
include/scsi/fc/fc_fip.h:29:#define ETH_P_FIP	0x8914 /* FIP Ethertype */

One thing to note is that I will later push a patch to linux-scsi
to remove the define in fc_fip.h. It may be preferable to do both
operations in one patch, but I was worried about cross-subsystem
conflicts with other patches to either netdev or fcoe code. I can
refresh this patch to include the fc_fip.h removal and you and James
can decide who takes the patch if that's a better aproach.
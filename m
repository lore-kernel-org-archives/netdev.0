From: Haggai Eran <haggaie@mellanox.com>
Subject: Re: [PATCH v3 for-next 05/13] IB/cm: Reference count ib_cm_ids
Date: Thu, 21 May 2015 09:51:23 +0300
Message-ID: <555D806B.1090002@mellanox.com>
References: <1431253604-9214-1-git-send-email-haggaie@mellanox.com>
 <1431253604-9214-6-git-send-email-haggaie@mellanox.com>
 <20150511183459.GB25405@obsidianresearch.com> <5551A2CB.1010407@mellanox.com>
 <20150512185447.GA3503@obsidianresearch.com> <55532566.9040105@mellanox.com>
 <20150513165823.GA20343@obsidianresearch.com>
 <1828884A29C6694DAF28B7E6B8A82373A8FDC0C3@ORSMSX109.amr.corp.intel.com>
 <20150519192353.GA23612@obsidianresearch.com>
 <1828884A29C6694DAF28B7E6B8A82373A8FDD412@ORSMSX109.amr.corp.intel.com>
 <20150519234654.GA26634@obsidianresearch.com>
 <1828884A29C6694DAF28B7E6B8A82373A8FDD565@ORSMSX109.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Doug Ledford <dledford@redhat.com>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Liran Liss <liranl@mellanox.com>,
	Guy Shapiro <guysh@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>
To: "Hefty, Sean" <sean.hefty@intel.com>,
	Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0064.outbound.protection.outlook.com ([157.55.234.64]:22195
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750927AbbEUGv3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 May 2015 02:51:29 -0400
In-Reply-To: <1828884A29C6694DAF28B7E6B8A82373A8FDD565@ORSMSX109.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20/05/2015 03:49, Hefty, Sean wrote:
>>> I wonder if the existing ib_cm interface is even what we want.
>>> Currently, the rdma_cm pushes the private data (i.e. IP address)
>>> comparison into the ib_cm.  This is only used by the rdma_cm.
>>> Should that instead be moved out of the ib_cm and handled in the
>>> rdma_cm?  And then update the ib_cm to support multiple listens on
>>> the same service id.
>>
>> Well, that really is the problem here, the private data compare
>> doesn't really do enough because rdma cm wildcard's the IP address and
>> does it's own check anyhow. So I see all of this as different
>> proposals on how to fix that. rdma_cm basically already does most of
>> the private data compare itself.
> 
> Maybe the first thing to fix is this.  Since the private data compare is no longer sufficient, remove it and update the rdma_cm to handle the change.  Regardless of how the code ends up structured, the namespace support should then easily fit into that solution.
Patch 8 in this series (IB/cma: Add compare_data checks to the RDMA CM
module) basically does that (change rdma_cm so that it doesn't rely on
private_data checks in ib_cm). Indeed, it is positioned in the series
before adding the rdma_cm namespace support.

It remains to clean up ib_cm's ib_cm_listen interface now that
compare_data isn't used, but I'm not sure this belongs in this series.

Haggai

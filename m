From: Chris Leech <christopher.leech@intel.com>
Subject: Re: [ANNOUNCE] Open-FCoE - Fibre Channel over Ethernet Project
Date: Wed, 28 Nov 2007 09:53:52 -0800
Message-ID: <474DAB30.20703@intel.com>
References: <10A7D0016239E24092DEF05CCC582E43028A636B@fmsmsx411.amr.corp.intel.com> <20071128074426.GA30468@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Love, Robert W" <robert.w.love@intel.com>,
	linux-scsi@vger.kernel.org,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	devel@open-fcoe.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Rob Love <robert.w.love@linux.intel.com>,
	"Zou, Yi" <yi.zou@intel.com>, "Dev, Vasu" <vasu.dev@intel.com>,
	james.bottomley@hansenpartnership.com, davem@davemloft.net,
	jeff@garzik.org, "Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Van De Ven, Arjan" <arjan.van.de.ven@intel.com>,
	Mike Christie <michaelc@cs.wisc.edu>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:9390 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750857AbXK1SFr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Nov 2007 13:05:47 -0500
In-Reply-To: <20071128074426.GA30468@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christoph Hellwig wrote:
> I just did a very quick glance over the tree.  Some extremly highlevel
> comments to start with before actually starting the source review:

Thanks for taking a look Christoph

>  - why do you need your own libcrc?  lib/crc32.c has a crc32_le

We shouldn't, but we may want to add a CRC and copy routine.

>  - libsa should go.  Much of it is just wrappers of kernel functions
>    that should be used directly.  Other like that hash, even or state
>    helpers might either be opencoded in the caller or made completely
>    generic in lib/.  Probably the former but we'll have to see.

Yes, and along with it the last use of the BSD TAILQ macros.  Just 
before Rob set up the open repos I finished converting most of those to 
list_head, the only one left is in the sa_event mechanism.  Rather than 
convert it I'd like to replace the use of sa_event with notifier call 
chains.  I just need to finish auditing the use to make sure the 
differences won't cause unexpected problems.

After than and unwrapping kernel functions, I think the only thing left 
before completly removing libsa is to open code the state machines.

Similarly I think net_types.h need to go.

- Chris

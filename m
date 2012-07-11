From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [RFC PATCH 09/10] ixgbe: Add support for displaying the number
 of Tx/Rx channels
Date: Wed, 11 Jul 2012 14:00:01 -0700
Message-ID: <4FFDE951.40604@intel.com>
References: <20120630000652.29939.11108.stgit@gitlad.jf.intel.com>  <20120630001659.29939.61276.stgit@gitlad.jf.intel.com> <1342030903.2613.52.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, edumazet@google.com,
	therbert@google.com, alexander.duyck@gmail.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:44576 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754788Ab2GKVAD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2012 17:00:03 -0400
In-Reply-To: <1342030903.2613.52.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/11/2012 11:21 AM, Ben Hutchings wrote:
> On Fri, 2012-06-29 at 17:16 -0700, Alexander Duyck wrote:
>> This patch adds support for the ethtool get_channels operation.
>>
>> Since the ixgbe driver has to support DCB as well as the other modes the
>> assumption I made here is that the number of channels in DCB modes refers
>> to the number of queues per traffic class, not the number of queues total.
> [...]
>
> When MSI-X is enabled, a 'channel' is an MSI-X vector and the associated
> queues, i.e. total number of channels reported should be the total
> number of MSI-X vectors in use.  (That was my intended interpretation,
> anyway.  It may be that there is too much variation in the way queues
> and interrupts are associated for these operations to be defined in a
> general way.)
>
> Ben.
>
The problem with the MSI-X interpretation is that ixgbe has that type of
control reversed.  We base everything on the number of queues, and then
from that you can end up determining the number of MSI-X vectors.  So
for example we could tell ixgbe via this interface to generate 64
queues, but if the system only has 8 CPUs we would end up with 8 MSI-X
vectors each with 8 queues.

Also as I mentioned in the case of DCB things get even more
complicated.  We need to have a symmetric number of queues per traffic
class based on the way we currently have DCB implemented.  The way I saw
it I could go two routes, the first being to force channels to be a
multiple of TCs which would have been complicated to deal with, or the
simpler approach I chose which was to apply 'channel' to be per TC. 
This way if DCB is then disabled we can easily revert to the standard
interpretation which would mean we would only have as many queues as the
channels specified.

Thanks,

Alex

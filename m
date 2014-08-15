From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH] macvlan: Allow setting multicast filter on all macvlan
 types
Date: Fri, 15 Aug 2014 15:54:39 -0400
Message-ID: <53EE657F.3020407@redhat.com>
References: <1408122299-29632-1-git-send-email-vyasevic@redhat.com> <53EE59BC.1070605@intel.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Jason Wang <jasowang@redhat.com>, roopa@cumulusnetworks.com
To: John Fastabend <john.r.fastabend@intel.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44975 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751138AbaHOTys (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Aug 2014 15:54:48 -0400
In-Reply-To: <53EE59BC.1070605@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/15/2014 03:04 PM, John Fastabend wrote:
> On 08/15/2014 10:04 AM, Vladislav Yasevich wrote:
>> Currently, macvlan code restricts multicast and unicast
>> filter setting only to passthru devices.  As a result,
>> if a guest using macvtap wants to receive multicast
>> traffic, it has to set IFF_ALLMULTI or IFF_PROMISC.
>>
>> This patch makes it possible to use the fdb interface
>> to add multicast addresses to the filter thus allowing
>> a guest to receive only targeted multicast traffic.
>>
>> CC: John Fastabend <john.r.fastabend@intel.com>
>> CC: Michael S. Tsirkin <mst@redhat.com>
>> CC: Jason Wang <jasowang@redhat.com>
>> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
>> ---
> 
> Acked-by: John Fastabend <john.r.fastabend@intel.com>
> 
> Looks good to me. Although I am trying to recall why
> we restrict unicast addresses? It looks like an additional
> check could be made to detect duplicate MAC addresses
> in fdb_add and then we could support this as well.

Additional unicasts can be easily supported in VEPA mode,
but VEB would require additional lookups in forwarding mode
to determine if the packet should be switched locally or not.

I don't think we would need any more duplicate checking
since we use the _excl() variants which already return error
on duplicates.  Thus no 2 macvlans would be able to add
the same unicast address to the same lower device.

-vlad

> But
> I might be missing why this wasn't supported originally.
> 
> Thanks,
> John
> 

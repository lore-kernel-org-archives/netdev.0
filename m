From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH v2 net] vlan: Mask off vlan acceleration features on vlan
 device.
Date: Wed, 26 Mar 2014 21:03:47 -0400
Message-ID: <533378F3.5000607@redhat.com>
References: <1395865521-2318-1-git-send-email-vyasevic@redhat.com>	<1395865711-3347-1-git-send-email-vyasevic@redhat.com> <20140326.171038.2150319831233512825.davem@davemloft.net>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62613 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754310AbaC0BDw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2014 21:03:52 -0400
In-Reply-To: <20140326.171038.2150319831233512825.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/26/2014 05:10 PM, David Miller wrote:
> From: Vlad Yasevich <vyasevic@redhat.com>
> Date: Wed, 26 Mar 2014 16:28:31 -0400
> 
>> Some drivers incorrectly assign vlan acceleration features to
>> vlan_features thus causing issues for Q-in-Q vlan configurations.
>> Prevent this once and for all by masking off acceleration features
>> for vlan devices until such time as we support stacked acceleration.
>>
>> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> 
> So what if we do have chips that can offload Q-in-Q?  Will we use
> a new flag?
> 

If there are chips that can take both the inner and outer tags an put
both vlan headers on the packet, then we'll need a lot more then just
a new flag to support that since the skbs will need to carry 2 vlan_tci
values in that case.

With this patch you can still offload the outer tag, whether STAG and
or CTAG (old Q-in-Q), but the inner tag can't be offloaded.

-vlad

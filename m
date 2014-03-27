From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH v2 net] vlan: Mask off vlan acceleration features on vlan
 device.
Date: Wed, 26 Mar 2014 20:53:12 -0400
Message-ID: <53337678.9050208@redhat.com>
References: <1395865521-2318-1-git-send-email-vyasevic@redhat.com> <1395865711-3347-1-git-send-email-vyasevic@redhat.com> <20140326.171038.2150319831233512825.davem@davemloft.net> <20140326211504.GA21393@macbook.localnet>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17859 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753291AbaC0AxR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2014 20:53:17 -0400
In-Reply-To: <20140326211504.GA21393@macbook.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/26/2014 05:15 PM, Patrick McHardy wrote:
> On Wed, Mar 26, 2014 at 05:10:38PM -0400, David Miller wrote:
>> From: Vlad Yasevich <vyasevic@redhat.com>
>> Date: Wed, 26 Mar 2014 16:28:31 -0400
>>
>>> Some drivers incorrectly assign vlan acceleration features to
>>> vlan_features thus causing issues for Q-in-Q vlan configurations.
>>> Prevent this once and for all by masking off acceleration features
>>> for vlan devices until such time as we support stacked acceleration.
>>>
>>> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
>>
>> So what if we do have chips that can offload Q-in-Q?  Will we use
>> a new flag?
> 
> For 802.1ad that was the intention, using the NETIF_F_HW_VLAN_STAG_* flags.
> 

But we can't really do that as we don't carry multiple vlan_tci in the
skb.  If the card advertises VLAN_STAG_*, then we'll offload that, but
CTAG will have to be computed by software.  More infrastructure is
needed to support nested vlan offloads.

-vlad

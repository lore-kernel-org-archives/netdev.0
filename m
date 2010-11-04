From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [RFC][net-next-2.6 PATCH 2/4] net: 8021Q consolidate header_ops
 routines
Date: Thu, 04 Nov 2010 06:43:31 -0700
Message-ID: <4CD2B883.30808@intel.com>
References: <20101021221004.22906.58438.stgit@jf-dev1-dcblab>	<20101021221010.22906.60238.stgit@jf-dev1-dcblab> <AANLkTi=pObCfPHkPCUxD8yicZL3pyTwm9s_z4KKda62k@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:9153 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750757Ab0KDNnc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Nov 2010 09:43:32 -0400
In-Reply-To: <AANLkTi=pObCfPHkPCUxD8yicZL3pyTwm9s_z4KKda62k@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/3/2010 5:47 PM, Jesse Gross wrote:
> On Thu, Oct 21, 2010 at 3:10 PM, John Fastabend
> <john.r.fastabend@intel.com> wrote:
>> The only thing the 8021Q header ops routines are required
>> for is the VLAN_FLAG_REORDER_HDR otherwise by the time
>> the VLAN tag has been added the packet is already on
>> its way down the stack. In this case using the Ethernet
>> ops works OK.
>>
>> At present the VLAN_FLAG_REORDER_HDR flag does not work
>> with vlan offloads. As I understand the flag the intent
>> is to allow taps on the vlan device and possibly the
>> QOS layer to see the vlan tag info.
>>
>> By inserting the tag in vlan_tci any taps or QOS policies
>> should be able to retrieve the vlan info. This allows
>> the flag to work the same in both the offload case and
>> non-offloaded case. And allows us to use the underlying
>> ethernet ops.
>>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> 
> I noticed that you dropped this patch from your most recent series, so
> I went back to take a look at it.  I realized that it probably works
> inconsistently since header caching doesn't take into account
> skb->vlan_tci, so whether you see the tag depends on the state of the
> cache.
> 
> It would be really good to have this type of code consolidation, both
> for the sake of sanity and to eliminate the inconsistent behavior.  We
> could do that by either not using header caching or making it work
> with vlan offloading somehow.  However, I'm not sure that there's
> really much point in that.  VLAN_FLAG_REORDER_HDR doesn't work with
> cards that do vlan offloading, which is a pretty significant number of
> them.  It similarly works inconsistently on the rx side.  So it's
> broken most of the time and worse, the behavior changes depending on
> the NIC (and now the ethtool setting).  Can we just eliminate it?

Yes this is why I have dropped it for now. Also rebuild is broke as best I can tell. Although I doubt anyone would notice you would need to clear VLAN_FLAG_REORDER_HDR and be using one of the ARPHRD_{ROSE|AX25|NETROM}.

The problem with caching the vlan header is the skb priority to vlan priority map. So we could cache the vid, sa, da, and protocols but I can not see anyway to cache the vlan priority. Also the cache would have to be flushed when the flag is toggled.

Thanks,
John.

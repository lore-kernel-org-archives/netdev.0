From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [net-next-2.6 PATCH 01/10] ethtool: prevent null pointer dereference
 with NTUPLE set but no set_rx_ntuple
Date: Fri, 25 Feb 2011 16:40:13 -0800
Message-ID: <4D684BED.20805@intel.com>
References: <20110225232357.7920.58559.stgit@gitlad.jf.intel.com>	 <20110225233244.7920.26742.stgit@gitlad.jf.intel.com> <1298679675.3555.4.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:13282 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755481Ab1BZAkO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Feb 2011 19:40:14 -0500
In-Reply-To: <1298679675.3555.4.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/25/2011 4:21 PM, Ben Hutchings wrote:
> On Fri, 2011-02-25 at 15:32 -0800, Alexander Duyck wrote:
>> This change is meant to prevent a possible null pointer dereference if
>> NETIF_F_NTUPLE is defined but the set_rx_ntuple function pointer is not.
>
> I think it would be a bug for NETIF_F_NTUPLE to be enabled on a device
> that doesn't have this operation.  Are there any drivers for which this
> is possible?

Currently there are no drivers where this is possible.  However I 
encountered it as a result of testing the patches further on in this set.

>> This issue appears to affect all kernels since 2.6.34.
>
> If this can actually happen, the fix should go to net-2.6 and
> stable@kernel.org.  However, I think that the null deference is
> impossible and this really just fixes the error code.
>
> Ben.

It cannot occur with any of the in-kernel drivers since they all set the 
NETIF_F_NTUPLE flag and have the function defined.  However going 
forward I would like to have the option of using the network flow 
classifier interface instead of the set_rx_ntuple interface due to the 
fact that it supports many of the features I needed.

I believe this patch should apply to net-2.6 without any changes so if 
it is better placed there I will resubmit it specifically for net-2.6 
and stable.

Thanks,

Alex

>> Signed-off-by: Alexander Duyck<alexander.h.duyck@intel.com>
>> ---
>>
>>   net/core/ethtool.c |    3 +++
>>   1 files changed, 3 insertions(+), 0 deletions(-)
>>
>> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
>> index c1a71bb..4843674 100644
>> --- a/net/core/ethtool.c
>> +++ b/net/core/ethtool.c
>> @@ -893,6 +893,9 @@ static noinline_for_stack int ethtool_set_rx_ntuple(struct net_device *dev,
>>   	struct ethtool_rx_ntuple_flow_spec_container *fsc = NULL;
>>   	int ret;
>>
>> +	if (!ops->set_rx_ntuple)
>> +		return -EOPNOTSUPP;
>> +
>>   	if (!(dev->features&  NETIF_F_NTUPLE))
>>   		return -EINVAL;
>>
>>
>


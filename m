From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [net-next 31/40] ethtool: remove support for ETHTOOL_GRXNTUPLE
Date: Tue, 07 Jun 2011 15:20:04 -0700
Message-ID: <4DEEA414.1010205@intel.com>
References: <1307449995-9458-1-git-send-email-jeffrey.t.kirsher@intel.com>	 <1307449995-9458-32-git-send-email-jeffrey.t.kirsher@intel.com> <1307451997.2908.13.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org, gospo@redhat.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:64066 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753921Ab1FGWUp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jun 2011 18:20:45 -0400
In-Reply-To: <1307451997.2908.13.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/07/2011 06:06 AM, Ben Hutchings wrote:
> On Tue, 2011-06-07 at 05:33 -0700, Jeff Kirsher wrote:
>> From: Alexander Duyck<alexander.h.duyck@intel.com>
>>
>> This change is meant to remove all support for displaying an ntuple as
>> strings via ETHTOOL_GRXNTUPLE.  The reason for this change is due to the
>> fact that multiple issues have been found including:
>>   - Multiple buffer overruns for strings being displayed.
>>   - Incorrect filters displayed, cleared filters with ring of -2 are displayed
>>   - Setting get_rx_ntuple displays no rules if defined.
>>   - Endianess wrong on displayed values.
>>   - Hard limit of 1024 filters makes display functionality extremely limited
>>
>> The only driver that had supported this interface was ixgbe.  Since it no
>> longer uses the interface and due to the issues mentioned above I am
>> submitting this patch to remove it.
>>
>> Signed-off-by: Alexander Duyck<alexander.h.duyck@intel.com>
>> Tested-by: Ross Brattain<ross.b.brattain@intel.com>
>> Signed-off-by: Jeff Kirsher<jeffrey.t.kirsher@intel.com>
>> ---
>>   include/linux/ethtool.h   |    8 +-
>>   include/linux/netdevice.h |    3 -
>>   net/core/dev.c            |    5 -
>>   net/core/ethtool.c        |  299 ---------------------------------------------
>>   4 files changed, 2 insertions(+), 313 deletions(-)
>>
>> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
>> index c6a850a..3310ab6 100644
>> --- a/include/linux/ethtool.h
>> +++ b/include/linux/ethtool.h
>> @@ -287,7 +287,7 @@ enum ethtool_stringset {
>>   	ETH_SS_TEST		= 0,
>>   	ETH_SS_STATS,
>>   	ETH_SS_PRIV_FLAGS,
>> -	ETH_SS_NTUPLE_FILTERS,
>> +	ETH_SS_DO_NOT_USE,		/* was ETH_SS_NTUPLE_FILTERS */
>>   	ETH_SS_FEATURES,
>>   };
>>
> Since this feature didn't work properly, any code that tried to use it
> didn't really work, but it still feels kind of wrong to turn that into a
> compile error.  And it does no harm to leave the definition here, though
> you may want to comment that it is no longer supported.
>
Ok, if Jeff can pull that patch I will redo it with the definition left 
behind and a comment added.
>> @@ -720,8 +720,6 @@ struct ethtool_rx_ntuple_flow_spec_container {
>>   };
>>
>>   struct ethtool_rx_ntuple_list {
>> -#define ETHTOOL_MAX_NTUPLE_LIST_ENTRY 1024
>> -#define ETHTOOL_MAX_NTUPLE_STRING_PER_ENTRY 14
>>   	struct list_head	list;
>>   	unsigned int		count;
>>   };
> You can remove struct ethtool_rx_ntuple_flow_spec_container and struct
> ethtool_rx_ntuple_list as they were not exposed to userland.
>
> [...]
>> @@ -1017,7 +1013,7 @@ struct ethtool_ops {
>>   #define ETHTOOL_FLASHDEV	0x00000033 /* Flash firmware to device */
>>   #define ETHTOOL_RESET		0x00000034 /* Reset hardware */
>>   #define ETHTOOL_SRXNTUPLE	0x00000035 /* Add an n-tuple filter to device */
>> -#define ETHTOOL_GRXNTUPLE	0x00000036 /* Get n-tuple filters from device */
>> +/* ETHTOOL_GRXNTUPLE		0x00000036 disabled due to multiple issues */
>>   #define ETHTOOL_GSSET_INFO	0x00000037 /* Get string set info */
>>   #define ETHTOOL_GRXFHINDIR	0x00000038 /* Get RX flow hash indir'n table */
>>   #define ETHTOOL_SRXFHINDIR	0x00000039 /* Set RX flow hash indir'n table */
> [...]
>
> Same here; the command number needs to be reserved forever and the
> definition does no harm.
>
> Ben.
Same for this.  I will update it so that the definition remains, but 
comment that it should not be used.

Thanks,

Alex


From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 2/4] net: ethtool: add the EEE support
Date: Wed, 29 Feb 2012 17:12:26 +0100
Message-ID: <4F4E4E6A.7090000@st.com>
References: <1330433084-18586-1-git-send-email-peppe.cavallaro@st.com>  <1330433084-18586-3-git-send-email-peppe.cavallaro@st.com> <1330443900.8460.158.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:49883 "EHLO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755310Ab2B2QMu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Feb 2012 11:12:50 -0500
In-Reply-To: <1330443900.8460.158.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Ben,

On 2/28/2012 4:45 PM, Ben Hutchings wrote:
> On Tue, 2012-02-28 at 13:44 +0100, Giuseppe CAVALLARO wrote:
>> This patch adds two new functions to detect if Energy-Efficient
>> Ethernet (EEE) is supported and the way to enable/disable it.
>>
>> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
>> ---
>>  include/linux/ethtool.h |    7 +++++++
>>  net/core/ethtool.c      |   32 ++++++++++++++++++++++++++++++++
>>  2 files changed, 39 insertions(+), 0 deletions(-)
>>
>> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
>> index da5b2de..fdea3c7 100644
>> --- a/include/linux/ethtool.h
>> +++ b/include/linux/ethtool.h
>> @@ -43,6 +43,7 @@ struct ethtool_cmd {
>>  	__u8	eth_tp_mdix;
>>  	__u8	reserved2;
>>  	__u32	lp_advertising;	/* Features the link partner advertises */
>> +	__u32	eee;		/* Energy-Efficient Etehrnet */
>>  	__u32	reserved[2];
>>  };
> 
> You can't change the size of this structure.

hmm, sorry but it's likely I missed something. Let me review the code
and so I come back on this.
> 
>> @@ -874,6 +875,8 @@ static inline u32 ethtool_rxfh_indir_default(u32 index, u32 n_rx_rings)
>>   * 		   and flag of the device.
>>   * @get_dump_data: Get dump data.
>>   * @set_dump: Set dump specific flags to the device.
>> + * @get_eee: Get Energy-Efficient Ethernet (EEE) supported and status.
>> + * @set_eee: Set EEE status (enable/disable).
>>   *
>>   * All operations are optional (i.e. the function pointer may be set
>>   * to %NULL) and callers must take this into account.  Callers must
>> @@ -937,6 +940,8 @@ struct ethtool_ops {
>>  				 struct ethtool_dump *, void *);
>>  	int	(*set_dump)(struct net_device *, struct ethtool_dump *);
>>  
>> +	int	(*get_eee) (struct net_device *, struct ethtool_value *);
>> +	int	(*set_eee) (struct net_device *, struct ethtool_value *);
> [...]
> 
> Why are there new operations as well as a new field to ethtool_cmd?
> 
> Is the value a boolean or a bitmask?

the former.
These are for enabling/disabling the EEE and also to get the status.

> Since EEE is an auto-negotiated feature, why aren't you defining flags
> for the supported/advertising/lp_advertising fields?

I added these because the stmmac needs to have a timer to enter in LPI
tx mode. So this can be stopped by using ethtool.
I didn't define flags for supported/advertising/lp_advertising because
these are fixed in the RO MMD register and it makes no sense to modify
them (hmm, I think :-)).

Regards
Peppe

> 
> Ben.
> 

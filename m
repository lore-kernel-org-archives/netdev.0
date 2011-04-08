From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [net-next-2.6 PATCH 2/2] ethtool: add ntuple flow specifier data
 to network flow classifier
Date: Fri, 08 Apr 2011 15:35:42 -0700
Message-ID: <4D9F8DBE.2050503@intel.com>
References: <20110408220410.25468.49130.stgit@gitlad.jf.intel.com>	 <20110408220727.25468.53817.stgit@gitlad.jf.intel.com> <1302301284.2871.25.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:49067 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752912Ab1DHWfn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Apr 2011 18:35:43 -0400
In-Reply-To: <1302301284.2871.25.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/8/2011 3:21 PM, Ben Hutchings wrote:
> On Fri, 2011-04-08 at 15:07 -0700, Alexander Duyck wrote:
>> This change is meant to add an ntuple data extensions to the rx network flow
>> classification specifiers.  The idea is to allow ntuple to be displayed via
>> the network flow classification interface.
>
> Thanks for carrying on with this.
>
> [...]
>>   /**
>>    * struct ethtool_rx_flow_spec - specification for RX flow filter
>>    * @flow_type: Type of match to perform, e.g. %TCP_V4_FLOW
>>    * @h_u: Flow fields to match (dependent on @flow_type)
>> + * @h_ext: Additional fields to match
>>    * @m_u: Masks for flow field bits to be ignored
>> + * @m_ext: Masks for additional field bits to be ignored.
>> + *	Note, all additional fields must be ignored unless @flow_type
>> + *	includes the %FLOW_EXT flag.
>>    * @ring_cookie: RX ring/queue index to deliver to, or %RX_CLS_FLOW_DISC
>>    *	if packets should be discarded
>>    * @location: Index of filter in hardware table
>>    */
>>   struct ethtool_rx_flow_spec {
>>   	__u32		flow_type;
>> -	union {
>> -		struct ethtool_tcpip4_spec		tcp_ip4_spec;
>> -		struct ethtool_tcpip4_spec		udp_ip4_spec;
>> -		struct ethtool_tcpip4_spec		sctp_ip4_spec;
>> -		struct ethtool_ah_espip4_spec		ah_ip4_spec;
>> -		struct ethtool_ah_espip4_spec		esp_ip4_spec;
>> -		struct ethtool_usrip4_spec		usr_ip4_spec;
>> -		struct ethhdr				ether_spec;
>> -		__u8					hdata[72];
>> -	} h_u, m_u;
>> +	union ethtool_flow_union h_u;
>> +	struct ethtool_flow_ext h_ext;
>> +	union ethtool_flow_union m_u;
>> +	struct ethtool_flow_ext m_ext;
>> +	__u32		flow_type_ext;
> [...]
>
> You can't add flow_type_ext here.  I assume this is an oversight, since
> it isn't mentioned anywhere else.
>
> Ben.
>

Yeah, I forgot and left it in there.  It will be removed and resubmitted.

Thanks,

Alex

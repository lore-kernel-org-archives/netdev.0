From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH V1 net-next 1/3] net: ethtool: Add destination MAC address
 to flow steering API
Date: Wed, 12 Dec 2012 22:40:25 +0200
Message-ID: <50C8EBB9.7050206@mellanox.com>
References: <1355314400-14909-1-git-send-email-amirv@mellanox.com>  <1355314400-14909-2-git-send-email-amirv@mellanox.com> <1355336881.3149.27.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"Or Gerlitz" <ogerlitz@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	"Yan Burman" <yanb@mellanox.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog119.obsmtp.com ([207.126.144.147]:34078 "HELO
	eu1sys200aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754669Ab2LLUsH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 15:48:07 -0500
In-Reply-To: <1355336881.3149.27.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/12/2012 20:28, Ben Hutchings wrote:
> On Wed, 2012-12-12 at 14:13 +0200, Amir Vadai wrote:
>> From: Yan Burman <yanb@mellanox.com>
>>
>> Add ability to specify destination MAC address for L3/L4 flow spec
>> in order to be able to specify action for different VM's under vSwitch
>> configuration. This change is transparent to older userspace.
>>
>> Signed-off-by: Yan Burman <yanb@mellanox.com>
>> Signed-off-by: Amir Vadai <amirv@mellanox.com>
>> ---
>>   include/uapi/linux/ethtool.h | 11 +++++++----
>>   1 file changed, 7 insertions(+), 4 deletions(-)
>>
>> diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
>> index d3eaaaf..be8c41e 100644
>> --- a/include/uapi/linux/ethtool.h
>> +++ b/include/uapi/linux/ethtool.h
>> @@ -500,13 +500,15 @@ union ethtool_flow_union {
>>   	struct ethtool_ah_espip4_spec		esp_ip4_spec;
>>   	struct ethtool_usrip4_spec		usr_ip4_spec;
>>   	struct ethhdr				ether_spec;
>> -	__u8					hdata[60];
>> +	__u8					hdata[52];
>>   };
>>
>>   struct ethtool_flow_ext {
>> -	__be16	vlan_etype;
>> -	__be16	vlan_tci;
>> -	__be32	data[2];
>> +	__u8		padding[2];
>> +	unsigned char	h_dest[ETH_ALEN];	/* destination eth addr	*/
>> +	__be16		vlan_etype;
>> +	__be16		vlan_tci;
>> +	__be32		data[2];
>>   };
>>
>>   /**
>> @@ -1027,6 +1029,7 @@ enum ethtool_sfeatures_retval_bits {
>>   #define	ETHER_FLOW	0x12	/* spec only (ether_spec) */
>>   /* Flag to enable additional fields in struct ethtool_rx_flow_spec */
>>   #define	FLOW_EXT	0x80000000
>> +#define	FLOW_MAC_EXT	0x40000000
>
> Please can you send another patch that adds kernel-doc to struct
> ethtool_flow_ext explaining which fields are dependent on which flags.
>
> Ben.
>
>>   /* L3-L4 network traffic flow hash options */
>>   #define	RXH_L2DA	(1 << 1)
>

Sure. Will send it.

Amir

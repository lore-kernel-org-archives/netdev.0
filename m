From: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Subject: Re: [PATCH net-next v5 1/5] netlink: extended ACK reporting
Date: Wed, 12 Apr 2017 17:13:03 +0200
Message-ID: <20170412151303.GK1952@nanopsycho>
References: <20170412123408.22012-1-johannes@sipsolutions.net>
 <20170412123408.22012-2-johannes@sipsolutions.net>
 <dbc81431-487b-f218-a4c6-2caa44783d97@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
        Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <dbc81431-487b-f218-a4c6-2caa44783d97-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Wed, Apr 12, 2017 at 05:06:48PM CEST, dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org wrote:
>On 4/12/17 6:34 AM, Johannes Berg wrote:
>> diff --git a/include/uapi/linux/netlink.h b/include/uapi/linux/netlink.h
>> index b2c9c26ea30f..7df88770e029 100644
>> --- a/include/uapi/linux/netlink.h
>> +++ b/include/uapi/linux/netlink.h
>> @@ -69,6 +69,10 @@ struct nlmsghdr {
>>  #define NLM_F_CREATE	0x400	/* Create, if it does not exist	*/
>>  #define NLM_F_APPEND	0x800	/* Add to end of list		*/
>>  
>> +/* Flags for ACK message */
>> +#define NLM_F_CAPPED	0x100	/* request was capped */
>> +#define NLM_F_ACK_TLVS	0x200	/* extended ACK TVLs were included */
>> +
>>  /*
>>     4.4BSD ADD		NLM_F_CREATE|NLM_F_EXCL
>>     4.4BSD CHANGE	NLM_F_REPLACE
>> @@ -101,6 +105,33 @@ struct nlmsghdr {
>>  struct nlmsgerr {
>>  	int		error;
>>  	struct nlmsghdr msg;
>> +	/*
>> +	 * followed by the message contents unless NETLINK_CAP_ACK was set
>> +	 * or the ACK indicates success (error == 0)
>> +	 * message length is aligned with NLMSG_ALIGN()
>> +	 */
>> +	/*
>> +	 * followed by TLVs defined in enum nlmsgerr_attrs
>> +	 * if NETLINK_EXT_ACK was set
>> +	 */
>> +};
>> +
>> +/**
>> + * enum nlmsgerr_attrs - nlmsgerr attributes
>> + * @NLMSGERR_ATTR_UNUSED: unused
>> + * @NLMSGERR_ATTR_MSG: error message string (string)
>> + * @NLMSGERR_ATTR_OFFS: offset of the invalid attribute in the original
>> + *	 message, counting from the beginning of the header (u32)
>> + * @__NLMSGERR_ATTR_MAX: number of attributes
>> + * @NLMSGERR_ATTR_MAX: highest attribute number
>> + */
>> +enum nlmsgerr_attrs {
>> +	NLMSGERR_ATTR_UNUSED,
>> +	NLMSGERR_ATTR_MSG,
>
>There was a discussion about side effects of adding strings (bloat,
>internationalization). Should ATTR_MSG be removed until that is ironed
>out? Leaving it in suggests it is ok to start adding strings.

I believe that we need strings right away. Without them, this patchset
really does not make much sense.

From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next RFC v2 2/3] ipv4: add support for light weight
 tunnel encap attributes
Date: Fri, 19 Jun 2015 07:19:20 -0700
Message-ID: <558424E8.5090806@cumulusnetworks.com>
References: <1434689355-4088-3-git-send-email-roopa@cumulusnetworks.com> <alpine.LFD.2.11.1506190857520.1731@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, rshearma@brocade.com, tgraf@suug.ch,
	davem@davemloft.net, netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:35790 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751954AbbFSOTX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2015 10:19:23 -0400
Received: by pdbci14 with SMTP id ci14so33202095pdb.2
        for <netdev@vger.kernel.org>; Fri, 19 Jun 2015 07:19:22 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.11.1506190857520.1731@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/18/15, 11:59 PM, Julian Anastasov wrote:
> 	Hello,
>
> On Thu, 18 Jun 2015, Roopa Prabhu wrote:
>
>> @@ -366,6 +371,7 @@ static inline size_t fib_nlmsg_size(struct fib_info *fi)
>>   	payload += nla_total_size((RTAX_MAX * nla_total_size(4)));
>>   
>>   	if (fi->fib_nhs) {
>> +		size_t nh_encapsize = 0;
> 	Var not in #ifdef. Any warnings with CONFIG_LWTUNNEL=n?
>
>>   		/* Also handles the special case fib_nhs == 1 */
>>   
>>   		/* each nexthop is packed in an attribute */
>> @@ -374,8 +380,23 @@ static inline size_t fib_nlmsg_size(struct fib_info *fi)
>>   		/* may contain flow and gateway attribute */
>>   		nhsize += 2 * nla_total_size(4);
>>   
>> +#ifdef CONFIG_LWTUNNEL
>> +		/* grab encap info */
>> +		for_nexthops(fi) {
>> +			if (nh->nh_lwtstate) {
>> +				/* RTA_ENCAP_TYPE */
>> +				nh_encapsize += lwtunnel_get_encap_size(
>> +						nh->nh_lwtstate);
> 	New labels not in #ifdef:
Will check and fix all warnings with CONFIG_LWTUNNEL off
>
>> +
>> +err_inval:
>> +	ret = -EINVAL;
>> +
>> +errout:
>> +	return ret;
>>   }
> 	Some other places may need changes:
>
> - nh_comp: there is logic that decides if same fib_info
> is reused from many fib nodes. There should be check
> if NH matches by nh_lwtstate.

yes, i will add that.
>
> - xfrm4_fill_dst: not sure about this but some fields
> are copied.
>
I have not picked up xfrm4_fill_dst specifically, but this infra is 
supposed to be similar to that.
I will look.

Thanks.

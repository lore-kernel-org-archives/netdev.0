From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 2/3] mpls: consistently use u8 to store number
 of labels
Date: Wed, 12 Aug 2015 20:25:02 -0700
Message-ID: <55CC0E0E.4080206@cumulusnetworks.com>
References: <1439329548-50935-3-git-send-email-roopa@cumulusnetworks.com> <55CB9BBE.2000303@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ebiederm@xmission.com, netdev@vger.kernel.org
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:32792 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751802AbbHMDZF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 23:25:05 -0400
Received: by pabyb7 with SMTP id yb7so27766325pab.0
        for <netdev@vger.kernel.org>; Wed, 12 Aug 2015 20:25:04 -0700 (PDT)
In-Reply-To: <55CB9BBE.2000303@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/12/15, 12:17 PM, Robert Shearman wrote:
> On 11/08/15 22:45, Roopa Prabhu wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> change all types representing number of labels to u8
>> to be consistent.
>>
>> This also changes labels to u8 in the light weight
>> mpls_tunnel_encap structure. This is because the
>> light weight mpls iptunnel code shares some of the label
>> encoding functions like nla_get/put_labels with the af_mpls
>> code.
>>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>> ---
> ...
>> @@ -243,11 +243,11 @@ static const struct nla_policy 
>> rtm_mpls_policy[RTA_MAX+1] = {
>>   struct mpls_route_config {
>>       u32            rc_protocol;
>>       u32            rc_ifindex;
>> -    u16            rc_via_table;
>> -    u16            rc_via_alen;
>> +    u8            rc_via_table;
>> +    u8            rc_via_alen;
>
> IMHO, it would be better to make rc_via_alen an int to avoid overflow 
> which could cause false negatives in this check on the RTA_VIA attribute:
>
>             if (cfg->rc_via_alen > MAX_VIA_ALEN)
>                 goto errout;
>

ok,
> ...
>>       u8            rc_via[MAX_VIA_ALEN];
>> +    u8            rc_output_labels;
>>       u32            rc_label;
>> -    u32            rc_output_labels;
>>       u32            rc_output_label[MAX_NEW_LABELS];
>>       u32            rc_nlflags;
>>       enum mpls_payload_type    rc_payload_type;
>> @@ -751,7 +751,7 @@ int nla_put_labels(struct sk_buff *skb, int 
>> attrtype,
>>   EXPORT_SYMBOL_GPL(nla_put_labels);
>>
>>   int nla_get_labels(const struct nlattr *nla,
>> -           u32 max_labels, u32 *labels, u32 label[])
>> +           u32 max_labels, u8 *labels, u32 label[])
>
> How about making max_labels a u8? That would make it even more 
> consistent and avoids any problem of overflow in the number of labels.
>
yes, I did want to change max_labels to u8. will do in v2.

thanks,
Roopa

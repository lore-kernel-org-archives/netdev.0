From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [PATCH net] macvtap: fix network header pointer for VLAN tagged
 pkts
Date: Tue, 21 Jul 2015 09:11:38 +0200
Message-ID: <55ADF0AA.1020209@redhat.com>
References: <1437407061-8698-1-git-send-email-ivecera@redhat.com> <55AD2502.5060203@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Vlad Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46778 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752597AbbGUHKz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jul 2015 03:10:55 -0400
In-Reply-To: <55AD2502.5060203@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/20/2015 06:42 PM, Vlad Yasevich wrote:
> On 07/20/2015 11:44 AM, Ivan Vecera wrote:
>> Network header is set with offset ETH_HLEN but it is not true for VLAN
>> (multiple-)tagged and results in checksum issues in lower devices.
>>
>> Signed-off-by: Ivan Vecera <ivecera@redhat.com>
>> ---
>>   drivers/net/macvtap.c | 6 ++++++
>>   1 file changed, 6 insertions(+)
>>
>> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
>> index 3b933bb..cdcbab4 100644
>> --- a/drivers/net/macvtap.c
>> +++ b/drivers/net/macvtap.c
>> @@ -796,6 +796,12 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
>>   	skb_reset_mac_header(skb);
>>   	skb->protocol = eth_hdr(skb)->h_proto;
>>
>> +	if (skb_vlan_tagged(skb)) {
>> +		int depth;
>> +		skb->protocol = __vlan_get_protocol(skb, skb->protocol, &depth);
>
> I don't think this is right.  This would reset the protocol to the encapsulated
> protocol which isn't really the case since you are not really stripping vlan
> encapsulations.
>
> -vlad
Yup, you are right, skb->protocol should be untouched. Will post v2.

Ivan

From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 2/3] net: mpls: Fixups for GSO
Date: Mon, 22 Aug 2016 07:11:27 -0600
Message-ID: <dcf3df40-3914-37c6-55dc-e5c3de7530b5@cumulusnetworks.com>
References: <1471626542-13335-1-git-send-email-dsa@cumulusnetworks.com>
 <1471626542-13335-3-git-send-email-dsa@cumulusnetworks.com>
 <20160822122122.GA8689@penelope.isobedori.kobe.vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        buytenh@wantstofly.org, ebiederm@xmission.com,
        rshearma@brocade.com, tom@herbertland.com, tgraf@suug.ch,
        olivier.dugeon@orange.com, alexander.duyck@gmail.com,
        roopa@cumulusnetworks.com
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:35816 "EHLO
        mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754196AbcHVNL1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 09:11:27 -0400
Received: by mail-io0-f173.google.com with SMTP id m101so109107448ioi.2
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 06:11:27 -0700 (PDT)
In-Reply-To: <20160822122122.GA8689@penelope.isobedori.kobe.vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/22/16 6:21 AM, Simon Horman wrote:
>> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
>> index 1ecbd7715f6d..6d78f162a88b 100644
>> --- a/net/openvswitch/actions.c
>> +++ b/net/openvswitch/actions.c
>> @@ -167,6 +167,12 @@ static int push_mpls(struct sk_buff *skb, struct sw_flow_key *key,
>>  		skb->mac_len);
>>  	skb_reset_mac_header(skb);
>>  
>> +	/* for GSO: set MPLS as network header and encapsulated protocol
>> +	 * header as inner network header
>> +	 */
>> +	skb_set_network_header(skb, skb->mac_len);
>> +	skb_set_inner_network_header(skb, skb->mac_len + MPLS_HLEN);
>> +
>>  	new_mpls_lse = (__be32 *)skb_mpls_header(skb);
>>  	*new_mpls_lse = mpls->mpls_lse;
> 
> Is the above calculation correct if push_mpls() is called multiple times?
> 

No. Does OVS support more than 1? I really need someone who is familiar with the OVS code to make sure it works for all use cases. e.g., set skb_set_inner_network_header() before pushing a series of MPLS labels.

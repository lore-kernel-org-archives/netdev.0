From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 2/2] net: original ingress device index in
 PKTINFO
Date: Sat, 7 May 2016 08:53:44 -0600
Message-ID: <572E0178.4010601@cumulusnetworks.com>
References: <1462585781-9146-1-git-send-email-dsa@cumulusnetworks.com>
 <1462585781-9146-3-git-send-email-dsa@cumulusnetworks.com>
 <20160507114148.347716e4@halley>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:35624 "EHLO
	mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750722AbcEGOxs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2016 10:53:48 -0400
Received: by mail-io0-f170.google.com with SMTP id d62so138674285iof.2
        for <netdev@vger.kernel.org>; Sat, 07 May 2016 07:53:47 -0700 (PDT)
In-Reply-To: <20160507114148.347716e4@halley>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/7/16 2:41 AM, Shmulik Ladkani wrote:
> Hi David,
>
> On Fri,  6 May 2016 18:49:41 -0700 David Ahern <dsa@cumulusnetworks.com> wrote:
>> Applications such as OSPF and BFD need the original ingress device not
>> the VRF device;
>
> Would you consider this true for any IP_PKTINFO users in VRF setups?

yes. I was just giving specific examples, but certainly every app I am 
aware of wants the enslaved index. If an app pops up that wants the vrf 
index it can be derived from the enslaved index.

>
>> @@ -1193,7 +1193,12 @@ void ipv4_pktinfo_prepare(const struct sock *sk, struct sk_buff *skb)
>>   		       ipv6_sk_rxinfo(sk);
>>
>>   	if (prepare && skb_rtable(skb)) {
>> -		pktinfo->ipi_ifindex = inet_iif(skb);
>> +		/* skb->cb is overloaded: prior to this point it is IP{6}CB
>> +		 * which has interface index (iif) as the first member of the
>> +		 * underlying inet{6}_skb_parm struct. This code then overlays
>> +		 * PKTINFO_SKB_CB and in_pktinfo also has iif as the first
>> +		 * element so the iif is picked up from the prior IPCB
>> +		 */
>
> Better if there was a guarantee in the code that inet_skb_parm layout stays
> that way. Or instead just explicitly assign the iif.

At this point inet_iif points to the vrf device so can't use it.

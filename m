From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [patch iproute2 1/6] iproute2: ipa: show switch id
Date: Thu, 04 Dec 2014 06:29:43 -0800
Message-ID: <54806FD7.50608@cumulusnetworks.com>
References: <1417683438-10935-1-git-send-email-jiri@resnulli.us> <1417683438-10935-2-git-send-email-jiri@resnulli.us> <20141204142015.GR27416@gospo.rtplab.test>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, linville@tuxdriver.com, jasowang@redhat.com,
	ebiederm@xmission.com, nicolas.dichtel@6wind.com,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, nbd@openwrt.org, alexei.starovoitov@gmail.com,
	Neil.Jerram@metaswitch.com, ronye@mellanox.com,
	simon.horman@netronome.com, alexander.h.duyck@redhat.com,
	john.ronciak@intel.com, mleitner@redhat.com, shrijeet@gmail.com,
	bcrl@kvack.org, hemal@broadcom.c
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:38504 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753826AbaLDO37 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 09:29:59 -0500
In-Reply-To: <20141204142015.GR27416@gospo.rtplab.test>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/4/14, 6:20 AM, Andy Gospodarek wrote:
> On Thu, Dec 04, 2014 at 09:57:13AM +0100, Jiri Pirko wrote:
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> ---
>>   include/linux/if_link.h | 1 +
>>   ip/ipaddress.c          | 8 ++++++++
>>   2 files changed, 9 insertions(+)
>>
>> diff --git a/include/linux/if_link.h b/include/linux/if_link.h
>> index 4732063..a6e2594 100644
>> --- a/include/linux/if_link.h
>> +++ b/include/linux/if_link.h
>> @@ -145,6 +145,7 @@ enum {
>>   	IFLA_CARRIER,
>>   	IFLA_PHYS_PORT_ID,
>>   	IFLA_CARRIER_CHANGES,
>> +	IFLA_PHYS_SWITCH_ID,
> Serious question for Stephen et al, once we take this to iproute2 are we
> going to be able to change the name but the string diplayed if needed?
>
> I had a patch that called this IFLA_PARENT_ID that I was using with the
> older github tree used by Jiri and Scott before these were in net-next.
> I wanted to submit that as a change to what became
> 82f2841291cfaf4d225aa1766424280254d3e3b2, but was waiting for things to
> be accepted and the dust settled.
>
> I like the parent/child/sibling nomenclature better for 4 reasons:
>
> - Most did not seem to like the term 'offload' since that term would be
>    confusing with, GRO, GSO, etc.
> - A *significant* use case for many of the high-end ASICs in datacenters
>    is routing.
> - switchid does not make sense in the OVS/flow case because it is all
>    about flows, not switches or routers, and parent made sense there.
> - I wanted to combine this for use with SR-IOV use case, so one can more
>    easily map PF->VF using this.

ack.., I have voted for calling it a generic parent id in the past.
>
> Can you give me a bit (a day) to clean-up that patch and submit an
> alternative proposal to these?
>
>>   	__IFLA_MAX
>>   };
>>   
>> diff --git a/ip/ipaddress.c b/ip/ipaddress.c
>> index 4d99324..bd36a07 100644
>> --- a/ip/ipaddress.c
>> +++ b/ip/ipaddress.c
>> @@ -589,6 +589,14 @@ int print_linkinfo(const struct sockaddr_nl *who,
>>   				      b1, sizeof(b1)));
>>   	}
>>   
>> +	if (tb[IFLA_PHYS_SWITCH_ID]) {
>> +		SPRINT_BUF(b1);
>> +		fprintf(fp, "switchid %s ",
>> +			hexstring_n2a(RTA_DATA(tb[IFLA_PHYS_SWITCH_ID]),
>> +				      RTA_PAYLOAD(tb[IFLA_PHYS_SWITCH_ID]),
>> +				      b1, sizeof(b1)));
>> +	}
>> +
>>   	if (tb[IFLA_OPERSTATE])
>>   		print_operstate(fp, rta_getattr_u8(tb[IFLA_OPERSTATE]));
>>   
>> -- 
>> 1.9.3
>>

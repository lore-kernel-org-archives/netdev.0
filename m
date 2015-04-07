From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 6/8] iproute2: Add support for the RTA_VIA attribute
Date: Tue, 07 Apr 2015 11:15:04 -0700
Message-ID: <55241EA8.9000909@cumulusnetworks.com>
References: <87bnjwspek.fsf@x220.int.ebiederm.org> <c3ad7d77783046d38e5b23b5e1fe0f71@BRMWP-EXMB11.corp.brocade.com> <20150315123337.2694183a@urahara> <87lhiyoxnw.fsf@x220.int.ebiederm.org> <87bnjuoxe8.fsf_-_@x220.int.ebiederm.org> <87d24animx.fsf_-_@x220.int.ebiederm.org> <552310E6.5060503@cumulusnetworks.com> <20150406232713.GR1051@gospo> <5523EFEB.1030205@cumulusnetworks.com> <87pp7for7v.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Gospodarek <gospo@cumulusnetworks.com>,
	Stephen Hemminger <shemming@brocade.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Vivek Venkatraman <vivek@cumulusnetworks.com>,
	rshearma@brocade.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:35075 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750983AbbDGSPF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 14:15:05 -0400
Received: by patj18 with SMTP id j18so86672894pat.2
        for <netdev@vger.kernel.org>; Tue, 07 Apr 2015 11:15:05 -0700 (PDT)
In-Reply-To: <87pp7for7v.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/7/15, 9:09 AM, Eric W. Biederman wrote:
> roopa <roopa@cumulusnetworks.com> writes:
>
>> On 4/6/15, 4:27 PM, Andy Gospodarek wrote:
>>> On Mon, Apr 06, 2015 at 04:04:06PM -0700, roopa wrote:
>>>> On 3/15/15, 12:52 PM, Eric W. Biederman wrote:
>>>>> Add support for the RTA_VIA attribute that specifies an address family
>>>>> as well as an address for the next hop gateway.
>>>>>
>>>>> To make it easy to pass this reorder inet_prefix so that it's tail
>>>>> is a proper RTA_VIA attribute.
>>>>>
>>>>> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
>>>>> ---
>>>>>    include/linux/rtnetlink.h |  7 +++++
>>>>>    include/utils.h           |  7 +++--
>>>>>    ip/iproute.c              | 76 +++++++++++++++++++++++++++++++++++++++++------
>>>>>    man/man8/ip-route.8.in    | 18 +++++++----
>>>>>    4 files changed, 90 insertions(+), 18 deletions(-)
>>>>>
>>>>> diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
>>>>> index 3eb78105399b..03e4c8df8e60 100644
>>>>> --- a/include/linux/rtnetlink.h
>>>>> +++ b/include/linux/rtnetlink.h
>>>>> @@ -303,6 +303,7 @@ enum rtattr_type_t {
>>>>>    	RTA_TABLE,
>>>>>    	RTA_MARK,
>>>>>    	RTA_MFC_STATS,
>>>>> +	RTA_VIA,
>>>> eric, if its not too late, what do you think about renaming RTA_VIA
>>>> attribute to
>>>> RTA_NEWGATEWAY (similar to your new RTA_NEWDST attribute to specify a label
>>>> dst) ?. RTA_VIA is fine too.
>>>> This is indeed a new way to specify a gateway (and can/will be used by RFC
>>>> 5549 in the future).
>>>>
>>>> If there is interest in renaming it to RTA_NEWGATEWAY (or any other name,
>>>> cant think of anything better right now),
>>>> I will be happy to submit a follow-on patch.
>>> FWIW, I actually do not mind the name RTA_VIA.  I was planning to
>>> replace use of RTA_GATEWAY in iproute2 and just usa RTA_VIA for all
>>> nexthops regardless of the address family of the dest route or nexthop
>>> and would allow easy creation of the infrastructure needed to support
>>> RFC5549 -- obviously while keeping backwards compatibility in the
>>> kernel.
>> ok, good to know.
> To answer the original question.  The new in RTA_NEWDST is not new as in
> a new attribute it is new as in replace the destination address with a
> new destination address.  NAT in other words.  Which is how mpls routing
> works.  Each hop NATs the address before sending the packet on.
thanks for the clarifying this.
>
>>> This was what my orignal set did (not submitted to netdev, but discussed
>>> with others at netconf) and it was much cleaner code-wise (but not ideal
>>> as I overloaded the use of RTA_GATEWAY and that was not pleasing to me
>>> or others).
>> ok, yeah i remember you had RTA_GATEWAY6 or something like that.
>>
>> just to clarify, i was not suggesting overloading.
>> eric introduced cleaner abstracted attributes for RTA_DST and RTA_GATEWAY.
>> One is called RTA_NEWDST and I was thinking if changing RTA_GATEWAY to
>> RTA_NEWGATEWAY
>> would be less confusing (because, the rest of the structures
>> (ipv4/ipv6) where you will put the
>> RTA_VIA information is still called gw).
>>
>> No worries, RTA_VIA can stay if more people prefer that.
> As long as the number and the semantics don't change I don't much care.
>
> However I think via is probably what we should have called the concept
> and the field in the first place, and certainly there are corner cases
> where the machine where we are going via is not actually a gateway but
> the final destination, when you are talking about multiple protocols.
agreed.

>
> Regardless the name RTA_VIA is my best attempt in that direction.
ack
>
> All of my added support in iproute2 should work for RFC5549.  As well as
> for mpls.
>
>
agreed.

and thanks.

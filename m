From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net iproute2 v2 1/2] mpls: always set type as RTN_UNICAST
 for route add/deletes
Date: Thu, 28 May 2015 10:15:33 +0100
Message-ID: <5566DCB5.3000909@brocade.com>
References: <1432751825-40804-2-git-send-email-roopa@cumulusnetworks.com> <5566221A.5020001@brocade.com> <55662439.7010503@cumulusnetworks.com> <55665C19.4060209@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <ebiederm@xmission.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <vivek@cumulusnetworks.com>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:34871 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751673AbbE1JRq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 05:17:46 -0400
In-Reply-To: <55665C19.4060209@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28/05/15 01:06, roopa wrote:
> On 5/27/15, 1:08 PM, roopa wrote:
>> On 5/27/15, 12:59 PM, Robert Shearman wrote:
>>> On 27/05/15 19:37, Roopa Prabhu wrote:
>>>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>>
>>>> Kernel expects type RTN_UNICAST for mpls route/dels
>>>>
>>>> Signed-off-by: Vivek Venkataraman <vivek@cumulusnetworks.com>
>>>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>> ---
>>>>   ip/iproute.c |    5 +++++
>>>>   1 file changed, 5 insertions(+)
>>>>
>>>> diff --git a/ip/iproute.c b/ip/iproute.c
>>>> index 670a4c6..71c088b 100644
>>>> --- a/ip/iproute.c
>>>> +++ b/ip/iproute.c
>>>> @@ -803,6 +803,7 @@ static int iproute_modify(int cmd, unsigned
>>>> flags, int argc, char **argv)
>>>>       int scope_ok = 0;
>>>>       int table_ok = 0;
>>>>       int raw = 0;
>>>> +    int type_ok = 0;
>>>>
>>>>       memset(&req, 0, sizeof(req));
>>>>
>>>> @@ -1095,6 +1096,7 @@ static int iproute_modify(int cmd, unsigned
>>>> flags, int argc, char **argv)
>>>>                   rtnl_rtntype_a2n(&type, *argv) == 0) {
>>>>                   NEXT_ARG();
>>>>                   req.r.rtm_type = type;
>>>> +                type_ok = 1;
>>>>               }
>>>>
>>>>               if (matches(*argv, "help") == 0)
>>>> @@ -1160,6 +1162,9 @@ static int iproute_modify(int cmd, unsigned
>>>> flags, int argc, char **argv)
>>>>           }
>>>>       }
>>>>
>>>> +    if (!type_ok && req.r.rtm_family == AF_MPLS)
>>>> +        req.r.rtm_type = RTN_UNICAST;
>>>> +
>>>>       if (req.r.rtm_family == AF_UNSPEC)
>>>>           req.r.rtm_family = AF_INET;
>>>>
>>>>
>>>
>>> There is this block of code near the start of iproute_modify that
>>> sets req.r.rtm_type in the add/modify cases:
>>>
>>>         if (cmd != RTM_DELROUTE) {
>>>                 req.r.rtm_protocol = RTPROT_BOOT;
>>>                 req.r.rtm_scope = RT_SCOPE_UNIVERSE;
>>>                 req.r.rtm_type = RTN_UNICAST;
>>>         }
>>>
>>> How about doing similar for the mpls delete case? This would avoid
>>> the need to track if the type has been set and would also make the
>>> way rtm_type is set in the delete case as close as possible to that
>>> in the add/modify cases.
>> sure that works too. There was already *_ok checks for the rest of the
>> attributes, ..so added it there.
>>
>> v3 ...coming...
>>
> looking at the code again..now i remember why i have it this way. I will
> have to add a check for family around
> the code you point out above. And it some cases if the user has not
> specified the family explicitly, we derive the msg family
> in the while loop that parses the args...based on the other arguments
> given by the user.
> In the particular mpls case though, user explicitly specifies the family
> and moving the patch to the code you point above should be ok.
>
> But to be consistent with the rest of the code, it seems better to do
> the check and set the defaults at the end after parsing all the args.
>
> So, now i am inclined to keep the v2 patch as is...unless you have
> strong reasons.

Ah, yes, of course.

In that case, LGTM.

Thanks,
Rob

From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v4 1/2] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Wed, 19 Apr 2017 12:07:48 -0400
Message-ID: <56488055-1f4b-ee10-2357-5ce80f1fbc50@mojatatu.com>
References: <1492603050-9318-1-git-send-email-jhs@emojatatu.com>
 <20170419123645.GB3357@nanopsycho.orion>
 <705a4d67-4a81-113f-e22a-0ca0bb6cf1eb@mojatatu.com>
 <20170419131323.GE3357@nanopsycho.orion>
 <e2a1e201-4830-e600-e668-91f83bcc9b32@mojatatu.com>
 <20170419155400.GH3357@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        eric.dumazet@gmail.com, xiyou.wangcong@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:35863 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1765996AbdDSQHv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 12:07:51 -0400
Received: by mail-it0-f67.google.com with SMTP id a140so4054981ita.3
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 09:07:50 -0700 (PDT)
In-Reply-To: <20170419155400.GH3357@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-19 11:54 AM, Jiri Pirko wrote:
> Wed, Apr 19, 2017 at 05:37:15PM CEST, jhs@mojatatu.com wrote:
>> On 17-04-19 09:13 AM, Jiri Pirko wrote:
>>> Wed, Apr 19, 2017 at 03:03:59PM CEST, jhs@mojatatu.com wrote:
>>>> On 17-04-19 08:36 AM, Jiri Pirko wrote:
>>>>> Wed, Apr 19, 2017 at 01:57:29PM CEST, jhs@mojatatu.com wrote:
>>>>>> From: Jamal Hadi Salim <jhs@mojatatu.com>
>>>>
>>>>>> include/uapi/linux/rtnetlink.h | 21 +++++++++++++++++++--
>>>>>> net/sched/act_api.c            | 43 ++++++++++++++++++++++++++++++++----------
>>>>>> 3 files changed, 53 insertions(+), 12 deletions(-)
>>
>>>>>> +#define TCAA_MAX (__TCAA_MAX - 1)
>>>>>> #define TA_RTA(r)  ((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct tcamsg))))
>>>>>> #define TA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct tcamsg))
>>>>>> -#define TCA_ACT_TAB 1 /* attr type must be >=1 */	
>>>>>> -#define TCAA_MAX 1
>>>>>> +#define TCA_ACT_TAB TCAA_ACT_TAB
>>>>>
>>>>> This is mess. What does "TCAA" stand for?
>>>>
>>>> TC Actions Attributes.  What would you call it? I could have
>>>> called it TCA_ROOT etc. But maybe a comment to just call it
>>>> TC Actions Attributes would be enough?
>>>
>>> TCA_DUMP_X
>>>
>>> it is only for dumping. Naming it "attribute" seems weird. Same as if
>>> you have: int variable_something;
>>>
>>
>> Jiri, this is not just for dumping. We are describing high level
>> attributes for tc actions.
>
> This is already present:
> enum {
>         TCA_ACT_UNSPEC,
>         TCA_ACT_KIND,
>         TCA_ACT_OPTIONS,
>         TCA_ACT_INDEX,
>         TCA_ACT_STATS,
>         TCA_ACT_PAD,
>         TCA_ACT_COOKIE,
>         __TCA_ACT_MAX
> };
>
> This is nested inside the dump message (TCAA_MAX, TCA_ACT_TAB)
>
> Looks like you are mixing these 2.
>

No - That space is per action. The space i am defining is
above that in the the hierarchy. There used to be only
one attribute there (TCA_ACT_TAB) and now we are making
it more generic.

>
>

>> It is a _lot_ of code to change! Note:
>> This is all the UAPI visible code (the same coding style for 20 years).
>> I am worried about this part.
>
> We'll see. Lets do it in a sensitive way, in steps. But for new things,
> I think it is good not to stick with old and outlived habits.
>
>

I know you have the muscle to get it done - so fine, i will start
with this one change.

>
> Netlink is TLV, should be used as TLV. I don't see how you can run out
> any space. You tend to use Netlink in some weird hybrid mode, with only
> argument being space. I think that couple of bytes wasted is not
> a problem at all...
>

You are not making sense to me still.
What you describe as "a couple of bytes" adds up when you have
a large number of objects. I am trying to cut down on data back
and forth from user/kernel and a bitmap is a well understood entity.

Even if i did use a TLV - when i am representing flags which require one
bit each - it makes sense to use a bitmask encapsulated in a TLV. Not
to waste a TLV per bit.

cheers,
jamal

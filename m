From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net-next v2 2/2] net_sched: add network namespace support
 for tc actions
Date: Wed, 24 Feb 2016 08:19:23 -0500
Message-ID: <56CDADDB.5070003@mojatatu.com>
References: <1456185473-25403-1-git-send-email-xiyou.wangcong@gmail.com>
 <1456185473-25403-3-git-send-email-xiyou.wangcong@gmail.com>
 <56CC5B35.4060408@mojatatu.com>
 <CAM_iQpVVe28XUkSfR1OhwMq6mgJVQ_zcPJn+xmLpb_YDy0wsDg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:35292 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757170AbcBXNT0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 08:19:26 -0500
Received: by mail-io0-f177.google.com with SMTP id g203so37864822iof.2
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2016 05:19:25 -0800 (PST)
In-Reply-To: <CAM_iQpVVe28XUkSfR1OhwMq6mgJVQ_zcPJn+xmLpb_YDy0wsDg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-23 05:23 PM, Cong Wang wrote:
> On Tue, Feb 23, 2016 at 5:14 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:

>> It doesnt seem neccessary to have hinfo in tc_action. Quick scan:
>> __tcf_hash_release() seems to be the only other place that uses it.
>> And the callers to that appear capable of passing the struct
>> net or tn  which eventually propagates up...
>
> The tcf_action_destroy() callchain still can't find out hinfo yet.
>

Did you mean something else or am i missing the obvious?
I am looking at the call sites for tcf_action_destroy():
-tc_dump_tfilter() has access to *net
-tcf_exts_change() - one level lower it has access to *net; i think you 
added this to your patch too.
-tcf_action_init() has *net.

> I know this is one of the ugly parts, this is why I mentioned it
> in the changelog that we should refactor it. Do you mind if I
> refactor this later?
>

I didnt understand the problem.

>> That also seemed unneeded. You could have derived hinfo
>> from tn.
>
> This is a pure taste of the API, I want to hide the hinfo as much as
> I can and expose tn to callers.
>

I dont know how i missed that;->

>>
>> Otherwise looks reasonable. I was hoping we could get rid of the per
>> action pernet ops but that could come later.
>>
>
> That is hard (if not impossible), because we have to allocate the pernet
> ops on heap, which seems not doable.
>

We can worry later. I thought there was a way to do it with compilation
into namespaces.

cheers,
jamal

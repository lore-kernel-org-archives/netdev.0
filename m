From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH 3/4] net: sched: cls_u32 add bit to specify software
 only rules
Date: Thu, 25 Feb 2016 08:39:48 -0800
Message-ID: <56CF2E54.40404@gmail.com>
References: <20160223190233.5970.61226.stgit@john-Precision-Tower-5810> <20160223190321.5970.58924.stgit@john-Precision-Tower-5810> <20160224080440.GA26500@office.Home> <20160224084057.GC2151@nanopsycho.orion> <56CD701B.8070308@gmail.com> <20160224102907.05aa8e42@griffin> <56CE7E8A.3040202@gmail.com> <56CEFF75.8070106@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, "Amir Vadai\"" <amir@vadai.me>,
	daniel@iogearbox.net, netdev@vger.kernel.org,
	alexei.starovoitov@gmail.com, davem@davemloft.net
To: Jamal Hadi Salim <jhs@mojatatu.com>, Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34910 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757854AbcBYQkC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 11:40:02 -0500
Received: by mail-pa0-f47.google.com with SMTP id ho8so35755812pac.2
        for <netdev@vger.kernel.org>; Thu, 25 Feb 2016 08:40:02 -0800 (PST)
In-Reply-To: <56CEFF75.8070106@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-25 05:19 AM, Jamal Hadi Salim wrote:
> On 16-02-24 11:09 PM, John Fastabend wrote:
>> On 16-02-24 01:29 AM, Jiri Benc wrote:
>>> On Wed, 24 Feb 2016 00:55:55 -0800, John Fastabend wrote:
>>>> The flags however likely stays with with TCA_U32_FLAGS until there is
>>>> some better way to group common attributes in 'tc' framework.
>>>
>>> That's pretty bad, as this is uAPI and will need to be supported
>>> forever. And having a different attribute in every filter won't ease
>>> things for user space tools. I'd say we need the "better way" to be
>>> added before this patchset.
>>>
>>>   Jiri
>>>
>>
>> The 'tc' semantics seem to support this "pretty bad" API design
>> with many of the fields already duplicated.
> 
> Mostly this is a netlink-ism. Netlink has the same problem with
> command name spaces. The problem is mixing verbs and nouns together.
> I like the switchdev approach where you have very few verbs
> (SET, GET etc) and the content of the object or path describes
> the nouns. This is why initially i thought it was better to have
> this offload passing by switchdev. Could we leverage some of that?
> 

No I don't think so. Either way you need some flag at the 'tc' layer
to push this down to hardware offload ops.

>> I suppose we could
>> put the flags at the same level as the TCA_* attributes but this
>> also doesn't seem right to me as it isn't actually handled until
>> we get into the TCA_#CLASSIFIER#_* set of attributes.
>>
> 
> Could we not steal a couple of bits off netlink flags? Then it applies
> to all subssystems.

I did that in some original patch I never sent but I didn't like it.
Netlink is used for all sorts of things and those flags already have
a meaning. We've already started this trend of using flags inside the
specific messages for other things like the bridge code. And there are
only a few bits left in the rtnetlink flags field I would prefer to
save them for something necessary.

In the end I think the solution here is really not that bad the
userspace code to add it is trivial (~5 lines of code). Its not
how I would do it if I was writing the entire OS from scratch
but we have to maintain UAPI so not sure I have any better solutions.

> 
> cheers,
> jamal
> 

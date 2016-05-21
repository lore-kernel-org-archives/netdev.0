From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IPv6 extension header privileges
Date: Sat, 21 May 2016 18:16:53 +0200
Message-ID: <f007389f-4ed1-2b67-69b5-28cd999264b9@stressinduktion.org>
References: <CALx6S36x2+HBLSYVBi0+rQAgejbVvvFF7fr0P13cTspxpJQCLg@mail.gmail.com>
 <1e22f140-920e-0d1c-4a43-03780fb380a8@stressinduktion.org>
 <20160521015604.GD2452@oracle.com>
 <1463823275.2335717.614453105.5011B2EE@webmail.messagingengine.com>
 <CALx6S36V8Bv1R+rKWB7u=Y8371aT7JybDdkEErrRtw_bsHrMaA@mail.gmail.com>
 <6a889c73-efb1-7d4c-ba33-8b076378fcb7@stressinduktion.org>
 <CALx6S36scChuaS+uygAu4zk9gEz_qA=BSwX4f=kC_YXurTpMqw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:43730 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752090AbcEUQQ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 May 2016 12:16:57 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id A772F20BAD
	for <netdev@vger.kernel.org>; Sat, 21 May 2016 12:16:56 -0400 (EDT)
In-Reply-To: <CALx6S36scChuaS+uygAu4zk9gEz_qA=BSwX4f=kC_YXurTpMqw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21.05.2016 18:00, Tom Herbert wrote:
> On Sat, May 21, 2016 at 8:33 AM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
>> On 21.05.2016 17:19, Tom Herbert wrote:
>>> On Sat, May 21, 2016 at 2:34 AM, Hannes Frederic Sowa
>>> <hannes@stressinduktion.org> wrote:
>>>> On Sat, May 21, 2016, at 03:56, Sowmini Varadhan wrote:
>>>>> On (05/21/16 02:20), Hannes Frederic Sowa wrote:
>>>>>>
>>>>>> There are some options inherently protocol depending like the jumbo
>>>>>> payload option, which should be under control of the kernel, or the
>>>>>> router alert option for igmp, which causes packets to be steered towards
>>>>>> the slow/software path of routers, which can be used for DoS attacks.
>>>>>>
>>>>>> Setting CALIPSO options in IPv6 on packets as users would defeat the
>>>>>> whole CALIPSO model, etc.
>>>>>>
>>>>>> The RFC3542 requires at least some of the options in dst/hop-by-hop
>>>>>
>>>>> "requires" is a strong word. 3542 declares it as a  "may" (lower case).
>>>>> The only thing required strongly is IPV6_NEXTHOP itself.
>>>>>
>>>>> I suspect 3542 was written at a time when hbh and dst opt were loosely
>>>>> defined and the "may" is just a place-holder (i.e., it's not even a MAY)
>>>>
>>>> My wording directly from the RFC was too strong, true, but given that
>>>> there is a CALIPSO patch already floating around for the kernel and
>>>> those options are strictly controlled by selinux policy and build the
>>>> foundation for the networking separation we can't make it simply
>>>> non-priv.
>>>>
>>> If you don't mind I'll change this to make specific options are
>>> privileged and not all hbh and destopt. There is talk in IETF about
>>> reinventing IP extensibility within UDP since the kernel APIs don't
>>> allow setting EH. I would like to avoid that :-)
>>
>> Hehe, certainly.
>>
>> A white list of certain registered IPv6 IANA-options for non-priv whould
>> certainly fly in my opinion. That is what I meant with "More
>> fine-grained parsing and setting of those options has never been
>> implemented." from my first mail.
>>
>> I am not that certain about a blacklist though, but haven't thought
>> about that enough. I didn't yet get around to review other options, but
>> basically people could use private options in some proprietary settings
>> and we could break their assumptions by such a change.
>>
>> Would a white list be sufficient?
>>
> Probably not. The "kernel is the problem" community always seem to be
> looking for even the slightest API or implementation deficiency to
> justify bypassing the kernel entirely. :-(

Hmm, I see...

Can you give some more details about the planned new options? I think we
can also open the API up for all options where the fourth bit is set,
which AFAIK denotes the experimental option space. And only have a
blacklist for the fourth bit == 0 case. Otherwise this is something IETF
people probably know more about what an impact this change could have.

Bye,
Hannes

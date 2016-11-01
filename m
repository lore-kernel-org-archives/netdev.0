From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: Why do we need tasklet in IFB?
Date: Tue, 1 Nov 2016 07:38:49 -0400
Message-ID: <dc98e4d7-b076-66ca-a22f-5199b6d13ea9@mojatatu.com>
References: <20161028144803.4d3f5a2a@xeon-e3>
 <CAAmHdhwWGygKtcNR2Bazh-TMoAahEaAf6N5CPWjnvun0BfUdLA@mail.gmail.com>
 <CAAmHdhyC4DT+Ch2jAhAeCXKoUBH+_q-j96VcZFMO=oBhikN6cg@mail.gmail.com>
 <20161031.141047.1551501937019100403.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, make0818@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f180.google.com ([209.85.220.180]:35676 "EHLO
        mail-qk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1168941AbcKALj4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 07:39:56 -0400
Received: by mail-qk0-f180.google.com with SMTP id z190so194026992qkc.2
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2016 04:39:56 -0700 (PDT)
In-Reply-To: <20161031.141047.1551501937019100403.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-10-31 02:10 PM, David Miller wrote:
> From: Michael Ma <make0818@gmail.com>
> Date: Mon, 31 Oct 2016 11:02:28 -0700
>
>> 2016-10-28 14:52 GMT-07:00 Michael Ma <make0818@gmail.com>:
>>> 2016-10-28 14:48 GMT-07:00 Stephen Hemminger <stephen@networkplumber.org>:
>>>> On Fri, 28 Oct 2016 14:45:07 -0700
>>>> Michael Ma <make0818@gmail.com> wrote:
>>>>
>>>>> 2016-10-28 14:38 GMT-07:00 Stephen Hemminger <stephen@networkplumber.org>:
>>>>>> On Fri, 28 Oct 2016 14:36:27 -0700
>>>>>> Michael Ma <make0818@gmail.com> wrote:
>>>>>>
>>>>>>> Hi -
>>>>>>>
>>>>>>> Currently IFB uses tasklet to process tx/rx on the interface that
>>>>>>> forwarded the packet to IFB. My understanding on why we're doing this
>>>>>>> is that since dev_queue_xmit() can be invoked in interrupt, we want to
>>>>>>> defer the processing of original tx/rx in case ifb_xmit() is called
>>>>>>> from interrupt.
>>>>>>
>>>>>> dev_queue_xmit is only called from interrupt if doing netconsole.
>>>>>
>>
>> In fact this doesn't seem to explain since if the original path is tx
>> and the context is interrupt, IFB will call dev_queue_xmit as well so
>> the context can be interrupt in that case.
>>
>> Then tasklet is still unnecessary.
>
> Perhaps it's necessary to deal with potential recursion, that's my only
> guess at this point.
>
> Jamal, do you remember what went through your mind back in 2005? :-)
>

Certainly recursions (which were a huge issue in the original
implementations) as well as the need to have qdisc which shape traffic
(which implies they will sit on the queue for some period of time and
where accuracy of timing is important; therefore low latency of
scheduling was  needed).

I didnt follow the context of "tasklets are unnecessary":
Are tasklets bad or is the OP interested in replacing them with
something s/he thinks is better? IIRC, at some point the idea was to
infact use a softirq but it became obvious it was overkill.

cheers,
jamal

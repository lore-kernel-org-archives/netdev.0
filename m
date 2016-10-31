From: David Miller <davem@davemloft.net>
Subject: Re: Why do we need tasklet in IFB?
Date: Mon, 31 Oct 2016 14:10:47 -0400 (EDT)
Message-ID: <20161031.141047.1551501937019100403.davem@davemloft.net>
References: <20161028144803.4d3f5a2a@xeon-e3>
        <CAAmHdhwWGygKtcNR2Bazh-TMoAahEaAf6N5CPWjnvun0BfUdLA@mail.gmail.com>
        <CAAmHdhyC4DT+Ch2jAhAeCXKoUBH+_q-j96VcZFMO=oBhikN6cg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
        jhs@mojatatu.com
To: make0818@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54964 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S943348AbcJaSKw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 14:10:52 -0400
In-Reply-To: <CAAmHdhyC4DT+Ch2jAhAeCXKoUBH+_q-j96VcZFMO=oBhikN6cg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Ma <make0818@gmail.com>
Date: Mon, 31 Oct 2016 11:02:28 -0700

> 2016-10-28 14:52 GMT-07:00 Michael Ma <make0818@gmail.com>:
>> 2016-10-28 14:48 GMT-07:00 Stephen Hemminger <stephen@networkplumber.org>:
>>> On Fri, 28 Oct 2016 14:45:07 -0700
>>> Michael Ma <make0818@gmail.com> wrote:
>>>
>>>> 2016-10-28 14:38 GMT-07:00 Stephen Hemminger <stephen@networkplumber.org>:
>>>> > On Fri, 28 Oct 2016 14:36:27 -0700
>>>> > Michael Ma <make0818@gmail.com> wrote:
>>>> >
>>>> >> Hi -
>>>> >>
>>>> >> Currently IFB uses tasklet to process tx/rx on the interface that
>>>> >> forwarded the packet to IFB. My understanding on why we're doing this
>>>> >> is that since dev_queue_xmit() can be invoked in interrupt, we want to
>>>> >> defer the processing of original tx/rx in case ifb_xmit() is called
>>>> >> from interrupt.
>>>> >
>>>> > dev_queue_xmit is only called from interrupt if doing netconsole.
>>>>
> 
> In fact this doesn't seem to explain since if the original path is tx
> and the context is interrupt, IFB will call dev_queue_xmit as well so
> the context can be interrupt in that case.
> 
> Then tasklet is still unnecessary.

Perhaps it's necessary to deal with potential recursion, that's my only
guess at this point.

Jamal, do you remember what went through your mind back in 2005? :-)

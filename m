From: Michael Ma <make0818@gmail.com>
Subject: Re: Why do we need tasklet in IFB?
Date: Mon, 31 Oct 2016 11:02:28 -0700
Message-ID: <CAAmHdhyC4DT+Ch2jAhAeCXKoUBH+_q-j96VcZFMO=oBhikN6cg@mail.gmail.com>
References: <CAAmHdhz_g5_+Uqp47cPm3NQd=8=9tCecddQLVCfHbChx=Tjhcw@mail.gmail.com>
 <20161028143808.3134f296@xeon-e3> <CAAmHdhxyrAQqKczaLyX8UmozdUdApbozM71vFv-j+YLnP1m21g@mail.gmail.com>
 <20161028144803.4d3f5a2a@xeon-e3> <CAAmHdhwWGygKtcNR2Bazh-TMoAahEaAf6N5CPWjnvun0BfUdLA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Stephen Hemminger <stephen@networkplumber.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:33896 "EHLO
        mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S944322AbcJaSC3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 14:02:29 -0400
Received: by mail-oi0-f46.google.com with SMTP id 62so122010071oif.1
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 11:02:29 -0700 (PDT)
In-Reply-To: <CAAmHdhwWGygKtcNR2Bazh-TMoAahEaAf6N5CPWjnvun0BfUdLA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-10-28 14:52 GMT-07:00 Michael Ma <make0818@gmail.com>:
> 2016-10-28 14:48 GMT-07:00 Stephen Hemminger <stephen@networkplumber.org>:
>> On Fri, 28 Oct 2016 14:45:07 -0700
>> Michael Ma <make0818@gmail.com> wrote:
>>
>>> 2016-10-28 14:38 GMT-07:00 Stephen Hemminger <stephen@networkplumber.org>:
>>> > On Fri, 28 Oct 2016 14:36:27 -0700
>>> > Michael Ma <make0818@gmail.com> wrote:
>>> >
>>> >> Hi -
>>> >>
>>> >> Currently IFB uses tasklet to process tx/rx on the interface that
>>> >> forwarded the packet to IFB. My understanding on why we're doing this
>>> >> is that since dev_queue_xmit() can be invoked in interrupt, we want to
>>> >> defer the processing of original tx/rx in case ifb_xmit() is called
>>> >> from interrupt.
>>> >
>>> > dev_queue_xmit is only called from interrupt if doing netconsole.
>>>

In fact this doesn't seem to explain since if the original path is tx
and the context is interrupt, IFB will call dev_queue_xmit as well so
the context can be interrupt in that case.

Then tasklet is still unnecessary.

>>> OK - so the reason is that netif_receive_skb() can only be invoked
>>> from softirq and we have to use tasklet in IFB to guarantee this.
>>>
>>> Then if the original path is rx, tasklet is unnecessary because
>>> ifb_xmit() is invoked from netif_receive_skb() which is always in the
>>> softirq context, right?
>>
>> The other reason is to avoid deep kernel callstacks

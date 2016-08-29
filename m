From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v2 net-next] documentation: Document issues with VMs and
 XPS and drivers enabling it on their own
Date: Mon, 29 Aug 2016 10:35:50 -0700
Message-ID: <CALx6S34Qak8vbMakLCTpf5UTNsZQ0rpLWNjHMxUnF3sULFQMOw@mail.gmail.com>
References: <20160825225543.BFA562900836@tardy> <CALx6S35myS9QTA7QhnDpL8ybC2c6S8LOp47iNEGS_zxXXVf4mw@mail.gmail.com>
 <20160826.213550.1069021753459989756.davem@davemloft.net> <CALx6S356MGsEiJkuTEfPLv=KGdfqZoz6Q2AJhPqp9yx-t2g15A@mail.gmail.com>
 <32d356cc-a7c7-2349-88a5-ab4652272ba1@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Alexander Duyck <alexander.duyck@gmail.com>
To: Rick Jones <rick.jones2@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f54.google.com ([209.85.214.54]:33336 "EHLO
        mail-it0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751195AbcH2Rfv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 13:35:51 -0400
Received: by mail-it0-f54.google.com with SMTP id j128so17650340ith.0
        for <netdev@vger.kernel.org>; Mon, 29 Aug 2016 10:35:51 -0700 (PDT)
In-Reply-To: <32d356cc-a7c7-2349-88a5-ab4652272ba1@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 29, 2016 at 9:26 AM, Rick Jones <rick.jones2@hpe.com> wrote:
> On 08/27/2016 12:41 PM, Tom Herbert wrote:
>>
>> On Fri, Aug 26, 2016 at 9:35 PM, David Miller <davem@davemloft.net> wrote:
>>>
>>> From: Tom Herbert <tom@herbertland.com>
>>> Date: Thu, 25 Aug 2016 16:43:35 -0700
>>>
>>>> This seems like it will only confuse users even more. You've clearly
>>>> identified an issue, let's figure out how to fix it.
>>>
>>>
>>> I kinda feel the same way about this situation.
>>
>>
>> I'm working on XFS (as the transmit analogue to RFS). We'll track
>> flows enough so that we should know when it's safe to move them.
>
>
> Is the XFS you are working on going to subsume XPS or will the two continue
> to exist in parallel a la RPS and RFS?
>
XPS selects the queue, XFS prevents changing the queues when OOO could
occur. I am thinking that XFS is only applicable when we don't have a
socket tracking OOO. Idea is to have a flow table indexed by packet
hash that gives the current TX queue for match flows. The TX queue
comes from doing XPS. We only change the queue used by flows if that
won't result in OOO as determined by tracking the queue similar to how
we do RFS.

Tom

> rick jones
>

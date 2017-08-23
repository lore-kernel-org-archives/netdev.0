From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: XDP redirect measurements, gotchas and tracepoints
Date: Wed, 23 Aug 2017 07:51:44 -0700
Message-ID: <CAKgT0UeBHPTWmQ9SppKrrT=4Gq65gpvSnLxqiFi3DZ3-JW=f4Q@mail.gmail.com>
References: <20170821212506.1cb0d5d6@redhat.com> <CACKFLimAF9OYwz8EqG=1-N40hWuA-8C8k8ut0oFKYdduvZOxHA@mail.gmail.com>
 <599C7530.2010405@gmail.com> <1503426617.2434.5.camel@intel.com>
 <CACKFLimMWLto4FRxNE3tzrO5MU+p67J7wu=n1nmg0t8QGYjgrA@mail.gmail.com>
 <CAKgT0Uf=ZfVeK-wtvNxSyGEVZ3UseUOHiP3ZOg-SrzmqsR=LtQ@mail.gmail.com> <CACKFLinJ0N7b8Xhq4ZoHdB80uXp_MU_vVyzZa7Dq11XrXsvDbw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "Duyck, Alexander H" <alexander.h.duyck@intel.com>,
        "john.fastabend@gmail.com" <john.fastabend@gmail.com>,
        "brouer@redhat.com" <brouer@redhat.com>,
        "pstaszewski@itcare.pl" <pstaszewski@itcare.pl>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "xdp-newbies@vger.kernel.org" <xdp-newbies@vger.kernel.org>,
        "andy@greyhouse.net" <andy@greyhouse.net>,
        "borkmann@iogearbox.net" <borkmann@iogearbox.net>
To: Michael Chan <michael.chan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f179.google.com ([209.85.216.179]:35104 "EHLO
        mail-qt0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754090AbdHWOvp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 10:51:45 -0400
In-Reply-To: <CACKFLinJ0N7b8Xhq4ZoHdB80uXp_MU_vVyzZa7Dq11XrXsvDbw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 22, 2017 at 11:59 PM, Michael Chan
<michael.chan@broadcom.com> wrote:
> On Tue, Aug 22, 2017 at 6:06 PM, Alexander Duyck
> <alexander.duyck@gmail.com> wrote:
>> On Tue, Aug 22, 2017 at 1:04 PM, Michael Chan <michael.chan@broadcom.com> wrote:
>>>
>>> Right, but it's conceivable to add an API to "return" the buffer to
>>> the input device, right?
>>
>> You could, it is just added complexity. "just free the buffer" in
>> ixgbe usually just amounts to one atomic operation to decrement the
>> total page count since page recycling is already implemented in the
>> driver. You still would have to unmap the buffer regardless of if you
>> were recycling it or not so all you would save is 1.000015259 atomic
>> operations per packet. The fraction is because once every 64K uses we
>> have to bulk update the count on the page.
>>
>
> If the buffer is returned to the input device, the input device can
> keep the DMA mapping.  All it needs to do is to dma_sync it back to
> the input device when the buffer is returned.

That is what ixgbe is already doing. The Rx path doesn't free the
page, it just treats it as a bounce buffer and uses the page count to
make certain we don't use a section of the buffer that is already in
use.

- Alex

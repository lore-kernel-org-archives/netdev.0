From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: XDP redirect measurements, gotchas and tracepoints
Date: Tue, 22 Aug 2017 23:59:05 -0700
Message-ID: <CACKFLinJ0N7b8Xhq4ZoHdB80uXp_MU_vVyzZa7Dq11XrXsvDbw@mail.gmail.com>
References: <20170821212506.1cb0d5d6@redhat.com> <CACKFLimAF9OYwz8EqG=1-N40hWuA-8C8k8ut0oFKYdduvZOxHA@mail.gmail.com>
 <599C7530.2010405@gmail.com> <1503426617.2434.5.camel@intel.com>
 <CACKFLimMWLto4FRxNE3tzrO5MU+p67J7wu=n1nmg0t8QGYjgrA@mail.gmail.com> <CAKgT0Uf=ZfVeK-wtvNxSyGEVZ3UseUOHiP3ZOg-SrzmqsR=LtQ@mail.gmail.com>
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
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f175.google.com ([209.85.161.175]:34114 "EHLO
        mail-yw0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753238AbdHWG7G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 02:59:06 -0400
Received: by mail-yw0-f175.google.com with SMTP id s143so4705470ywg.1
        for <netdev@vger.kernel.org>; Tue, 22 Aug 2017 23:59:06 -0700 (PDT)
In-Reply-To: <CAKgT0Uf=ZfVeK-wtvNxSyGEVZ3UseUOHiP3ZOg-SrzmqsR=LtQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 22, 2017 at 6:06 PM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:
> On Tue, Aug 22, 2017 at 1:04 PM, Michael Chan <michael.chan@broadcom.com> wrote:
>>
>> Right, but it's conceivable to add an API to "return" the buffer to
>> the input device, right?
>
> You could, it is just added complexity. "just free the buffer" in
> ixgbe usually just amounts to one atomic operation to decrement the
> total page count since page recycling is already implemented in the
> driver. You still would have to unmap the buffer regardless of if you
> were recycling it or not so all you would save is 1.000015259 atomic
> operations per packet. The fraction is because once every 64K uses we
> have to bulk update the count on the page.
>

If the buffer is returned to the input device, the input device can
keep the DMA mapping.  All it needs to do is to dma_sync it back to
the input device when the buffer is returned.

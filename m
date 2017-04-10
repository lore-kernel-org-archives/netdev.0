From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH v2 net-next RFC] Generic XDP
Date: Mon, 10 Apr 2017 14:47:04 -0700
Message-ID: <CACKFLik+GKHPqKU7Mb4dXMLVLBKKDLVWZd7uuR=uA5yZ4_GmsQ@mail.gmail.com>
References: <20170409.133528.660876505013192371.davem@davemloft.net>
 <20170410183935.GB4730@C02RW35GFVH8.dhcp.broadcom.net> <20170410.152854.2025617543091711047.davem@davemloft.net>
 <20170410213025.GC4730@C02RW35GFVH8.dhcp.broadcom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Netdev <netdev@vger.kernel.org>, xdp-newbies@vger.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:33237 "EHLO
        mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751914AbdDJVrH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 17:47:07 -0400
Received: by mail-lf0-f47.google.com with SMTP id h125so77647813lfe.0
        for <netdev@vger.kernel.org>; Mon, 10 Apr 2017 14:47:06 -0700 (PDT)
In-Reply-To: <20170410213025.GC4730@C02RW35GFVH8.dhcp.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 10, 2017 at 2:30 PM, Andy Gospodarek <andy@greyhouse.net> wrote:
> On Mon, Apr 10, 2017 at 03:28:54PM -0400, David Miller wrote:
>> From: Andy Gospodarek <andy@greyhouse.net>
>> Date: Mon, 10 Apr 2017 14:39:35 -0400
>>
>> > As promised, I did some testing today with bnxt_en's implementation
>> > of XDP and this one.
>>
>> Thanks a lot Andy, obviously the patch needs some more work.
>>
>> I noticed GRO stuff in your profile, and Alexei mentioned this earlier
>> today.  We probably should elide GRO if generic XDP is attached, since
>> in particular this makes the skb_linearize() really expensive.
>
> Good catch -- I actually thought we were disabling GRO automatically and it
> looks like we are not.  :-/  I'll send Michael a patch.

Andy,  I think we only need to disable GRO if we are doing generic
XDP.  Optimized XDP can still use GRO for the XDP_PASS case.

>
> Disabling GRO allows me to process an additional 1Mpps, so I'm up to 7.5Mpps
> with this patch.

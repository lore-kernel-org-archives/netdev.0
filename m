From: Tom Herbert <therbert@google.com>
Subject: Re: some failures with vxlan offloads..
Date: Wed, 29 Oct 2014 07:59:59 -0700
Message-ID: <CA+mtBx9TCtHgW=TegUgjZ6Se=mP+0CNiNHYmbYHPd1cJJGYoBQ@mail.gmail.com>
References: <544CF8E3.8070207@mellanox.com>
	<CA+mtBx-Jp5Kps5WycYwN0PuyXLDtGM0s8USxdQoSLPRDVS19xw@mail.gmail.com>
	<CAJ3xEMi6UuCT+6iriX02qjS6trhEaoYh39UBL+p_i995MvZc2Q@mail.gmail.com>
	<CA+mtBx9g6MYpFv83av1YdRpZRBcBKvsqzSnhs5C7iV+kP8cWDA@mail.gmail.com>
	<544FB5CA.2060003@mellanox.com>
	<CA+mtBx_ncYrp_fbp8ucXfBaCoPpv_X+TEsmofCnpzTyPPfLXnw@mail.gmail.com>
	<54508020.1040305@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:42150 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933114AbaJ2PAA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 11:00:00 -0400
Received: by mail-ie0-f182.google.com with SMTP id rd18so3154249iec.27
        for <netdev@vger.kernel.org>; Wed, 29 Oct 2014 07:59:59 -0700 (PDT)
In-Reply-To: <54508020.1040305@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 28, 2014 at 10:50 PM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
> On 10/28/2014 5:36 PM, Tom Herbert wrote:
>>>
>>> I wonder if we have another bug somewhere... when both sides were
>>> offloaded,
>>> >it works even with the mlx4 bug, canyou explain that?is it possible that
>>> > the
>>> >GRO stack somehow covers on the bug when both sides are offloaded and
>>> >GRO/VXLAN comes into play?
>>>
>> Look at the receive side. As I mentioned, if the device is returning
>> checksum-unnecessary and setting csum_level to 1 (inner checksum was
>> validated) then stack won't try to verify the outer checksum. So in
>> this case if outer checksum is incorrect nobody complains about it.
>
>
> OK, I'll look there. Anything that should worries us at that stack trace I
> sent in my initial email of this thread, or you think this is related to the
> mlx4 driver checksum bug?
>
The trace doesn't seem like it would be related to a checksum bug. Do
you only see this with offload enabled?

> Or.
>
>>
>

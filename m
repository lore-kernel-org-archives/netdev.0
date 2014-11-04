From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next 0/7] gue: Remote checksum offload
Date: Mon, 3 Nov 2014 16:19:39 -0800
Message-ID: <CAEP_g=-rgL1D3kEQaCCmgArsVZQ0D=-JxDjoyZut3iykASYjNQ@mail.gmail.com>
References: <1414882683-25484-1-git-send-email-therbert@google.com>
 <CAEP_g=88Q155PxTm9qbNVuxevqDneH3bed0nRfw1nKnZEKvMfQ@mail.gmail.com> <CA+mtBx-t2a80VhYypH8d0pjWh7FqT8GRGZt1F=o23GC3BZm-sA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog109.obsmtp.com ([74.125.149.201]:42379 "HELO
	na3sys009aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750719AbaKDAUB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 19:20:01 -0500
Received: by mail-qc0-f173.google.com with SMTP id x3so10046242qcv.32
        for <netdev@vger.kernel.org>; Mon, 03 Nov 2014 16:20:00 -0800 (PST)
In-Reply-To: <CA+mtBx-t2a80VhYypH8d0pjWh7FqT8GRGZt1F=o23GC3BZm-sA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 3, 2014 at 2:39 PM, Tom Herbert <therbert@google.com> wrote:
> On Mon, Nov 3, 2014 at 1:26 PM, Jesse Gross <jesse@nicira.com> wrote:
>> On Sat, Nov 1, 2014 at 3:57 PM, Tom Herbert <therbert@google.com> wrote:
>>> This patch set implements remote checksum offload for
>>> GUE, which is a mechanism that provides checksum offload of
>>> encapsulated packets using rudimentary offload capabilities found in
>>> most Network Interface Card (NIC) devices. The outer header checksum
>>> for UDP is enabled in packets and, with some additional meta
>>> information in the GUE header, a receiver is able to deduce the
>>> checksum to be set for an inner encapsulated packet. Effectively this
>>> offloads the computation of the inner checksum. Enabling the outer
>>> checksum in encapsulation has the additional advantage that it covers
>>> more of the packet than the inner checksum including the encapsulation
>>> headers.
>>
>> Tom, I have a pretty hard time squaring this with your previous
>> comments on hardware offload. This looks almost identical to a
>> protocol-specific hardware offload to me in terms of the implications
>> on the stack. It actually is more invasive and less likely to scale
>> across protocols, so the relative cost/benefit doesn't really add up
>> in my mind.
>
> With this patch and checksum-unnecessary conversion we can provide
> checksum offload for encapsulation on millions of already deployed
> NICs without any HW or FW change.  Why do you think this is not a good
> cost/benefit tradeoff?

I just don't see how this is consistent with your previously stated
goal of keeping protocol-specific offload code out of the core stack.
Can you explain how this is different?

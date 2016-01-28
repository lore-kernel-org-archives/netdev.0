From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 1/8] net: local checksum offload for encapsulation
Date: Thu, 28 Jan 2016 09:09:24 -0800
Message-ID: <CALx6S37hTuTcrNVr8zKHTVa46wxkZSjbzyxPOuVjW4_4xRh-Sw@mail.gmail.com>
References: <56901197.8040808@solarflare.com>
	<569011D4.60002@solarflare.com>
	<56A9BD8E.4030209@gmail.com>
	<CAKgT0UcA5kAg64QPL=L=SYw3O=f+KDwcqgMEziCs=AYL439FYA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Zang MingJie <zealot0630@gmail.com>,
	Edward Cree <ecree@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, linux-net-drivers@solarflare.com
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:34902 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751537AbcA1RJY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 12:09:24 -0500
Received: by mail-io0-f194.google.com with SMTP id m139so3298786ioe.2
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2016 09:09:24 -0800 (PST)
In-Reply-To: <CAKgT0UcA5kAg64QPL=L=SYw3O=f+KDwcqgMEziCs=AYL439FYA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 28, 2016 at 1:00 AM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:
> On Wed, Jan 27, 2016 at 11:04 PM, Zang MingJie <zealot0630@gmail.com> wrote:
>> I have also noticed that for gso, all gso segs will have exactly same outer
>> udp checksum, this is also because inner checksum cancellation.
>>
>> Can we also optimize that outer udp checksum should be only calculated once
>> for all gso segs ?
>
> Actually that is a good point.  It isn't as if anything really changes
> in the tunnel headers between frames so we probably can just compute

This is probably true for current all implementation, but it has never
been declared as a requirement. It's conceivable that some
encapsulation layer might implement something like a sequence number
or its own CRC. The requirements should at least be documented.

Tom

> the outer once and then adjust it on the last frame to account for the
> fact that the length will be different.  I'll see if we can do that in
> the GSO patches I have been working on.
>
> - Alex

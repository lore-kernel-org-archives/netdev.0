From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Sat, 5 Dec 2015 18:13:48 -0800
Message-ID: <CAKgT0Udj2vNjqTO3HQKRoQajm-_Y6PdgQAu23Z8eQfnLRvsUiQ@mail.gmail.com>
References: <CAKgT0Uc1bJRrzpLUdr3vOFkYZbcqP=J8wgOz1feF+u04aNBg1g@mail.gmail.com>
	<20151205.130313.1952213347830357234.davem@davemloft.net>
	<CAKgT0UfQCnz+oGfETZQs-nCP_QL_5qzngB+zC-e6ZN1-kV8C0Q@mail.gmail.com>
	<20151205.172742.1214683922564543621.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <tom@herbertland.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	John Linville <linville@tuxdriver.com>,
	Jesse Gross <jesse@kernel.org>,
	Anjali Singhai Jain <anjali.singhai@intel.com>,
	Netdev <netdev@vger.kernel.org>,
	Kiran Patil <kiran.patil@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:34286 "EHLO
	mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752983AbbLFCNt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Dec 2015 21:13:49 -0500
Received: by ioir85 with SMTP id r85so151418362ioi.1
        for <netdev@vger.kernel.org>; Sat, 05 Dec 2015 18:13:49 -0800 (PST)
In-Reply-To: <20151205.172742.1214683922564543621.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 5, 2015 at 2:27 PM, David Miller <davem@davemloft.net> wrote:
> From: Alexander Duyck <alexander.duyck@gmail.com>
> Date: Sat, 5 Dec 2015 11:34:47 -0800
>
>> I'm only really interested in what options the customers has in order
>> to get this all configured.  As long as there eventually ends up being
>> some path forward I'll be good with whatever ends up happening, though
>> my preference would be to see some option available in the kernel.
>
> Fair enough.
>
> BTW, I don't entirely buy your hardware complexity argument.
>
> When we're looking at checksumming offload via 1's complement in the
> RX descriptor, that is heaps simpler than having a seperate RTL path
> for N different encapsulation technologies and/or protocols.

I fully agree with you.  Basically what I had mentioned is some of the
explanation I was given from the hardware engineers when they pushed
back on my request.

> I'd rather maintain a single 1's complement circuit than N header
> parser engines that trigger the sum at the right range.

Yes, but the thing is the port number and parsers are also needed for
other things like RSS.  You also have to take into account there are
also requirements placed on the vendors by other organizations such as
Microsoft that end up impacting the final design.  As such there are
some parts of the design we cannot convince the hardware vendors to
give up.

> There is definitely long term maintainability and stability value in
> this.

Agreed.  That is why I fully support the request to add the feature,
it is just a matter of convincing the vendors to do so.

The only spot I think you and I disagreed on was the approach.  I
don't know if the hard push back does anything but punish the users by
delaying the time needed to find a reasonable solution.  I really
think if we are going to get the hardware vendors to change their
behavior we have to create a market demand for it.  Having a bit of
marketable data showing the folly of this approach versus the 1's
compliment checksum would probably do more to encourage and/or shame
them into it than simply pushing for this based on engineering
opinion.

- Alex

From: Vegard Nossum <vegard.nossum@gmail.com>
Subject: Re: [PATCH] net: fix setsockopt() locking errors
Date: Tue, 27 Jan 2009 17:25:12 +0100
Message-ID: <19f34abd0901270825j570037b8k3629764d3a09e661@mail.gmail.com>
References: <20090124224930.GA4456@localhost.localdomain>
	 <20090126115012.GA5620@ff.dom.local>
	 <20090126.123351.201148059.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, mmokrejs@ribosome.natur.cuni.cz,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:50635 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753255AbZA0QZO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 11:25:14 -0500
Received: by fg-out-1718.google.com with SMTP id 13so193548fge.17
        for <netdev@vger.kernel.org>; Tue, 27 Jan 2009 08:25:12 -0800 (PST)
In-Reply-To: <20090126.123351.201148059.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 26, 2009 at 9:33 PM, David Miller <davem@davemloft.net> wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Mon, 26 Jan 2009 11:50:12 +0000
>
>> On 24-01-2009 23:49, Vegard Nossum wrote:
>> > +static int sock_linger(struct sock *sk, char __user *optval, int optlen)
>> ...
>> > +static int sock_set_rcvtimeo(struct sock *sk, char __user *optval, int optlen)
>> > +{
>> > +   int ret;
>> > +   long rcvtimeo;
>> > +
>> > +   ret = sock_set_timeout(&rcvtimeo, optval, optlen);
>>
>> A check for error is needed here and below.
>
> Right, you cannot continue and update the socket state if this
> sock_set_timeout() call returns an error.
>

Argh, thanks both. What a stupid mistake. What is the point in fixing
something if the fix introduces a different kind of error? :-(

I will fix the patch and also check for other places (like that
attach_filter) that need to be fixed.


Vegard

-- 
"The animistic metaphor of the bug that maliciously sneaked in while
the programmer was not looking is intellectually dishonest as it
disguises that the error is the programmer's own creation."
	-- E. W. Dijkstra, EWD1036

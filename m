From: Luiz Augusto von Dentz <luiz.dentz@gmail.com>
Subject: Re: [PATCH 0/10] af_unix: add multicast and filtering features to AF_UNIX
Date: Thu, 1 Mar 2012 14:57:51 +0200
Message-ID: <CABBYNZJdYnZwm+Y15wdt225PhX=ApZrAbxH9da4EMrejWVmA1Q@mail.gmail.com>
References: <4F4B8C66.5060206@collabora.co.uk>
	<20120227.140535.1623396420455657443.davem@davemloft.net>
	<1330426059.2139.21.camel@megeve>
	<20120228.140558.1132853996225815681.davem@davemloft.net>
	<4F4F641E.7000501@collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, rodrigo.moya@collabora.co.uk,
	javier@collabora.co.uk, eric.dumazet@gmail.com,
	lennart@poettering.net, kay.sievers@vrfy.org,
	alban.crequy@collabora.co.uk, bart.cerneels@collabora.co.uk,
	sjoerd.simons@collabora.co.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F4F641E.7000501@collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Javier,

On Thu, Mar 1, 2012 at 1:57 PM, Javier Martinez Canillas
<javier.martinez@collabora.co.uk> wrote:
> On 02/28/2012 08:05 PM, David Miller wrote:
>> From: Rodrigo Moya <rodrigo.moya@collabora.co.uk>
>> Date: Tue, 28 Feb 2012 11:47:39 +0100
>>
>>> Because of all of this, UDP/IP multicast wasn't even considered as an
>>> option. We might be wrong in some/all of those, so could you please
>>> comment on them to check if that's so?
>>
>> You guys seem to want something that isn't AF_UNIX, ordering guarentees
>> and whatnot, it really has no place in these protocols.
>>
>> You've designed a userlevel subsystem with requirements that no existing
>> socket layer can give, and you just figured you'd work that out later.
>>
>> I think you rather should have reconsidered these premises and designed
>> something that could handle reality which is AF_UNIX can't do multicast
>> and nobody guarentees those strange ordering requirements you seem to
>> have.
>
> Yes, you are right it doesn't follow AF_UNIX semantics so Unix sockets
> is not the best place to add our multicast implementation.
>
> So, now we are trying a different approach. To create a new address
> family AF_MCAST. That way we can have more control over the semantics of
> the socket interface for that family.
>
> We expect to have some patches in a few days and we will resend.

Lets say AF_MCAST is acceptable, wouldn't it make AF_UNIX obsolete?
>From what I can tell a lot, if not most, of users of AF_UNIX uses it
to implement some kind of IPC being it D-Bus, chromium or wayland and
eventually all of them run into the same problems. Actually the
article in lwn put it nice together: http://lwn.net/Articles/466304/

What about SCM_RIGHTS and other Ancillary Messages, would that be
acceptable in other socket families?

-- 
Luiz Augusto von Dentz

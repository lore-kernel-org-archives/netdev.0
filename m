From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH] TCP_FAILFAST: a new socket option to timeout/abort a
 connection quicker
Date: Tue, 24 Aug 2010 14:56:28 -0700
Message-ID: <AANLkTimw_J40zOEDmYuiF1qymLr=WsQTjSRr_0XWLboH@mail.gmail.com>
References: <1282630819-23104-1-git-send-email-hkchu@google.com>
	<1282632262.2378.1681.camel@edumazet-laptop>
	<4C737D15.5060400@nets.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, ilpo.jarvinen@helsinki.fi,
	davem@davemloft.net, netdev@vger.kernel.org
To: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:38205 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755927Ab0HXV4b convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 17:56:31 -0400
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id o7OLuUxb030550
	for <netdev@vger.kernel.org>; Tue, 24 Aug 2010 14:56:30 -0700
Received: from ywg8 (ywg8.prod.google.com [10.192.7.8])
	by wpaz33.hot.corp.google.com with ESMTP id o7OLuTcg030689
	for <netdev@vger.kernel.org>; Tue, 24 Aug 2010 14:56:29 -0700
Received: by ywg8 with SMTP id 8so3399978ywg.24
        for <netdev@vger.kernel.org>; Tue, 24 Aug 2010 14:56:29 -0700 (PDT)
In-Reply-To: <4C737D15.5060400@nets.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 24, 2010 at 1:04 AM, Arnd Hannemann
<hannemann@nets.rwth-aachen.de> wrote:
> Am 24.08.2010 08:44, schrieb Eric Dumazet:
>> Le lundi 23 ao=FBt 2010 =E0 23:20 -0700, H.K. Jerry Chu a =E9crit :
>>> From: Jerry Chu <hkchu@google.com>
>>>
>>> This is a TCP level socket option that takes an unsigned int to spe=
cify
>>> how long in ms TCP should resend a lost data packet before giving u=
p
>>> and returning ETIMEDOUT. The normal TCP retry/abort timeout limit s=
till
>>> applies. In other words this option is only meant for those applica=
tions
>>> that need to "fail faster" than the default TCP timeout. The latter
>>> may take upto 20 minutes in a normal WAN environment.
>>>
>>> The option is disabled (by default) when set to 0. Also it does not
>>> apply during the connection establishment phase.
>>>
>>> Signed-off-by: H.K. Jerry Chu <hkchu@google.com>
>>
>> TCP_FAILFAST might be misleading. It reads as a boolean option, whil=
e
>> its an option to cap the timeout, with a time unit, instead of the u=
sual
>> "number of retransmits".
>
> Why not call it TCP_USERTIMEOUT?

Sure, except that it was designed to shorten the system default user ti=
meout,
not lengthen it. (But perhaps it can be combined with TCP_UTO?)

The current default user timeout of 13-20minutes in Linux may be adequa=
te for
some apps but too long for many others. A per connection socket option =
solves
this problem.

> Later you can also send it via the TCP user timeout option... (RFC548=
2)
> Hmm... is the ms granularity really needed? Does it make sense to abo=
rt
> a connection below a second?

Yes I thought about that too, but decided it's better to allow the
flexibility of sub-
sec level timeout for possible future usage in HPC type of applications=
, rather
than to regret later.

>
>> Its also funny you dont ask for a default value, given by a sysctl
>> tunable ;)
>
> Well retries1/2 would be the tunables, no?

The was my first thought, to allow tcp_retries2 to be reduced on a per
connection basis. But I also see a need to reduce TCP_RTO_MAX in
order to allow a reasonable # of retries, given a shorter timeout.

I saw a patch submitted a couple of months ago to allow tcp_retries2 to=
 be
configured but haven't seen any forward progress on the patch. If peopl=
e
think letting apps configure tcp_retries2 and TCP_RTO_MAX directly is
a better solution I'm for it too.

Thanks,

Jerry

>
> Best regards,
> Arnd
>

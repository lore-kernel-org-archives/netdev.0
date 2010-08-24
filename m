From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH] TCP_FAILFAST: a new socket option to timeout/abort a
 connection quicker
Date: Tue, 24 Aug 2010 15:13:44 -0700
Message-ID: <AANLkTikAGKObYnczsVoKnUOewJBp2J2036yOD7TncA0F@mail.gmail.com>
References: <1282630819-23104-1-git-send-email-hkchu@google.com>
	<1282632262.2378.1681.camel@edumazet-laptop>
	<4C737D15.5060400@nets.rwth-aachen.de>
	<423116d1d215b0fb3d1c966fb8167508@localhost>
	<4C73DE32.1030802@nets.rwth-aachen.de>
	<20100824162844.GA7889@nuttenaction>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnd Hannemann <hannemann@nets.rwth-aachen.de>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	ilpo.jarvinen@helsinki.fi, davem@davemloft.net,
	netdev@vger.kernel.org
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:45041 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932166Ab0HXWNs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 18:13:48 -0400
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [172.25.149.7])
	by smtp-out.google.com with ESMTP id o7OMDkjq008895
	for <netdev@vger.kernel.org>; Tue, 24 Aug 2010 15:13:47 -0700
Received: from ywa6 (ywa6.prod.google.com [10.192.1.6])
	by hpaq7.eem.corp.google.com with ESMTP id o7OMDjrb009615
	for <netdev@vger.kernel.org>; Tue, 24 Aug 2010 15:13:45 -0700
Received: by ywa6 with SMTP id 6so2966248ywa.4
        for <netdev@vger.kernel.org>; Tue, 24 Aug 2010 15:13:45 -0700 (PDT)
In-Reply-To: <20100824162844.GA7889@nuttenaction>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 24, 2010 at 9:28 AM, Hagen Paul Pfeifer <hagen@jauu.net> wr=
ote:
> * Arnd Hannemann | 2010-08-24 16:58:58 [+0200]:
>
>>Nice, so did you come up with a name for the socket option yet?
>
> +#define =A0 =A0 =A0TCP_UTO =A0 =A0 =A0 18 =A0/* User Timeout Option =
*/
>
> The patch is an early state and details as well as testing is a littl=
e bit
> costly.
>
>>Hmm, is there really a difference? If an application specifies
>>a wanted timeout e.g. with USER_TIMEOUT, CHANGEABLE will
>>become false and the value would be announced via ADV_UTO.
>>The connection could be aborted locally after that time passed,
>>regardless of what the remote site thinks the timeout should be.
>>
>>As I understand it U_LIMIT and L_LIMIT would only be there
>>for safety to disallow nonsensical values of USER_TIMEOUT.
>>
>>Did I miss something?
>
> Maybe not, aot sure. I must take a look at the patch from Jerry. I ha=
d no time
> until now.

According to RFC5482
"Decreasing the user timeouts allows busy servers to explicitly notify
their clients that they will maintain the connection state only for a
short time without connectivity."

So it looks like the user timeout can be used in either senario (shorte=
ning
or lengthening) and in both cases is a lower bound, i.e., the connectio=
n
should abort at or shortly after the specified user timeout.

In this case does it make sense to combine the two? Will your TCP_UTO
patch be ready anytime soon?

Again an alternative is to allow configuring tcp_retries2 and TCP_RTO_M=
AX
directly. I'm open to suggestion but we'd like to get something in soon=
er.

Thanks,

Jerry

>
> Hagen
>

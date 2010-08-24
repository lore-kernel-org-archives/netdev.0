From: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
Subject: Re: [PATCH] TCP_FAILFAST: a new socket option to timeout/abort a
 connection quicker
Date: Tue, 24 Aug 2010 10:04:37 +0200
Message-ID: <4C737D15.5060400@nets.rwth-aachen.de>
References: <1282630819-23104-1-git-send-email-hkchu@google.com> <1282632262.2378.1681.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "H.K. Jerry Chu" <hkchu@google.com>, ilpo.jarvinen@helsinki.fi,
	davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-i4.nets.RWTH-Aachen.DE ([137.226.12.21]:53704 "EHLO
	MAIL-i4.nets.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752227Ab0HXINW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 04:13:22 -0400
In-Reply-To: <1282632262.2378.1681.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 24.08.2010 08:44, schrieb Eric Dumazet:
> Le lundi 23 ao=C3=BBt 2010 =C3=A0 23:20 -0700, H.K. Jerry Chu a =C3=A9=
crit :
>> From: Jerry Chu <hkchu@google.com>
>>
>> This is a TCP level socket option that takes an unsigned int to spec=
ify
>> how long in ms TCP should resend a lost data packet before giving up
>> and returning ETIMEDOUT. The normal TCP retry/abort timeout limit st=
ill
>> applies. In other words this option is only meant for those applicat=
ions
>> that need to "fail faster" than the default TCP timeout. The latter
>> may take upto 20 minutes in a normal WAN environment.
>>
>> The option is disabled (by default) when set to 0. Also it does not
>> apply during the connection establishment phase.
>>
>> Signed-off-by: H.K. Jerry Chu <hkchu@google.com>
>=20
> TCP_FAILFAST might be misleading. It reads as a boolean option, while
> its an option to cap the timeout, with a time unit, instead of the us=
ual
> "number of retransmits".

Why not call it TCP_USERTIMEOUT?
Later you can also send it via the TCP user timeout option... (RFC5482)
Hmm... is the ms granularity really needed? Does it make sense to abort
a connection below a second?

> Its also funny you dont ask for a default value, given by a sysctl
> tunable ;)

Well retries1/2 would be the tunables, no?

Best regards,
Arnd

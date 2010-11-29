From: John Haxby <john.haxby@oracle.com>
Subject: Re: inet_hash_connect: source port allocation
Date: Mon, 29 Nov 2010 18:29:40 +0000
Message-ID: <4CF3F114.2070108@oracle.com>
References: <4CF3DD02.90906@oracle.com> <1291051560.3435.1198.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NetDev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:22838 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751903Ab0K2ScA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Nov 2010 13:32:00 -0500
In-Reply-To: <1291051560.3435.1198.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29/11/10 17:26, Eric Dumazet wrote:
> Le lundi 29 novembre 2010 =C3=A0 17:04 +0000, John Haxby a =C3=A9crit=
 :
>> Hello,
>>
>> Please forgive me if this is a stupid question, but is there any
>> particular reason why the source port allocation in
>> __inet_hash_connect() shouldn't use the same random allocation that
>> inet_csk_get_port() uses?  The latter, of course, is used when bind(=
)
>> doesn't specify a source port but the implicit "bind" for a connect(=
)
>> gets its port allocated by __inet_hash_connect().
>>
>> jch
> autobind vs bind
>
> bind() gives more information, like local address (if any)
>
> autobind(), we dont know local address, it'll be chose later by routi=
ng.

Sorry,  I think I phrased my question badly.

inet_csk_get_port() starts its search for a free port with

     smallest_rover =3D rover =3D net_random() % remaining + low;

whereas __inet_hash_connect() basically misses out that call to=20
net_random() so you get a predictable port number.

Is there any good reason why that is the case?

jch



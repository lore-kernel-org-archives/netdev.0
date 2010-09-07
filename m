From: =?UTF-8?B?S3J6eXN6dG9mIE9sxJlkemtp?= <ole@ans.pl>
Subject: Re: [PATCH] inet: dont set inet_rcv_saddr in connect()
Date: Tue, 07 Sep 2010 23:52:02 +0200
Message-ID: <4C86B402.5000205@ans.pl>
References: <4C865C21.5010803@ans.pl>	 <1283877391.2313.62.camel@edumazet-laptop>	 <1283887569.2634.95.camel@edumazet-laptop>	 <20100907.125947.39192078.davem@davemloft.net> <1283895316.2634.248.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([195.187.34.71]:35664 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755136Ab0IGVwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Sep 2010 17:52:08 -0400
In-Reply-To: <1283895316.2634.248.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2010-09-07 23:35, Eric Dumazet wrote:
> Le mardi 07 septembre 2010 =C3=A0 12:59 -0700, David Miller a =C3=A9c=
rit :
>
>> Eric, please just delete the code block instead of leaving it
>> there inside of an #if 0 block.
>>
>> If there is information conveyed by the unused code, add that
>> information to the nice comment you're adding :-)
>>
>
> Indeed ;)
>
> [PATCH] inet: dont set inet_rcv_saddr in connect()
>
> The following sequence :
>
> socket(PF_INET, SOCK_DGRAM, IPPROTO_IP)
>
> connect(fd, {sa_family=3DAF_INET, sin_port=3Dhtons(xx),
> sin_addr=3Dinet_addr("1.2.3.4")}, 28)
>
> 1) Does an implicit inet_autobind()
>    (using an INADDR_ANY address, and selecting a random port).
>
> 2) Does an ip4_datagram_connect() to specify the address/port of
> remote end point.
>
> Problem is ip4_datagram_connect() also sets inet->inet_rcv_saddr (fro=
m
> INADDR_ANY to IP source address, given the current route to remote en=
d
> point). Only the first connect() on the socket does this. Following o=
nes
> dont change the (possibly wrong) source address.
>
> This breaks the secondary UDP hash, based on (ADDRESS, port), that wa=
s
> computed by inet_autobind(). If more than 10 sockets are linked in
> primary hash chain, we can drop incoming packets because searches are
> done in wrong secondary hash chain.
>
> This also potentially breaks multiple connect() to change remote
> endpoints, because old source address might be non usable for packets=
 to
> new destination.
>
> If route happens to change, then we should automatically change our
> source address too, at next sendmsg() call, and UDP code deals with t=
his
> just fine.
>
> If an application needs to specify a precise source address, it must =
use
> bind() system call. connect() man page only refers to remote address,
> not local one.
>
> Reported-by: Krzysztof Ol=C4=99dzki <ole@ans.pl>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Tested-by: Krzysztof Piotr Oledzki <ole@ans.pl>

Best regards,

			Krzysztof Ol=C4=99dzki

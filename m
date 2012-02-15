From: James Chapman <jchapman@katalix.com>
Subject: Re: [RFC] l2tp/ipv6: support for L2TPv2 over UDP over IPv6
Date: Wed, 15 Feb 2012 08:26:14 +0000
Message-ID: <4F3B6C26.4090701@katalix.com>
References: <20120214223112.GB6806@kvack.org> <1329282410.2555.31.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:60582 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757624Ab2BOI0W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Feb 2012 03:26:22 -0500
In-Reply-To: <1329282410.2555.31.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is very timely - I'm keen to see IPv6 support added for L2TPv2 and=
=20
L2TPv3, but we can work on L2TPv2 first.

On 15/02/12 05:06, Eric Dumazet wrote:
> Le mardi 14 f=E9vrier 2012 =E0 17:31 -0500, Benjamin LaHaise a =E9cri=
t :
>> Hello folks,
>>
>> Below is a patch that adds support for L2TPv2 over UDP over IPv6.  I=
t's an
>> RFC at present due to 2 outstanding issues: the first is that struct
>> pppol2tp_addr and pppol2tpv3_addr have an embedded struct sockaddr_i=
n, and
>> these changes have not implemented a replacement of those socket add=
resses.
>> Since the existing pppol2tp{,v3}_addr structures did not place the s=
ockaddr_in
>> at the end of the structure, IPv6 addresses cannot be embedded witho=
ut
>> changing the ABI.  The question becomes one of how: just add a versi=
on of the
>> pppol2tp_addr structure with a sockaddr_in6 embedded in it (easily d=
one, as
>> the different in address structures can be detected via sin_family i=
n the
>> embedded address), or replace it wholesale with a new pppol2tp_addr =
that has
>> the embedded address at the end of the structure?  That is:
>>
>> 	struct pppol2tp_addr_in6 {
>> 		int			pid;
>> 		int			fd;
>> 		struct sockaddr_in6	addr;
>> 		u16			s_tunnel, s_session;
>> 		u16			d_tunnel, d_session;
>> 	};
>>
>> or
>>
>> 	struct new_pppol2tp_addr {
>> 		int			pid;
>> 		int			fd;
>> 		u32			s_tunnel, s_session;
>> 		u32			d_tunnel, d_session;
>> 		struct sockaddr_in6	addr;
>> 	};
>>
> My personal choice would be the latter .

Certainly put the sockaddr struct at the end in the new ipv6 struct,=20
like new_pppol2tp_addr, but we need to retain the ABI. Code already=20
handles two different pppol2tp_addr structs for L2TPv2 and L2TPv3, so i=
t=20
should be possible to add two more for IPv6 compatibility and have the=20
code detect which form is used similar to that in pppol2tp_connect(). M=
y=20
preference for the struct naming is pppol2tp_addr_{in6,new}.

> The second issue still outstanding is that I still have to test the t=
ransmit
> path with IPv6 hardware checksumming.  I've tested with virtio_net an=
d
> pcnet32 with qemu, but would like to verify on real hardware.

I'll see if we have suitable hardware here. If I can find some, could=20
you share your test code?


--=20
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

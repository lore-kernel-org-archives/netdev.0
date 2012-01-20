From: Arvid Brodin <arvid.brodin@enea.com>
Subject: Re: HSR: Standard breaks alignment. Solution?
Date: Fri, 20 Jan 2012 16:30:10 +0100
Message-ID: <4F198882.6030709@enea.com>
References: <4F14AE66.7060301@enea.com>	 <1326787481.3342.2.camel@jlt3.sipsolutions.net> <1326789125.2564.54.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sestofw01.enea.se ([192.36.1.252]:8562 "HELO mx-3.enea.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753458Ab2ATPaO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2012 10:30:14 -0500
In-Reply-To: <1326789125.2564.54.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Le mardi 17 janvier 2012 =C3=A0 09:04 +0100, Johannes Berg a =C3=A9cr=
it :
>> On Tue, 2012-01-17 at 00:10 +0100, Arvid Brodin wrote:
>>> As I've written before here, I'm trying to add support for the HSR =
protocol
>>> ("High-availability Seamless Redundancy") to the linux kernel. The =
protocol is
>>> specified in IEC-62439-3, and involves adding a protocol tag after =
the ethhdr
>>> on outgoing frames, and stripping it again on reception, much like =
VLAN.
>>>
>>> This HSR tag is 6 bytes long, which breaks 32-bit header alignment =
and causes
>>> an Oops and a kernel panic in icmp_echo on the receiving side of pi=
ngs (here,
>>> exactly: http://lxr.linux.no/#linux+v2.6.37/net/ipv4/icmp.c#L838 )
>>>
>>> If I add two bytes of padding to the HSR tag everything works beaut=
ifully. But
>>> of course that breaks any pretense of standard compliance.
>>>
>>> Is there some way to fix this without having to memmove the whole f=
rame payload
>>> 2 bytes on reception?
>> I don't think there's any other choice, but you can use
>> CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS to see whether you actually n=
eed
>> to do it.
>=20
> Or test if NET_IP_ALIGN is 0, it might be more explicit.
>=20

Thanks guys!

--=20
Arvid Brodin
Enea Services Stockholm AB

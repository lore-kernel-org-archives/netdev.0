From: nisse@southpole.se (Niels =?utf-8?Q?M=C3=B6ller?=)
Subject: Re: What's the right way to use a *large* number of source addresses?
Date: Fri, 23 May 2014 14:26:52 +0200
Message-ID: <6zegzkvfxv.fsf@southpole.se>
References: <6zlhtsvnqp.fsf@southpole.se>
	<20140523101144.GH24523@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jonas Bonn <jonas@southpole.se>
To: Florian Westphal <fw@strlen.de>, Lukas Tribus <luky-37@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([37.247.8.11]:47632 "EHLO mail.southpole.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750981AbaEWM1E convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2014 08:27:04 -0400
In-Reply-To: <20140523101144.GH24523@breakpoint.cc> (Florian Westphal's
	message of "Fri, 23 May 2014 12:11:44 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46lorian Westphal <fw@strlen.de> writes:

> Niels M=C3=B6ller <nisse@southpole.se> wrote:

>> 3. Just set the desired local address with the bind call. Currently,
>>    this gives an EADDRNOTAVAIL error, so the first step would be som=
e
>>    option to allow arbitrary source addresses.
>
> See 'Making non-local sockets work' in Documentation/networking/tprox=
y.txt

Great! Sounds like it should work fine with no additional kernel hackin=
g.

Lukas Tribus <luky-37@hotmail.com> writes:

> Yes, its a simple as setting IP_FREEBIND and then binding to the spec=
ific
> source IP.
>
> setsockopt(fd, SOL_IP, IP_FREEBIND, &one, sizeof(one))

This sounds even easier, but I'm not sure it works. For my first test, =
I just tried

  sysctl net.ipv4.ip_nonlocal_bind=3D1

(which is the global equivalent of IP_FREEBIND). Then bind succeeds, bu=
t
connect fails with EINVAL,

  socket(PF_INET, SOCK_STREAM, IPPROTO_TCP) =3D 3
  bind(3, {sa_family=3DAF_INET, sin_port=3Dhtons(8000), sin_addr=3Dinet=
_addr("10.200.0.1")}, 16) =3D 0
  connect(3, {sa_family=3DAF_INET, sin_port=3Dhtons(9), sin_addr=3Dinet=
_addr("10.1.0.2")}, 16) =3D -1 EINVAL (Invalid argument)

I'll do some more experiments, using IP_TRANSPARENT, and setting up the
suggested iptables rules.

Thanks,
/Niels

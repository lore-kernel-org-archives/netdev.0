From: Colin Walters <walters@verbum.org>
Subject: Re: [RFC] ipv4: add ICMP socket kind
Date: Tue, 21 Dec 2010 15:46:15 -0500
Message-ID: <AANLkTin6_fck1SbCbX5tLvY8CPzJstqmpkJuVF-B6oC6@mail.gmail.com>
References: <20101221181800.GA8166@albatros>
	<AANLkTikS6rs-AFGmtTfuRdELJ5+y=o4g1i0Xk9KDFRiv@mail.gmail.com>
	<20101221194606.GA25359@openwall.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vasiliy Kulikov <segooon@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Pavel Kankovsky <peak@argo.troja.mff.cuni.cz>
To: Solar Designer <solar@openwall.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101221194606.GA25359@openwall.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 21, 2010 at 2:46 PM, Solar Designer <solar@openwall.com> wr=
ote:
> On Tue, Dec 21, 2010 at 01:46:41PM -0500, Colin Walters wrote:
>> On Tue, Dec 21, 2010 at 1:18 PM, Vasiliy Kulikov <segooon@gmail.com>=
 wrote:
>> > A new ping socket is created with
>> >
>> > =C2=A0socket(PF_INET, SOCK_DGRAM, IPPROTO_ICMP)
>>
>> And the default is to allow any uid to do this (modulo LSM)?
>
> We intend to have this sysctl'able and to have it restricted to a gro=
up
> by default (the sysctl would set the GID) on our Linux distro,
> Openwall GNU/*/Linux. =C2=A0However, we figured that it'd be tough fo=
r us to
> get this complication accepted into mainstream, so we opted to have t=
he
> patch posted for comment without it.

Right, a sysctl was the obvious thing to have.

>> If you really have a burning desire to get rid of setuid /bin/ping,
>> why not just do it in userspace via message passing to/from a
>> privileged process, and avoid a lot of code in the kernel?
>
> Yes, we thought of that, and we don't like this solution.

=2E..because?

>=C2=A0We similarly
> (but for different reasons) don't like using fscaps to grant CAP_NET_=
RAW
> to ping.

I am (learning now) about the fscaps drawbacks...

> We share your concern about the size of net/ipv4/ping.c introduced by
> this patch, yet this is our current proposal.

To be clear I have no personal stake in the size of net/; my concern
is more about the set of permissions granted by the default kernel
configuration.  Both from an OS developer standpoint, and also just so
I feel I can continue to explain to someone who's learning about Linux
all the interactions between the uid/gid, capabilities, SELinux, etc.
If the kernel starts adding extensions to things it historically
didn't, that gets even more complicated.

> We figured that there's little point behind such restrictions. =C2=A0=
Just how
> is an ICMP echo request any worse than a UDP packet of the same size?
> Anyone can send the latter with current kernels.

Clearly if we could go back in time and make some changes to the
default Unix security model, one of those would probably be making
allocating TCP/UDP sockets a privileged operation in some way.  But
the ship has sailed there...

> Yet, as I have mentioned, we're in fact going to restrict this to a
> group by default and to have ping SGID - just not to expose the extra
> kernel code for direct attack by a local user. =C2=A0That's in case t=
here's a
> vulnerability in the added code.

So wait...this whole patch is to remove the setuid bit, but then
you're going to go back and add setgid?  How is that really
compellingly different and better?

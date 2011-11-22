From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Subject: Re: MPLS for Linux kernel
Date: Tue, 22 Nov 2011 15:33:40 +0100
Message-ID: <4ECBB2C4.9000505@dti2.net>
References: <CAFdo_mWE8wMB6QJt_DPi9Ou9OiayzV48URDq7KhKf+q8OfP+Gw@mail.gmail.com> <4ECA67C6.2080802@dti2.net> <20111121.132914.1611617296397809001.davem@davemloft.net> <4ECAA41C.9040007@dti2.net> <CAFdo_mXzqC_v5OkC6P012gFT_OmRO_yDTA0w96VhV-Lp3Hp7Fw@mail.gmail.com> <4ECB95D7.7030702@dti2.net> <CAFdo_mXD7by23i38GZHePiHhESpcX66vamBUqHU-fQQFU1RcaA@mail.gmail.com>
Reply-To: jorge@dti2.net
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: igorm@etf.rs
Return-path: <netdev-owner@vger.kernel.org>
Received: from alcalazamora.dti2.net ([81.24.162.8]:49435 "EHLO
	alcalazamora.dti2.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754236Ab1KVOdr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 09:33:47 -0500
Received: from [172.16.16.6] ([81.24.161.20])
	(authenticated user jorge@dti2.net)
	by alcalazamora.dti2.net (alcalazamora.dti2.net [81.24.162.8])
	(MDaemon PRO v12.5.0)
	with ESMTP id md50019779756.msg
	for <netdev@vger.kernel.org>; Tue, 22 Nov 2011 15:33:45 +0100
In-Reply-To: <CAFdo_mXD7by23i38GZHePiHhESpcX66vamBUqHU-fQQFU1RcaA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

El 22/11/2011 14:55, Igor Maravi=C4=87 escribi=C3=B3:
> 2011/11/22 Jorge Boncompte [DTI2] <jorge@dti2.net>:
>>        You keep insisting in that you fixed a lot of things, but you=
 have provided a
>> git tree with just one big commit and say that have taken some of my=
 patches on
>> it, could you please provide patches on TOP of the sourceforge code =
for the
>> things that are not fixed there?
>=20
> I insist on that because I did do a lot of things. When I did send yo=
u
> patch, on TOP of your net-next code, about the most important bug
> (stack overflow that was happening when mpls nhlfe entry was built)
> that I fixed it was just ignored. Unfortunately I started  fixing MPL=
S
> code without git, and I added your patches manually.

	(Dropped Dave from the cc: list)

	But you failed to provide patches, that fix ONE thing at a time, and n=
ot a
patch with all the work that you have done, that's what you sent me for=
 the
stack overflow bug or have done now with the git tree. Providing clean,
separated patches it's YOUR work if you WANT to see them applied on the
mpls-linux tree.

>>        The kernel code that is not commented out on the mpls-linux c=
ode when you build
>> the kernel it the shim layer and it's not done on purpose. This code=
 was written
>> by James to be a generic feature of the networking layer. Now I am n=
ot sure that
>> it has any value keeping it and am for removing it.
>=20
> I didn't understand what did You want to say here.

	You have #ifdefed the MPLS code in the core networking code, that's wr=
ong,
that's not the way to go if you want to see the code merged upstream. T=
he shim
layer was thought as a core component of the kernel. If we rip it what =
we come
at with should be #ifdef-less.

>>        The other thing that probably I am going to remove is the lab=
elspace support. I
>> don't see a use for it, and even Cisco doesn't implement it either t=
hat I know.
>=20
> That's 15 min of work, but I think that labelspaces should stay.

	Yes, I dit it an hour ago on a private branch. :) Why should did it st=
ay?

>>        Then we must rework the netlink interface to make it cleaner =
and extensible.
>=20
> What do you mean by extensible? With my netlink code you can add,
> change and delete ilm, nhlfe and xc entries without any problem. What
> other could one wish for? As I could see in your code you can't chang=
e
> ilm, nhlfe and xc entries.

	Yes, I did not finish the change code because no ones uses it currentl=
y
(iproute, quagga). In my opinion the instructions should be nested attr=
ibutes,
and we have to change how the MPLS_CHANGE_* flags get passed, currently=
 it's a hack.

>=20
>>        Check the dst's usages, there has been a lot of changes in th=
e core kernel here
>> lately and I am not sure if we are using it correctly.
>=20
> As far I could see you did a great job of using nhlfe as dst entry.
> Problem was when you delete nhlfe entry that is referenced with ilm
> entry. It shouldn't be allowed to be deleted, or the ilm should chang=
e
> last instructions from fwd to peek. I did the last thing.

	If I delete an nhlfe I for sure don't want the traffic for be routed i=
nstead of
dropped. Instructions are policy set by the user and you shouldn't chan=
ge them
under the hood.

> Also there was the problem with neighbor hh_cache, because we are
> using nhlfe as dst_entry but I fixed that too.  (hh_cache wouldn't
> change when we are sending packets with diferent type (ETH_P_IP and
> ETH_P_MPLS_UC))

	patch.

> Also ilm shouldn't be dst_entry. I'm going to change that.

	I agree 100%. I did forgot it.

	Regards,
		Jorge

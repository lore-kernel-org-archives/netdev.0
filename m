From: Patrick McHardy <kaber@trash.net>
Subject: Re: tc: RTM_GETQDISC causes kernel OOPS
Date: Sat, 22 May 2010 11:51:37 +0200
Message-ID: <4BF7A929.2090007@trash.net>
References: <20100521224243.GD10247@nicira.com> <1274512687.5020.21.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Pfaff <blp@nicira.com>, Jamal Hadi Salim <hadi@cyberus.ca>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56751 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751852Ab0EVJvn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 May 2010 05:51:43 -0400
In-Reply-To: <1274512687.5020.21.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Le vendredi 21 mai 2010 =E0 15:42 -0700, Ben Pfaff a =E9crit :
>> Hi.  While working on some library code for working with qdiscs and
>> classes I came upon a kernel OOPS.  Originally I came across it with=
 a
>> 2.6.26 kernel, but I can also reproduce it with unmodified v2.6.34 f=
rom
>> kernel.org.
>>
>> At the end of this mail I'm appending both an example of the OOPS an=
d a
>> simple test program that reliably reproduces the problem for me when=
 I
>> invoke it with "lo" as argument.  The program does not need to be ru=
n as
>> root.
>>
>> After the OOPS, a lot of networking and other system functions stop
>> working, so it seems to me a serious issue.
>>
>> The null pointer dereference that causes the OOPS is the dereference=
 of
>> the return value of qdisc_dev() in tc_fill_qdisc() in
>> net/sched/sch_api.c line 1163:
>>
>>     1161	tcm->tcm__pad1 =3D 0;
>>     1162	tcm->tcm__pad2 =3D 0;
>>     1163	tcm->tcm_ifindex =3D qdisc_dev(q)->ifindex;
>>     1164	tcm->tcm_parent =3D clid;
>>     1165	tcm->tcm_handle =3D q->handle;
>>
>> I am pretty sure about that, because if I add "WARN_ON(!qdisc_dev(q)=
);"
>> just before line 1163 then that warning triggers.
>>
>> Thanks,
>=20
> Indeed, thanks for this very useful report !
>=20
> We could add a check for TCQ_F_BUILTIN flag, or just make=20
> qdisc_notify() checks consistent for both old and new qdisc
>=20
> What other people thinks ?

We already use TCQ_F_BUILTIN in tc_qdisc_dump_ignore(), so I
think it would be more consistent than checking for a handle
to use it here as well.

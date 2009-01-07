From: Li Zefan <lizf@cn.fujitsu.com>
Subject: Re: [RFC][PATCH] IP address restricting cgroup subsystem
Date: Wed, 07 Jan 2009 16:36:35 +0800
Message-ID: <49646993.6080802@cn.fujitsu.com>
References: <20090106230554.GB25228@eskarina.localdomain.pl> <49644526.8030205@cn.fujitsu.com> <20090107073831.GA23648@megiteam.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: containers@lists.osdl.org, netdev@vger.kernel.org
To: Grzegorz Nosek <root@localdomain.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:65287 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752315AbZAGIh1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2009 03:37:27 -0500
In-Reply-To: <20090107073831.GA23648@megiteam.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Grzegorz Nosek wrote:
> On =C5=9Bro, sty 07, 2009 at 02:01:10 +0800, Li Zefan wrote:
>> CC: netdev@vger.kernel.org
>>
>> I'll review the cgroup part if this patch is regarded as useful.
>>
>> Grzegorz Nosek wrote:
>>> This is a very simple cgroup subsystem to restrict IP addresses use=
d
>>> by member processes. Currently it is limited to IPv4 only but IPv6 =
(or
>>> other protocols) should be easy to implement.
>>>
>>> IP addresses are write-once (via /cgroup/.../ipaddr.ipv4 in dotted-=
quad
>> Why they should be write-once ?
>=20
> No real (technical) reason. Making it read-write would be fine with m=
e.
> I wanted to make the restriction a one-way road but I guess I can pol=
ice
> that in userspace (simply don't write anything to the file twice).
>=20

But seems the patch makes it impossible to re-allow a restricted task t=
o
be binded to INADDR_ANY.

> However, I think that the restriction should be inherited, so that if
> CG1 is bound to e.g. 10.0.0.1, CG1/CG2 must be bound to the same
> address. But what would I do then with descendant cgroups? Leave them=
 as
> is (breaking the inheritance)? Find them all and change their bound
> address behind their back (do we have an API for that?)?
>=20

=46irstly, is inheritance necessary ?

If yes, then how about:

The root cgroup is read-only, so the tasks in it always bind to INADDR_=
ANY.
=46or other cgroups, write is allowed only if it has no children and th=
e
parent is INADDR_ANY.

> I guess I have the same problem right now, anyway (only once instead =
of
> multiple times), so I'd really appreciate your input on this.
>=20
> Best regards,
>  Grzegorz Nosek
>=20
>=20



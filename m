From: Krzysztof Oledzki <ole@ans.pl>
Subject: Re: Warning when unloading the nf_conntack module (regression?)
Date: Mon, 4 Aug 2008 20:40:56 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0808042039400.4338@bizon.gios.gov.pl>
References: <20080803143730.7747e9a8@infradead.org>
 <Pine.LNX.4.64.0808032344510.16818@bizon.gios.gov.pl>
 <Pine.LNX.4.64.0808042027080.4338@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-1991130210-1217875256=:4338"
Cc: netdev@vger.kernel.org, kaber@trash.net
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:53776 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759322AbYHDSlP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2008 14:41:15 -0400
In-Reply-To: <Pine.LNX.4.64.0808042027080.4338@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-1991130210-1217875256=:4338
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Mon, 4 Aug 2008, Krzysztof Oledzki wrote:

>
>
> On Sun, 3 Aug 2008, Krzysztof Oledzki wrote:
>
>>=20
>>=20
>> On Sun, 3 Aug 2008, Arjan van de Ven wrote:
>>=20
>>> The warning below started showing up on kerneloops.org in the top 20 an=
d=20
>>> it appears to
>>> be new in 2.6.27-rc (e.g. a regression)...
>>>=20
>>> It happens when nf_conntrack is rmmod'd
>>>=20
>>>=20
>>> The reports:
>>> http://www.kerneloops.org/search.php?search=3Dnf_conntrack_acct_fini
>>>=20
>>> The warning:
>>>=20
>>> WARNING: at kernel/sysctl.c:1966 unregister_sysctl_table+0xcc/0x103()
>>>=20
>>> Modules : nf_conntrack(-)
>>>=20
>>> Call Trace:
>>> [<ffffffff81043bc8>] warn_on_slowpath+0x65/0x98
>>> [<ffffffff8104abdf>] unregister_sysctl_table+0xcc/0x103
>>> [<ffffffffa0306655>] nf_conntrack_acct_fini+0x15/0x23 [nf_conntrack]
>>> [<ffffffffa03018a1>] nf_conntrack_cleanup+0x84/0x86 [nf_conntrack]
>>> [<ffffffffa0306944>] nf_conntrack_standalone_fini+0x40/0x42 [nf_conntra=
ck]
>>> [<ffffffff810700d0>] sys_delete_module+0x202/0x263
>>> [<ffffffff8101034a>] system_call_fastpath+0x16/0x1b
>>=20
>> Thanks. It seems I'm the person who introduced it. I'll look at it ASAP.
>
> Probably spoken too fast. This problem was introduced in 2.6.26-git15, ab=
out=20
> one week after my accounting rework had been included. Obviously there is=
=20
> something wrong with netfilter sysctl handling as starting with this kern=
el=20
> version sysctl reports duplicated net.netfilter:
>
> # find /proc/sys/net/|grep net/netf
> /proc/sys/net/netfilter
> /proc/sys/net/netfilter/nf_conntrack_generic_timeout
> /proc/sys/net/netfilter/nf_conntrack_acct
> /proc/sys/net/netfilter
> /proc/sys/net/netfilter/nf_conntrack_generic_timeout
> /proc/sys/net/netfilter/nf_conntrack_acct
>
> # sysctl -a|grep net.netfilter
> net.netfilter.nf_conntrack_generic_timeout =3D 600
> net.netfilter.nf_conntrack_acct =3D 1
> net.netfilter.nf_conntrack_generic_timeout =3D 600
> net.netfilter.nf_conntrack_acct =3D 1
>
> Still investigating.

BTW: It also happens when I revert my patch:

sysctl -a|grep net.netfilter

net.netfilter.nf_conntrack_generic_timeout =3D 600
net.netfilter.nf_conntrack_generic_timeout =3D 600

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-1991130210-1217875256=:4338--

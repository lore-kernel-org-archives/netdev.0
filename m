From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bug #13838] kernel BUG at include/net/netns/generic.h:41!
Date: Tue, 28 Jul 2009 14:46:54 +0200
Message-ID: <4A6EF33E.6080408@gmail.com>
References: <Jya1GruKQpD.A.16.2GObKB@chimera>	 <3zAHs5O6maO.A.B5B.IHObKB@chimera>	 <2375c9f90907262229t2def934emb9340c31d3efdc21@mail.gmail.com> <68676e00907280130tbbf5672x83182641b0c977b3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?QW3DqXJpY28gV2FuZw==?= <xiyou.wangcong@gmail.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	Alexey Dobriyan <adobriyan@gmail.com>
To: Luca Tettamanti <kronos.it@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:57531 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753913AbZG1MrN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 08:47:13 -0400
In-Reply-To: <68676e00907280130tbbf5672x83182641b0c977b3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Luca Tettamanti a =C3=A9crit :
> On Mon, Jul 27, 2009 at 7:29 AM, Am=C3=A9rico Wang<xiyou.wangcong@gma=
il.com> wrote:
>> On Mon, Jul 27, 2009 at 4:28 AM, Rafael J. Wysocki<rjw@sisk.pl> wrot=
e:
>>> This message has been generated automatically as a part of a report
>>> of recent regressions.
>>>
>>> The following bug entry is on the current list of known regressions
>>> from 2.6.30.  Please verify if it still should be listed and let me=
 know
>>> (either way).
>>>
>>>
>>> Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=3D1383=
8
>>> Subject         : kernel BUG at include/net/netns/generic.h:41!
>>> Submitter       : Luca Tettamanti <kronos.it@gmail.com>
>>> Date            : 2009-07-20 15:27 (7 days old)
>>> References      : http://lkml.org/lkml/2009/7/20/105
>> Hmm, it looks like that 'pfkey_net_id' is still zero after ipsec_pfk=
ey_init()...
>>
>> Add Herbert and net-dev into Cc.
>>
>> Luca, would you mind to provide your .config and the steps to reprod=
uce this?
>=20
> I cannot reproduce it anymore with the current git kernel. The BUG wa=
s
> triggered by racoon at startup.
> Should I go back to an older kernel to investigate or can we consider
> it "fixed"?
>=20

This should be fixed by following patch (submitted for bug 13760, but s=
hould apply)

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index b7292a2..1972830 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -488,7 +488,7 @@ int net_assign_generic(struct net *net, int id, voi=
d *data)
 	 */
=20
 	ng->len =3D id;
-	memcpy(&ng->ptr, &old_ng->ptr, old_ng->len);
+	memcpy(&ng->ptr, &old_ng->ptr, old_ng->len * sizeof(void *));
=20
 	rcu_assign_pointer(net->gen, ng);
 	call_rcu(&old_ng->rcu, net_generic_release);

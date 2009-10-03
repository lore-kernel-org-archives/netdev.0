From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bug #14301] WARNING: at net/ipv4/af_inet.c:154
Date: Sat, 03 Oct 2009 19:53:00 +0200
Message-ID: <4AC78F7C.40908@gmail.com>
References: <3onW63eFtRF.A.xXH.oMTxKB@chimera> <COE24pZSBH.A.mdH.sMTxKB@chimera> <4AC70D20.4060009@gmail.com> <4AC710DF.5070705@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>,
	Ralf Hildebrandt <Ralf.Hildebrandt@charite.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	"David S. Miller" <davem@davemloft.net>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:37283 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752428AbZJCRyG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Oct 2009 13:54:06 -0400
In-Reply-To: <4AC710DF.5070705@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =C3=A9crit :
> Eric Dumazet a =C3=A9crit :
>> Rafael J. Wysocki a =C3=A9crit :
>>> This message has been generated automatically as a part of a report
>>> of regressions introduced between 2.6.30 and 2.6.31.
>>>
>>> The following bug entry is on the current list of known regressions
>>> introduced between 2.6.30 and 2.6.31.  Please verify if it still sh=
ould
>>> be listed and let me know (either way).
>>>
>>>
>>> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14301
>>> Subject		: WARNING: at net/ipv4/af_inet.c:154
>>> Submitter	: Ralf Hildebrandt <Ralf.Hildebrandt@charite.de>
>>> Date		: 2009-09-30 12:24 (2 days old)
>>> References	: http://marc.info/?l=3Dlinux-kernel&m=3D125431350218137=
&w=3D4
>>>
>>>
>> If commit d99927f4d93f36553699573b279e0ff98ad7dea6
>> (net: Fix sock_wfree() race) doesnt fix this problem, then
>> maybe we should take a look at an old patch.
>>
>> < data mining... running... output results to lkml/netdev >
>>
>> Random guesses
>>
>>  1) : commit d55d87fdff8252d0e2f7c28c2d443aee17e9d70f
>> (net: Move rx skb_orphan call to where needed)
>>
>> A similar problem on SCTP was fixed by commit=20
>> 1bc4ee4088c9a502db0e9c87f675e61e57fa1734
>> (sctp: fix warning at inet_sock_destruct() while release sctp socket=
)
>>
>> 2) CORK and UDP sockets
>>   It seems we can leave an UDP socket with a frame in sk_write_queue
>>   Purge of this queue is done by udp_flush_pending_frames()
>>    This calls ip_flush_pending_frames()
>>    But this function only calls kfree_skb(), not sk_wmem_free_skb().=
=2E.
>>
>>
>> Could you try following patch ?
>>
>=20
> Hmm, I missed the ip_cork_release(), here is an updated version.
>=20

Please ignore this patch, I was wrong, sk_forward_alloc is not used
on xmit side for udp, only receive side. CORK/UDP should be fine

Investigation still needed...



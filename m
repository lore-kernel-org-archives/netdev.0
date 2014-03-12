From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RCU PATCH 06/14] net: sched: fw use RCU
Date: Wed, 12 Mar 2014 10:01:13 -0700
Message-ID: <1394643673.21721.48.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140310170008.3011.73599.stgit@nitbit.x32>
	  <20140310170546.3011.82918.stgit@nitbit.x32>
	 <1394473279.3607.46.camel@edumazet-glaptop2.roam.corp.google.com>
	 <53208E3F.5090401@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xiyou.wangcong@gmail.com, jhs@mojatatu.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:58441 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751276AbaCLRBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 13:01:16 -0400
Received: by mail-pd0-f181.google.com with SMTP id p10so1311175pdj.26
        for <netdev@vger.kernel.org>; Wed, 12 Mar 2014 10:01:15 -0700 (PDT)
In-Reply-To: <53208E3F.5090401@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-03-12 at 09:41 -0700, John Fastabend wrote:

> Rearranging the rcu_head placement above results in this error:
>=20
> net/sched/cls_fw.c: In function =E2=80=98fw_destroy=E2=80=99:
> net/sched/cls_fw.c:169:279: error: call to =E2=80=98__compiletime_ass=
ert_169=E2=80=99=20
> declared with attribute error: BUILD_BUG_ON failed:=20
> !__is_kfree_rcu_offset(__builtin_offsetof(typeof(*(head)),rcu))
>=20
>=20
> However it seems best to have the rcu_head at the end of the struct
> so I'll just convert the kfree_rcu() to call_rcu().


I missed HTSIZE was so big.

Its unfortunate because it makes struct fw_head slightly larger than on=
e
page.

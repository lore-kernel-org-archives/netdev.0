From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: [PATCH -next v2] unix stream: Fix use-after-free crashes
Date: Thu, 08 Sep 2011 09:56:01 +0200
Message-ID: <4E687511.3040107@gmail.com>
References: <4E631032.6050606@intel.com>  <1315326326.2576.2980.camel@schen9-DESK>  <1315330805.2899.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <1315335019.2576.3048.camel@schen9-DESK>  <1315335660.3400.7.camel@edumazet-laptop>  <1315337580.2576.3066.camel@schen9-DESK>  <1315338186.3400.20.camel@edumazet-laptop>  <1315339157.2576.3079.camel@schen9-DESK>  <1315340388.3400.28.camel@edumazet-laptop>  <CAAM7YAn0c0SpAD42PcT+-HDXjT9HMajhmfZD6D68_0E21i2tSQ@mail.gmail.com>  <1315372100.3400.76.camel@edumazet-laptop> <4E66FF38.9000107@intel.com>  <1315381503.3400.85.camel@edumazet-laptop>  <1315396903.2364.23.camel@schen9-mobl>  <CA+icZUVqJVn4ONuSDV5YdgpEcmetVMM9X=Sxt2EqM8qdegMnjQ@mail.gmail.com>  <CA+icZUW5Biu8cMhaJcz=MwtMOVn-NFD92PTpT0-DfEDKrRmaUQ@mail.gmail.com>  <1315406256.6287.7.camel@sche
 n9-mobl>  <4E680BF1.8000901@intel.com>  <1315429583.2361.3.camel@schen9-mobl>  <1315461572.2532.7.camel@edumazet-laptop>  <4E685F19.6030407@intel.com> <1315465919.2532.19.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Yan, Zheng" <zheng.z.yan@intel.com>,
	Tim Chen <tim.c.chen@linux.intel.com>,
	"sedat.dilek@gmail.com" <sedat.dilek@gmail.com>,
	"Yan, Zheng" <yanzheng@21cn.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
	"Shi, Alex" <alex.shi@intel.com>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:57799 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932243Ab1IHH4H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2011 03:56:07 -0400
Received: by fxh19 with SMTP id 19so1231076fxh.19
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2011 00:56:05 -0700 (PDT)
In-Reply-To: <1315465919.2532.19.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/08/2011 09:11 AM, Eric Dumazet wrote:
> Le jeudi 08 septembre 2011 =C3=A0 14:22 +0800, Yan, Zheng a =C3=A9cri=
t :
>=20
>> I don't think so. unix_scm_to_skb() calls unix_attach_fds(), it
>> always duplicates scm->fp.=20
>=20
> What a mess. This code is a nightmare.
>=20
> Part of the mess comes from scm_destroy() and scm_release() duplicati=
on.
>=20
> We should have scm_destroy() only, as before, and NULLify scm->pid/cr=
ed
> in unix_scm_to_skb() when we steal references.

This patch works for me. I haven't tried the out_err fixup from the
followup, but I assume I won't spot a difference as those are fail path=
s
anyway...

thanks,
--=20
js

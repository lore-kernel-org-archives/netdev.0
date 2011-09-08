From: Sedat Dilek <sedat.dilek@googlemail.com>
Subject: Re: [PATCH -next v2] unix stream: Fix use-after-free crashes
Date: Thu, 8 Sep 2011 10:43:53 +0200
Message-ID: <CA+icZUVKr7YaqPhoHeaDJwfqJEE_bhwum7vti2Qk3wxtQ1JXUQ@mail.gmail.com>
References: <4E631032.6050606@intel.com>
	<1315326326.2576.2980.camel@schen9-DESK>
	<1315330805.2899.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1315335019.2576.3048.camel@schen9-DESK>
	<1315335660.3400.7.camel@edumazet-laptop>
	<1315337580.2576.3066.camel@schen9-DESK>
	<1315338186.3400.20.camel@edumazet-laptop>
	<1315339157.2576.3079.camel@schen9-DESK>
	<1315340388.3400.28.camel@edumazet-laptop>
	<CAAM7YAn0c0SpAD42PcT+-HDXjT9HMajhmfZD6D68_0E21i2tSQ@mail.gmail.com>
	<1315372100.3400.76.camel@edumazet-laptop>
	<4E66FF38.9000107@intel.com>
	<1315381503.3400.85.camel@edumazet-laptop>
	<1315396903.2364.23.camel@schen9-mobl>
	<CA+icZUVqJVn4ONuSDV5YdgpEcmetVMM9X=Sxt2EqM8qdegMnjQ@mail.gmail.com>
	<CA+icZUW5Biu8cMhaJcz=MwtMOVn-NFD92PTpT0-DfEDKrRmaUQ@mail.gmail.com>
	<1315406256.6287.7.camel@schen9-mobl>
	<4E680BF1.8000901@intel.com>
	<1315429583.2361.3.camel@schen9-mobl>
	<1315461572.2532.7.camel@edumazet-laptop>
	<4E685F19.6030407@intel.com>
	<1315465919.2532.19.camel@edumazet-laptop>
	<4E687511.3040107@gmail.com>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"Yan, Zheng" <zheng.z.yan@intel.com>,
	Tim Chen <tim.c.chen@linux.intel.com>,
	"Yan, Zheng" <yanzheng@21cn.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
	"Shi, Alex" <alex.shi@intel.com>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
To: Jiri Slaby <jirislaby@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:55120 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932368Ab1IHIny convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2011 04:43:54 -0400
Received: by qyk7 with SMTP id 7so191384qyk.19
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2011 01:43:54 -0700 (PDT)
In-Reply-To: <4E687511.3040107@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 8, 2011 at 9:56 AM, Jiri Slaby <jirislaby@gmail.com> wrote:
> On 09/08/2011 09:11 AM, Eric Dumazet wrote:
>> Le jeudi 08 septembre 2011 =C3=A0 14:22 +0800, Yan, Zheng a =C3=A9cr=
it :
>>
>>> I don't think so. unix_scm_to_skb() calls unix_attach_fds(), it
>>> always duplicates scm->fp.
>>
>> What a mess. This code is a nightmare.
>>
>> Part of the mess comes from scm_destroy() and scm_release() duplicat=
ion.
>>
>> We should have scm_destroy() only, as before, and NULLify scm->pid/c=
red
>> in unix_scm_to_skb() when we steal references.
>
> This patch works for me. I haven't tried the out_err fixup from the
> followup, but I assume I won't spot a difference as those are fail pa=
ths
> anyway...
>
> thanks,
> --
> js
>

I have tested the same patch here (before shopping, but can test the
"final" patch, too.).

- Sedat -

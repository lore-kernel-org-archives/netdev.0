From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] sch_htb.c consume the classes's tokens bellow the
	HTB_CAN_SEND level
Date: Thu, 5 Nov 2009 13:44:25 +0800
Message-ID: <412e6f7f0911042144u1e5a4797kcb42b8d02b618086@mail.gmail.com>
References: <4AEF9862.8040404@gmail.com>
	 <412e6f7f0911031753m4af1467fn1b0326bdf17fe48b@mail.gmail.com>
	 <20091104082808.GA6224@ff.dom.local>
	 <412e6f7f0911040116q6b25b705k83e5a45464698af1@mail.gmail.com>
	 <20091104104245.GB6224@ff.dom.local> <4AF15E73.30806@cdi.cz>
	 <412e6f7f0911040330uc5ebbcekfef57854fce501f@mail.gmail.com>
	 <4AF16C49.409@cdi.cz>
	 <412e6f7f0911040408w5adcdde8yc1add4a561e90e40@mail.gmail.com>
	 <4AF17066.1050504@cdi.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Jamal Hadi Salim <hadi@cyberus.ca>, netdev@vger.kernel.org
To: Martin Devera <martin.devera@cdi.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:54181 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750787AbZKEFoU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2009 00:44:20 -0500
Received: by pwj9 with SMTP id 9so3671596pwj.21
        for <netdev@vger.kernel.org>; Wed, 04 Nov 2009 21:44:25 -0800 (PST)
In-Reply-To: <4AF17066.1050504@cdi.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 4, 2009 at 8:15 PM, Martin Devera <martin.devera@cdi.cz> wr=
ote:
> Changli Gao wrote:
>
> Ok, then the reason is in "logic". When you have parent P and childre=
n
> A,B each with half of rate and only A is sending, than we want A to u=
se
> its own rate and also B's rate. B's rate is available as excess in P.
> Here I see correct to charge part to A and part to P, while you want
> to charge one P and twice A. Only mbuffer will limit the duplicity.
> And it is not good idea because tokens can go very negative and then
> ittroduce A's stall for some time.
> I see no principial benefit...
>

I get it. After reviewing the code, I find mbuffer is 1 minute. It
means that bandwidth will be unfair between A and B(A/B =3D 1/3) for at
least 2 minute long. It is unacceptable. I'm wrong, and need to think
it again!

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)

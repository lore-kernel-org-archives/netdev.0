From: Junchang Wang <junchangwang@gmail.com>
Subject: Re: Question about way that NICs deliver packets to the kernel
Date: Sun, 25 Jul 2010 22:18:40 +0800
Message-ID: <AANLkTi=gpPK7WEOwHV0YyAUsSLbMvhEgzw2UkuPJjNQH@mail.gmail.com>
References: <20100715142418.GA26491@host-a-229.ustcsz.edu.cn>
	<1279204417.2118.12.camel@achroite.uk.solarflarecom.com>
	<AANLkTild5SQvt7Uw7AAV7BrrSdvPdoglgbm1uJQnigdM@mail.gmail.com>
	<4C409DD6.7060903@hp.com>
	<20100720011522.GA4123@host-a-160.ustcsz.edu.cn>
	<4C45D9FA.5090108@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>, romieu@fr.zoreil.com
To: Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:36468 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751392Ab0GYOSl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jul 2010 10:18:41 -0400
Received: by iwn7 with SMTP id 7so1939148iwn.19
        for <netdev@vger.kernel.org>; Sun, 25 Jul 2010 07:18:40 -0700 (PDT)
In-Reply-To: <4C45D9FA.5090108@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi list,

> Clearly something is out of joint - let's go off-list (or on to
> netperf-talk@netperf.org) and hash that out to see what may be happen=
ing.
> =C2=A0It will probably involve variations on grabbing the top-of-trun=
k, adding
> the debug option etc.
>
The discrepancy between netperf and top has been worked out.

It seems top produce buggy data when I try to send output to a file.
=46or example, "top -b > output" gives out my previous buggy data in it=
s
first iteration.

Actually, the report of top should be:

top - 21:37:15 up 21 min,  6 users,  load average: 0.43, 0.28, 0.19
Tasks: 152 total,   2 running, 149 sleeping,   0 stopped,   1 zombie
Cpu(s):  0.2%us,  5.4%sy,  0.0%ni, 50.9%id,  0.0%wa,  0.0%hi, 43.5%si, =
 0.0%
Mem:   2074064k total,   690192k used,  1383872k free,    39372k buffer=
s
Swap:  2096476k total,        0k used,  2096476k free,   435056k cached

 PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
 3916 root      20   0  2228  584  296 R 86.3  0.0   0:09.72 netserver

I think 50.9% system idle makes sense because this is a dual-core syste=
m
and netserver is consuming 86.3% of a core. On average, the CPU usage
of the whole system reported by top can be regarded as from 46.2% to
50.1%.

netperf's report of 48% is right and testifies that "there is no huge
discrepancy
between the overall CPU utilization reported by top and the CPU utiliza=
tion
reported by netperf."

Thanks Rick.

--=20
--Junchang

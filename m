From: zhou rui <zhourui.cn@gmail.com>
Subject: Re: RPS will assign different smp_processor_id for the same packet?
Date: Fri, 22 Apr 2011 00:29:45 +0800
Message-ID: <BANLkTi=gTNwKX1Tb3mqgWJekRf7n_MHpJQ@mail.gmail.com>
References: <BANLkTimvuGKYuiV_ngTo4wtqhNix4iMfmA@mail.gmail.com>
	<1303402094.3685.54.camel@edumazet-laptop>
	<1303403112.3685.61.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:48959 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754856Ab1DUQ3q convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2011 12:29:46 -0400
Received: by iwn34 with SMTP id 34so1520587iwn.19
        for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 09:29:46 -0700 (PDT)
In-Reply-To: <1303403112.3685.61.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday, April 22, 2011, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Le jeudi 21 avril 2011 =E0 18:08 +0200, Eric Dumazet a =E9crit :
>> Le jeudi 21 avril 2011 =E0 23:50 +0800, zhou rui a =E9crit :
>> > kernel 2.6.36.4
>> > CONFIG_RPS=3Dy but not set the cpu mask
>> >
>> > /sys/class/net/eth1/queues/rx-0 # cat rps_cpus
>> > 00
>> >
>> > register a hook func:
>> > =A0 prot_hook.func =3D packet_rcv;
>> > =A0 prot_hook.type =3D htons(ETH_P_ALL);
>> > =A0 dev_add_pack(&prot_hook);
>> >
>> >
>> > replay the same traffic in very slow speed, printk the
>> > smp_processor_id in packet_rcv():
>> > first time:
>> > cpu=3D4
>> > cpu=3D3
>> > cpu=3D6
>> > cpu=3D7
>> >
>> > second time:
>> > cpu=3D7
>> > cpu=3D1
>> > cpu=3D5
>> > cpu=3D2
>> >
>> > is it normal?
>>
>> Yes it is.
>>
>> What would you expect ?
>>
>
> If rps_cpus contains only '0' bits, it basically means RPS is not act=
ive
> for this input queue.
>
> CPU is therefore not changed : The cpu handling NAPI on your network
> device directly calls upper linux stack.
>
> Seeing your traces, it also means your device spreads its interrupts =
on
> many different cpus, this might be not optimal.
>
> Check /proc/irq/{irq_number}/smp_affinity, it probably contains "ff"
>
>
>
>
Thanks,just saw this email

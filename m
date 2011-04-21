From: zhou rui <zhourui.cn@gmail.com>
Subject: Re: RPS will assign different smp_processor_id for the same packet?
Date: Fri, 22 Apr 2011 00:27:30 +0800
Message-ID: <BANLkTikzCOYSPSVe4+vZaLmkYFWep0tWYw@mail.gmail.com>
References: <BANLkTimvuGKYuiV_ngTo4wtqhNix4iMfmA@mail.gmail.com>
	<1303402094.3685.54.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:39956 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754542Ab1DUQ1b convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2011 12:27:31 -0400
Received: by iyb14 with SMTP id 14so1523234iyb.19
        for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 09:27:30 -0700 (PDT)
In-Reply-To: <1303402094.3685.54.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday, April 22, 2011, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Le jeudi 21 avril 2011 =E0 23:50 +0800, zhou rui a =E9crit :
>> kernel 2.6.36.4
>> CONFIG_RPS=3Dy but not set the cpu mask
>>
>> /sys/class/net/eth1/queues/rx-0 # cat rps_cpus
>> 00
>>
>> register a hook func:
>> =A0 prot_hook.func =3D packet_rcv;
>> =A0 prot_hook.type =3D htons(ETH_P_ALL);
>> =A0 dev_add_pack(&prot_hook);
>>
>>
>> replay the same traffic in very slow speed, printk the
>> smp_processor_id in packet_rcv():
>> first time:
>> cpu=3D4
>> cpu=3D3
>> cpu=3D6
>> cpu=3D7
>>
>> second time:
>> cpu=3D7
>> cpu=3D1
>> cpu=3D5
>> cpu=3D2
>>
>> is it normal?
>
> Yes it is.
>
> What would you expect ?
>
>
>
I want a same CPU for same packet,
If I echo ff >rps_cpu,will I get it?
And the design idea for different CPU in rps?
I understand nic will assign same rxq for packet has same hash

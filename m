From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] ifb: add multi-queue support
Date: Sat, 14 Nov 2009 07:28:42 +0800
Message-ID: <412e6f7f0911131528i3105648y49213143e12f2522@mail.gmail.com>
References: <412e6f7f0911122216u6880e855g6a15dac29ad6a100@mail.gmail.com>
	 <20091113074508.GA6605@ff.dom.local>
	 <412e6f7f0911130054i7a508a6ah16368f11bdc7353d@mail.gmail.com>
	 <20091113091825.GA7449@ff.dom.local>
	 <412e6f7f0911130138td181935w36cab3119972753e@mail.gmail.com>
	 <20091113081553.0568296c@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f180.google.com ([209.85.216.180]:47413 "EHLO
	mail-px0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932614AbZKMX2i convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 18:28:38 -0500
Received: by pxi10 with SMTP id 10so2776378pxi.33
        for <netdev@vger.kernel.org>; Fri, 13 Nov 2009 15:28:42 -0800 (PST)
In-Reply-To: <20091113081553.0568296c@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 14, 2009 at 12:15 AM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> On Fri, 13 Nov 2009 17:38:56 +0800
> Changli Gao <xiaosuo@gmail.com> wrote:
>>
>> Oh, :) . I know more than one companies use kernel threads to forwar=
d
>> packets, and there isn't explicit extra overhead at all. And as you
>> know, as throughput increases, NAPI will bind the NIC to a CPU, and
>> softirqd will be waked up to do the work, which should be done in
>> SoftIRQ context. At that time, there isn't any difference between my
>> approach and the current kernel's.
>>
> Why not make IFB a NAPI device. This would get rid of the extra soft-=
irq
> round trip from going through netif_rx(). =C2=A0It would also behave =
like
> regular multi-queue recieive device, and eliminate need for seperate
> tasklets or threads.
>

It needs to send remote SoftIRQ, as Receiving Packet Steering, and we
must support a extra interface to map load to CPUs.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)

From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [RFC] sched: CHOKe packet scheduler (v0.2)
Date: Fri, 7 Jan 2011 13:39:26 +0800
Message-ID: <AANLkTi=C6c2md1_MB6dqvVHx2OL0Vj5Lgosi2C=kK9YG@mail.gmail.com>
References: <20110104162930.6fa672e3@nehalam> <1294208375.3420.46.camel@edumazet-laptop>
 <20110105091718.02f8a00f@nehalam> <1294248332.10633.25.camel@edumazet-laptop>
 <20110105112104.64ad3c86@nehalam> <1294286850.2723.65.camel@edumazet-laptop> <20110106205549.0de56de1@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:47008 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751988Ab1AGFjs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jan 2011 00:39:48 -0500
Received: by fxm20 with SMTP id 20so16676837fxm.19
        for <netdev@vger.kernel.org>; Thu, 06 Jan 2011 21:39:47 -0800 (PST)
In-Reply-To: <20110106205549.0de56de1@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 7, 2011 at 12:55 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> On Thu, 06 Jan 2011 05:07:30 +0100
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
>> Le mercredi 05 janvier 2011 =E0 11:21 -0800, Stephen Hemminger a =E9=
crit :
>> > This implements the CHOKe packet scheduler based on the existing
>> > Linux RED scheduler based on the algorithm described in the paper.
>> >
>> > The core idea is:
>> > =A0 For every packet arrival:
>> > =A0 =A0 Calculate Qave
>> > =A0 =A0 if (Qave < minth)
>> > =A0 =A0 =A0 =A0 =A0Queue the new packet
>> > =A0 =A0 else
>> > =A0 =A0 =A0 =A0 =A0Select randomly a packet from the queue
>> > =A0 =A0 =A0 =A0 =A0if (both packets from same flow)
>> > =A0 =A0 =A0 =A0 =A0then Drop both the packets
>> > =A0 =A0 =A0 =A0 =A0else if (Qave > maxth)
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 Drop packet
>> > =A0 =A0 =A0 =A0 =A0else
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 Admit packet with probability p (same =
as RED)
>> >
>> > See also:
>> > =A0 Rong Pan, Balaji Prabhakar, Konstantinos Psounis, "CHOKe: a st=
ateless active
>> > =A0 =A0queue management scheme for approximating fair bandwidth al=
location",
>> > =A0 Proceeding of INFOCOM'2000, March 2000.
>> >
>> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>> >
>>
>> To be really useful in a wide range of environments, I believe that =
:
>>
>> - CHOKe should be able to use an external flow classifier (like say.=
=2E.
>> SFQ) to compute a token and compare two skbs by this token instead o=
f
>> custom rxhash or whatever. (rxhash can be the default in absence of =
flow
>> classifier). Probably you need to store the token in skb->cb[] to av=
oid
>> calling tc_classify() several times for a given packet.
>>
>> http://lwn.net/Articles/236200/
>> http://kerneltrap.org/mailarchive/linux-netdev/2008/1/31/667679
>
> Probably should split SFQ flow hash stuff into core code for reuse.
>
>

We need not do that, since we have sch_drr and cls_flow. :)

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)

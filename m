From: Jerry Chu <hkchu@google.com>
Subject: Re: GRO: very bad routing performance with 3.14.4 for GRE-packets
Date: Fri, 11 Jul 2014 08:57:12 -0700
Message-ID: <CAPshTCjVHkw-B-a6uBW-KE69NG91zy8XbVuj_zaq-MLT_h3Z6A@mail.gmail.com>
References: <1442942.x8F4o95O8x@h2o.as.studentenwerk.mhn.de>
	<1404859475.3515.10.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAPshTCgBRn6JT=b=anaoLxeAs1CfkiavuV4MRev+yeHo9VBddQ@mail.gmail.com>
	<10126633.oS5Z8BFzgN@h2o.as.studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Wolfgang Walter <linux@stwm.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f178.google.com ([209.85.220.178]:51568 "EHLO
	mail-vc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751522AbaGKP5O convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2014 11:57:14 -0400
Received: by mail-vc0-f178.google.com with SMTP id ij19so2414319vcb.37
        for <netdev@vger.kernel.org>; Fri, 11 Jul 2014 08:57:13 -0700 (PDT)
In-Reply-To: <10126633.oS5Z8BFzgN@h2o.as.studentenwerk.mhn.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 10, 2014 at 7:34 AM, Wolfgang Walter <linux@stwm.de> wrote:
> Am Dienstag, 8. Juli 2014, 17:19:33 schrieb Jerry Chu:
>> On Tue, Jul 8, 2014 at 3:44 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
>> > On Tue, 2014-07-08 at 22:35 +0200, Wolfgang Walter wrote:
>> >> Hello,
>> >>
>> >> I upgraded a router from 3.10.46 to 3.14.4 and I see a dramatic
>> >> perfomance
>> >> loss for GRE-pakets if (and only if) GRO is enabled on the incomi=
ng or
>> >> outgoing interface (drops to 1/50th to 1/100th).
>> >>
>> >> Other traffic is just fine.
>> >>
>> >> The router itself is not endpoint of the GRE-tunnel.
>> >>
>> >> The router has connection tracking enabled and does NAT (but most=
 of the
>> >> traffic is not NATed nor are GRE-packets).
>> >>
>> >> The network card is an Intel Corporation I350 Gigabit (both inter=
faces).
>> >>
>> >> Regards,
>> >
>> > GRO is a win if the consumer of the packets understands GSO packet=
s.
>> >
>> > In this case, Intel driver is not able to send GSO packets with GR=
E
>> > encapsulation, so they need to be segmented before being sent.
>> >
>> > That's extra work and not worth it, as you noticed.
>> >
>> > One way to get good performance would be to implement a software T=
SO in
>> > the Intel driver for the GRE encapsulated packets.
>> >
>> > You might revert bf5a755f5e9186406bbf50f4087100af5bd68e40, or subm=
it a
>> > patch to make the GRE handling in GRO an optional feature.
>>
>> There is also a bug to the forwarding path introduced by my GRE-GRO
>> patch that I discovered a while back and submitted a fix to it. Plea=
se
>> see http://patchwork.ozlabs.org/patch/324953/ and let me know if tha=
t
>> addresses the problem you've seen. Sorry I have not got the time to
>> follow through with the patch.
>
> Yes, this patch fixes the problem.
>
> Is there any chance this will make it into 3.14, soon?

Will try to resubmit the patch soon.

>
> I would recommend to revert bf5a755f5e9186406bbf50f4087100af5bd68e40 =
in 3.14
> for now and reapply it when this fix is available as this is a real
> regression.
>
> Thanks for your help.
>
> Regards,
> --
> Wolfgang Walter
> Studentenwerk M=C3=BCnchen
> Anstalt des =C3=B6ffentlichen Rechts

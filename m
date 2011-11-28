From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH 5/5] tcp: skip cwnd moderation in TCP_CA_Open in tcp_try_to_open
Date: Mon, 28 Nov 2011 12:35:01 -0500
Message-ID: <CADVnQykp47igdNbN68nbdd4SzaPoDCVTX-bDog4MDesWBbv9MA@mail.gmail.com>
References: <alpine.DEB.2.00.1111201024080.22397@melkinpaasi.cs.helsinki.fi>
	<CAK6E8=cNBCJbQs9dKcOwU1yZMC6czgMEuZt4Ubt=t-kBzHfFmw@mail.gmail.com>
	<alpine.DEB.2.00.1111221146060.31705@wel-95.cs.helsinki.fi>
	<20111127.190120.2116987138205753451.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, ycheng@google.com,
	netdev@vger.kernel.org, nanditad@google.com, therbert@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:33969 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751533Ab1K1RfD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2011 12:35:03 -0500
Received: by yenl6 with SMTP id l6so3091446yen.19
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2011 09:35:01 -0800 (PST)
In-Reply-To: <20111127.190120.2116987138205753451.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 27, 2011 at 7:01 PM, David Miller <davem@davemloft.net> wro=
te:
> From: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Tue, 22 Nov 2011 13:47:13 +0200 (EET)
>
>> On Mon, 21 Nov 2011, Yuchung Cheng wrote:
>>
>>> AFAIK cwnd moderation is to lower bursty drops not to discourage
>>> (dsack) cheating. I believe the reason is the same in
>>> tcp_try_to_open(). We are in common cases, e.g., loss-recovery, thi=
s
>>> logic hurts performance.
>>
>> Quote from the patch description: "Senders were overriding cwnd valu=
es
>> picked during an undo by calling tcp_moderate_cwnd()" ...so after al=
l it
>> has to do with undo being limited. IMHO only up to orig_cwnd/2+IW is=
 safe
>> due to cheating opportunities. Also FRTO uses orig_cwnd/2 due to sam=
e
>> reason (it could do the +IW too but IIRC it is only /2 currently). W=
hat
>> would be the safeguard there after this one is removed? I kind of se=
e your
>> point about this particular line being related to burst mitigation b=
ut on
>> the same time the end result of removal is that undo becomes potenti=
ally
>> much more aggressive.
>
> I'm apply this patch to net-next now, but Neil and Yucheng are on the=
 hook
> to fully look into the issues Ilpo has raised.

Thanks! We will spend some time looking into these issues.

neal

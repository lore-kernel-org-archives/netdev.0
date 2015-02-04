From: Michal Kazior <michal.kazior@tieto.com>
Subject: Re: Throughput regression with `tcp: refine TSO autosizing`
Date: Wed, 4 Feb 2015 13:22:23 +0100
Message-ID: <CA+BoTQ=BDcQ779uKCuX+f40=4npXVF4MTQnpjKimNYAxPsxBoQ@mail.gmail.com>
References: <CA+BoTQkVu23P3EOmY_Q3E1GJnWsyF==Pawz4iPOS_Bq5dvfO5Q@mail.gmail.com>
	<1422537297.21689.15.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQk2xT-8DqPuiiKG+kHAjLPrj8F9dLTb-rcGhvMq0u_2Qw@mail.gmail.com>
	<1422628835.21689.95.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQkV+mOZfe_Niz5101sMQeaV6muKCsShptjGQ1AgOHqqoQ@mail.gmail.com>
	<1422903136.21689.114.camel@edumazet-glaptop2.roam.corp.google.com>
	<1422926330.21689.138.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQkMikA8wxm1ce2DkKhPB0HiKeAqT7f+sQ=91W40z=X0Rg@mail.gmail.com>
	<1422973660.907.10.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQmvUuFdfYF=wVMYxrf_nQZB5GCV=LvDZVvfs-3hAE4WKw@mail.gmail.com>
	<1423051045.907.108.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	eyalpe@dev.mellanox.co.il
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:39806 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964860AbbBDMWY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 07:22:24 -0500
Received: by mail-wi0-f172.google.com with SMTP id h11so31335702wiw.5
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 04:22:23 -0800 (PST)
In-Reply-To: <1423051045.907.108.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4 February 2015 at 12:57, Eric Dumazet <eric.dumazet@gmail.com> wrot=
e:
> On Wed, 2015-02-04 at 12:35 +0100, Michal Kazior wrote:
>
>> > (Or maybe wifi drivers should start to use skb->xmit_more as a sig=
nal to end aggregation)
>>
>> This could work if your firmware/device supports this kind of thing.
>> To my understanding ath10k firmware doesn't.
>
> This is a pure software signal. You do not need firmware support.
>
> Idea is the following :
>
> Your driver gets a train of messages, coming from upper layers (TCP, =
IP,
> qdisc)
>
> It can know that a packet is not the last one, by looking at
> skb->xmit_more.
>
> Basically, aggregation logic could use this signal as a very clear
> indicator you got the end of a train -> force the xmit right now.

There's no way to tell ath10k firmware: "xmit right now". The firmware
does all tx aggregation logic by itself. Host driver just submits a
frame and hopes it'll get out soon. It's not even a tx-ring you'd
expect. Each frame has a host assigned id which firmware then uses in
tx completion.


> To disable gso you would have to use :
>
> ethtool -K wlan1 gso off

Oh, thanks! This works. However I can't turn it on:

; ethtool -K wlan1 gso on
Could not change any device features

=2E.so I guess it makes no sense to re-run tests because:

; ethtool -k wlan1 | grep generic
        tx-checksum-ip-generic: on [fixed]
generic-segmentation-offload: off [requested on]
generic-receive-offload: on

And this seems to never change.


Micha=C5=82

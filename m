From: Michal Kazior <michal.kazior@tieto.com>
Subject: Re: Throughput regression with `tcp: refine TSO autosizing`
Date: Fri, 6 Feb 2015 15:09:36 +0100
Message-ID: <CA+BoTQkazCOin7VWLfrHUjtgKDPV6T+sFsk5FPS7D-morr4FZQ@mail.gmail.com>
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
	<CA+BoTQ=BDcQ779uKCuX+f40=4npXVF4MTQnpjKimNYAxPsxBoQ@mail.gmail.com>
	<1423053531.907.115.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQ=qmCZz4CmSOvCOzMLowrDEG12XBffkTcYxjGqVD9604g@mail.gmail.com>
	<1423055810.907.125.camel@edumazet-glaptop2.roam.corp.google.com>
	<1423056591.907.130.camel@edumazet-glaptop2.roam.corp.google.com>
	<1423084303.31870.15.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQnnwrv0nrKyGyQNvosz_E4e5fBa9iN8fpeqcd-iRfi17g@mail.gmail.com>
	<1423141038.31870.38.camel@edumazet-glaptop2.roam.corp.google.com>
	<1423142342.31870.49.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQmcShK0U_cXvEOLY_8y7LH8x3taTgjcyMzv0MLVn4UtCA@mail.gmail.com>
	<1423147286.31870.59.camel@edumazet-glaptop2.roam.corp.google.com>
	<1423156205.31870.86.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQ=WaKLV=r6qWaWAEfyDr2pqMWpm4NDmnek92TEVndnxRQ@mail.gmail.com>
	<1423230001.31870.128.camel@edumazet-glaptop2.roam.corp.google.com>
	<1423230785.31870.131.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neal Cardwell <ncardwell@google.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Eyal Perry <eyalpe@dev.mellanox.co.il>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:49719 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752509AbbBFOJi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 09:09:38 -0500
Received: by mail-wi0-f178.google.com with SMTP id bs8so2681364wib.5
        for <netdev@vger.kernel.org>; Fri, 06 Feb 2015 06:09:36 -0800 (PST)
In-Reply-To: <1423230785.31870.131.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6 February 2015 at 14:53, Eric Dumazet <eric.dumazet@gmail.com> wrot=
e:
> On Fri, 2015-02-06 at 05:40 -0800, Eric Dumazet wrote:
>
>> tcp_wfree() could maintain in tp->tx_completion_delay_ms an EWMA
>> of TX completion delay. But this would require yet another expensive
>> call to ktime_get() if HZ < 1000.
>>
>> Then tcp_write_xmit() could use it to adjust :
>>
>>    limit =3D max(2 * skb->truesize, sk->sk_pacing_rate >> 9);
>>
>> to
>>
>>    amount =3D (2 + tp->tx_completion_delay_ms) * sk->sk_pacing_rate
>>
>>    limit =3D max(2 * skb->truesize, amount / 1000);
>>
>> I'll cook a patch.
>
> Hmm... doing this in all protocols would be too expensive,
> and we do not want to include time spent in qdiscs.
>
> wifi could eventually do that, providing in skb->tx_completion_delay_=
us
> the time spent in wifi driver.
>
> This way, we would have no penalty for network devices doing normal s=
kb
> orphaning (loopback interface, ethernet, ...)

I'll play around with this idea and report back later.


Micha=C5=82

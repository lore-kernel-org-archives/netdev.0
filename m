From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Throughput regression with `tcp: refine TSO autosizing`
Date: Tue, 10 Feb 2015 05:14:39 -0800
Message-ID: <1423574079.28434.21.camel@edumazet-glaptop2.roam.corp.google.com>
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
	 <CA+BoTQ=u_xPuqTVOVaFTQNRrJ+UTXe89SY+=+7Y1LpxxrkRDfg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Neal Cardwell <ncardwell@google.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Eyal Perry <eyalpe@dev.mellanox.co.il>
To: Michal Kazior <michal.kazior@tieto.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:42329 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755677AbbBJNOo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 08:14:44 -0500
In-Reply-To: <CA+BoTQ=u_xPuqTVOVaFTQNRrJ+UTXe89SY+=+7Y1LpxxrkRDfg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-02-10 at 11:33 +0100, Michal Kazior wrote:
>                            ath10k_core_napi_dummy_poll, 64);
> +       ewma_init(&ar->tx_delay_us, 16384, 8);


1) 16384 factor might be too big.

2) a weight of 8 seems too low given aggregation values used in wifi.

On 32bit arches, the max range for ewma value would be 262144 usec,
a quarter of a second...

You could use a factor of 64 instead, and a weight of 16.

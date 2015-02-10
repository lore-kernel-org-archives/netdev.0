From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Throughput regression with `tcp: refine TSO autosizing`
Date: Tue, 10 Feb 2015 07:09:34 -0800
Message-ID: <1423580974.28434.29.camel@edumazet-glaptop2.roam.corp.google.com>
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
	 <CA+BoTQkazCOin7VWLfrHUjtgKDPV6T+sFsk5FPS7D-morr4FZQ@mail.gmail.com>
	 <CA+BoTQn3KRym0qCJ+fLav5LQgjfiN_-Eqz0xPSc2eXJ-ijNjQw@mail.gmail.com>
	 <1423494690.31870.189.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQ=u_xPuqTVOVaFTQNRrJ+UTXe89SY+=+7Y1LpxxrkRDfg@mail.gmail.com>
	 (sfid-20150210_113400_003683_520989B4) <1423577962.2215.2.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Michal Kazior <michal.kazior@tieto.com>,
	Neal Cardwell <ncardwell@google.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Eyal Perry <eyalpe@dev.mellanox.co.il>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:44731 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750704AbbBJPJk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 10:09:40 -0500
In-Reply-To: <1423577962.2215.2.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-02-10 at 15:19 +0100, Johannes Berg wrote:
> On Tue, 2015-02-10 at 11:33 +0100, Michal Kazior wrote:
> 
> > +       if (msdu->sk) {
> > +               ewma_add(&ar->tx_delay_us,
> > +                        ktime_to_ns(ktime_sub(ktime_get(), skb_cb->stamp)) /
> > +                        NSEC_PER_USEC);
> > +
> > +               ACCESS_ONCE(msdu->sk->sk_tx_completion_delay_cushion) =
> > +                               (ewma_read(&ar->tx_delay_us) *
> > +                                msdu->sk->sk_pacing_rate) >> 20;
> > +       }
> 
> To some extent, every wifi driver is going to have this problem. Perhaps
> we should do this in mac80211?

I'll provide the TCP patch.

sk->sk_tx_completion_delay_cushion is probably a wrong name, as the
units here are in bytes, since it is really number of bytes in the
network driver that accommodate for tx completions delays. 

tx_completion_delay * pacing_rate

sk_tx_completion_cushion maybe.

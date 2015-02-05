From: Dave Taht <dave.taht@gmail.com>
Subject: Re: Throughput regression with `tcp: refine TSO autosizing`
Date: Fri, 6 Feb 2015 08:50:03 +1300
Message-ID: <CAA93jw45o-Tnt4hEYgc-wHJ26J11dDZLptO9ZONy0Jxp350S3A@mail.gmail.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eyal Perry <eyalpe@dev.mellanox.co.il>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>
To: Michal Kazior <michal.kazior@tieto.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:62792 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752329AbbBETuE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 14:50:04 -0500
In-Reply-To: <CA+BoTQmcShK0U_cXvEOLY_8y7LH8x3taTgjcyMzv0MLVn4UtCA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 6, 2015 at 2:44 AM, Michal Kazior <michal.kazior@tieto.com>=
 wrote:
>
> On 5 February 2015 at 14:19, Eric Dumazet <eric.dumazet@gmail.com> wr=
ote:
> > On Thu, 2015-02-05 at 04:57 -0800, Eric Dumazet wrote:
> >
> >> The intention is to control the queues to the following :
> >>
> >> 1 ms of buffering, but limited to a configurable value.
> >>
> >> On a 40Gbps flow, 1ms represents 5 MB, which is insane.
> >>
> >> We do not want to queue 5 MB of traffic, this would destroy latenc=
ies
> >> for all concurrent flows. (Or would require having fq_codel or fq =
as
> >> packet schedulers, instead of default pfifo_fast)
> >>
> >> This is why having 1.5 ms delay between the transmit and TX comple=
tion
> >> is a problem in your case.
>
> I do get your point. But 1.5ms is really tough on Wi-Fi.
>
> Just look at this:
>
> ; ping 192.168.1.2 -c 3
> PING 192.168.1.2 (192.168.1.2) 56(84) bytes of data.
> 64 bytes from 192.168.1.2: icmp_seq=3D1 ttl=3D64 time=3D1.83 ms
> 64 bytes from 192.168.1.2: icmp_seq=3D2 ttl=3D64 time=3D2.02 ms
> 64 bytes from 192.168.1.2: icmp_seq=3D3 ttl=3D64 time=3D1.98 ms
>
> ; ping 192.168.1.2 -c 3 -Q 224
> PING 192.168.1.2 (192.168.1.2) 56(84) bytes of data.
> 64 bytes from 192.168.1.2: icmp_seq=3D1 ttl=3D64 time=3D0.939 ms
> 64 bytes from 192.168.1.2: icmp_seq=3D2 ttl=3D64 time=3D0.906 ms
> 64 bytes from 192.168.1.2: icmp_seq=3D3 ttl=3D64 time=3D0.946 ms
>
> This was run with no load so batching code in the driver itself shoul=
d
> have no measurable effect. The channel was near-ideal: low noise
> floor, cabled rf, no other traffic.
>
> The lower latency ping is when 802.11 QoS Voice Access Category is
> used. I also get 400mbps instead of 250mbps in this case with 5 flows
> (net/master).
>

The VO queue is now nearly useless in a real world environment. Whlle
it does grab the media mildly faster in some cases, on a good day with
no other competing APs, it cannot aggregate packets, and wastes TXOPS.
It is far saner to aim for better aggregate (use the VI queue if you
must try to get better media acquisition).

It is disabled in multiple products I know of.

And I really, really, really wish, that just once during this thread,
someone had bothered to try running a test
at a real world MCS rate - say MCS1, or MCS4, and measured the latency
under load of that...

or tried talking to two or more stations at the same time.

Instead of trying for 1.5Gbits in a faraday cage.


>
> Dealing with black box firmware blobs is a pain.
>

+10

>
>
> > Note that TCP stack could detect when this happens, *if* ACK where
> > delivered before the TX completions, or when TX completion happens,
> > we could detect that the clone of the freed packet was freed.
> >
> > In my test, when I did "ethtool -C eth0 tx-usecs 1024 tx-frames 64"=
, and
> > disabling GSO, TCP stack sends a bunch of packets (a bit less than =
64),
> > blocks on tcp_limit_output_bytes.
> >
> > Then we receive 2 stretch ACKS after ~50 usec.
> >
> > TCP stack tries to push again some packets but blocks on
> > tcp_limit_output_bytes again.
> >
> > 1ms later, TX completion happens, tcp_wfree() is called, and TCP st=
ack
> > push following ~60 packets.
> >
> >
> > TCP could  eventually dynamically adjust the tcp_limit_output_bytes=
,
> > using a per flow dynamic value, but I would rather not add a kludge=
 in
> > TCP stack only to deal with a possible bug in ath10k driver.
> >
> > niu has a similar issue and simply had to call skb_orphan() :
> >
> > drivers/net/ethernet/sun/niu.c:6669:            skb_orphan(skb);
>
> Ok. I tried calling skb_orphan() right after I submit each Tx frame
> (similar to niu which does this in start_xmit):
>
> --- a/drivers/net/wireless/ath/ath10k/htt_tx.c
> +++ b/drivers/net/wireless/ath/ath10k/htt_tx.c
> @@ -564,6 +564,8 @@ int ath10k_htt_tx(struct ath10k_htt *htt, struct
> sk_buff *msdu)
>         if (res)
>                 goto err_unmap_msdu;
>
> +       skb_orphan(msdu);
> +
>         return 0;
>
>  err_unmap_msdu:
>
>
> Now, with {net/master + ath10k GRO + the above} I get 620mbps on a
> single flow (even better then before). Wow.
>
> Does this look ok/safe as a solution to you?
>
>
> Micha=C5=82
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html




--=20
Dave T=C3=A4ht

thttp://www.bufferbloat.net/projects/bloat/wiki/Upcoming_Talks

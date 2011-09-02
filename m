From: Phil Sutter <phil.sutter@viprinet.com>
Subject: Re: FW: [PATCH] af_packet: flush complete kernel cache in
 packet_sendmsg
Date: Fri, 2 Sep 2011 17:31:47 +0200
Message-ID: <20110902153147.GB29025@philter>
References: <20110505141107.GC30443@orbit.nwl.cc>
 <1314961686-30870-1-git-send-email-phil.sutter@viprinet.com>
 <D3F292ADF945FB49B35E96C94C2061B90A239361@nsmail.netscout.com>
 <CAAsGZS6Tt9FLXfanH1+DgKt_9gR_YPJ8kX_pryhnzWTQVkNkNw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	linux@arm.linux.org.uk, davem@davemloft.net
To: chetan loke <loke.chetan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vipri.net ([89.207.250.2]:44189 "EHLO mail.vipri.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752900Ab1IBPcH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Sep 2011 11:32:07 -0400
Content-Disposition: inline
In-Reply-To: <CAAsGZS6Tt9FLXfanH1+DgKt_9gR_YPJ8kX_pryhnzWTQVkNkNw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 02, 2011 at 10:00:16AM -0400, chetan loke wrote:
> >
> > This flushes the cache before and after accessing the mmapped packe=
t
> > buffer. It seems like the call to flush_dcache_page from inside
> > __packet_get_status is not enough on Kirkwood (or ARM in general).
>=20
>=20
>=20
> > + =C2=A0 =C2=A0 =C2=A0 kw_extra_cache_flush();
> > + =C2=A0 =C2=A0 =C2=A0 rc =3D po->tx_ring.pg_vec ? tpacket_snd(po, =
msg) :
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 packet_snd(sock, msg, len);
> > + =C2=A0 =C2=A0 =C2=A0 kw_extra_cache_flush();
> > + =C2=A0 =C2=A0 =C2=A0 return rc;
> > =C2=A0}
>=20
> If a workaround is needed for mmap, then why not change tpacket_snd?

I did not verify that packet_snd() is not affected. OTOH, adding it
there was quite "intuitive".

> Also, is this workaround actually working for all the cases? Because
> packet_get_status is not being touched in your patch.
>=20
> Also, I don't see any changes for the Rx-path. Is that working ok?

So far we haven't noticed problems in that direction. I just tried some
explicit test: having tcpdump print local timestamps (not the pcap-ones=
)
on every received packet, activating icmp_echo_ignore_all and pinging
the host on a dedicated line. I expected to sometimes see a second
difference between the two timestamps, as like with sending from time t=
o
time a packet should get "lost" in the cache, and then occur to
userspace after the next one arrived. Maybe my test is broken, or RX is
indeed unaffected.

Greetings and thanks for the hints, Phil
--=20
Viprinet GmbH
Mainzer Str. 43
55411 Bingen am Rhein
Germany

Zentrale:     +49-6721-49030-0
Durchwahl:    +49-6721-49030-134
=46ax:          +49-6721-49030-209

phil.sutter@viprinet.com
http://www.viprinet.com

Sitz der Gesellschaft: Bingen am Rhein
Handelsregister: Amtsgericht Mainz HRB40380
Gesch=C3=A4ftsf=C3=BChrer: Simon Kissel

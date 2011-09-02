From: chetan loke <loke.chetan@gmail.com>
Subject: Re: FW: [PATCH] af_packet: flush complete kernel cache in packet_sendmsg
Date: Fri, 2 Sep 2011 10:00:16 -0400
Message-ID: <CAAsGZS6Tt9FLXfanH1+DgKt_9gR_YPJ8kX_pryhnzWTQVkNkNw@mail.gmail.com>
References: <20110505141107.GC30443@orbit.nwl.cc>
	<1314961686-30870-1-git-send-email-phil.sutter@viprinet.com>
	<D3F292ADF945FB49B35E96C94C2061B90A239361@nsmail.netscout.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux@arm.linux.org.uk, davem@davemloft.net
To: phil.sutter@viprinet.com, linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:36474 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752241Ab1IBOAR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2011 10:00:17 -0400
Received: by gxk21 with SMTP id 21so2162791gxk.19
        for <netdev@vger.kernel.org>; Fri, 02 Sep 2011 07:00:17 -0700 (PDT)
In-Reply-To: <D3F292ADF945FB49B35E96C94C2061B90A239361@nsmail.netscout.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> This flushes the cache before and after accessing the mmapped packet
> buffer. It seems like the call to flush_dcache_page from inside
> __packet_get_status is not enough on Kirkwood (or ARM in general).



> + =C2=A0 =C2=A0 =C2=A0 kw_extra_cache_flush();
> + =C2=A0 =C2=A0 =C2=A0 rc =3D po->tx_ring.pg_vec ? tpacket_snd(po, ms=
g) :
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 packet_snd(sock, msg, len);
> + =C2=A0 =C2=A0 =C2=A0 kw_extra_cache_flush();
> + =C2=A0 =C2=A0 =C2=A0 return rc;
> =C2=A0}

If a workaround is needed for mmap, then why not change tpacket_snd?

Also, is this workaround actually working for all the cases? Because
packet_get_status is not being touched in your patch.

Also, I don't see any changes for the Rx-path. Is that working ok?


Chetan Loke

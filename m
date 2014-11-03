From: Neal Cardwell <ncardwell@google.com>
Subject: Re: TCP NewReno and single retransmit
Date: Mon, 3 Nov 2014 18:17:21 -0500
Message-ID: <CADVnQykePToQ-MatwFV=o7iYw_1T7L_jg_3NtaXRueyMA=GAuw@mail.gmail.com>
References: <544E93BD.50202@redhat.com>
	<CADVnQynu7+wgkNTkdY=XDBeyWjFxpYYBjx=n98g1_awdG2OpnA@mail.gmail.com>
	<54521FD6.70403@redhat.com>
	<CAK6E8=dYfJw16Q0D40QD7RLr=wq=y+5W59zHmZ24L49OPS9O5A@mail.gmail.com>
	<5457AF6D.6010105@redhat.com>
	<CADVnQykXpA_A87+bFOCdbb-QLTRf-5TEgspCzE-STO49N+6waw@mail.gmail.com>
	<5457F52F.8060002@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Yuchung Cheng <ycheng@google.com>, netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Marcelo Ricardo Leitner <mleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f44.google.com ([209.85.192.44]:41247 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750719AbaKCXRW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 18:17:22 -0500
Received: by mail-qg0-f44.google.com with SMTP id q107so9809828qgd.3
        for <netdev@vger.kernel.org>; Mon, 03 Nov 2014 15:17:21 -0800 (PST)
In-Reply-To: <5457F52F.8060002@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 3, 2014 at 4:35 PM, Marcelo Ricardo Leitner
<mleitner@redhat.com> wrote:
> So by sticking with the recovery for a bit longer will help disambiguate the
> 3 dupacks on high_seq, if they ever happen, and with that avoid re-entering
> Fast Retransmit if initial (2) happen. It's at the cost of leaving the fast
> retransmit an ack later but if (2) happens the impact would be much worse,
> AFAICS.

Yes, that's my sense.

> Cool, thanks Neal. If Yuchung is okay with it, I'll proceed with just
> zeroing that tstamp as initially proposed.

Yes, that sounds good to me for a short-term fix for the "net" branch,
as long as it's:

+  if (!tcp_any_retrans_done(sk))
+    tp->retrans_stamp = 0;

Longer-term ("net-next"?) perhaps it makes sense to remove the hold
state and protect against this spurious FR situation at the time we
decide to enter Fast Recovery, which seems to be the model the RFC is
suggesting.

neal

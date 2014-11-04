From: Yuchung Cheng <ycheng@google.com>
Subject: Re: TCP NewReno and single retransmit
Date: Tue, 4 Nov 2014 15:59:03 +0800
Message-ID: <CAK6E8=cgkznkAWTps7aA+txuETpZ2RNiU3rbQf9WxLjawhgNog@mail.gmail.com>
References: <544E93BD.50202@redhat.com> <CADVnQynu7+wgkNTkdY=XDBeyWjFxpYYBjx=n98g1_awdG2OpnA@mail.gmail.com>
 <54521FD6.70403@redhat.com> <CAK6E8=dYfJw16Q0D40QD7RLr=wq=y+5W59zHmZ24L49OPS9O5A@mail.gmail.com>
 <5457AF6D.6010105@redhat.com> <CADVnQykXpA_A87+bFOCdbb-QLTRf-5TEgspCzE-STO49N+6waw@mail.gmail.com>
 <5457F52F.8060002@redhat.com> <CADVnQykePToQ-MatwFV=o7iYw_1T7L_jg_3NtaXRueyMA=GAuw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Marcelo Ricardo Leitner <mleitner@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:40401 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750985AbaKDH7o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 02:59:44 -0500
Received: by mail-ig0-f180.google.com with SMTP id h3so6142912igd.13
        for <netdev@vger.kernel.org>; Mon, 03 Nov 2014 23:59:44 -0800 (PST)
In-Reply-To: <CADVnQykePToQ-MatwFV=o7iYw_1T7L_jg_3NtaXRueyMA=GAuw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 4, 2014 at 7:17 AM, Neal Cardwell <ncardwell@google.com> wrote:
> On Mon, Nov 3, 2014 at 4:35 PM, Marcelo Ricardo Leitner
> <mleitner@redhat.com> wrote:
>> So by sticking with the recovery for a bit longer will help disambiguate the
>> 3 dupacks on high_seq, if they ever happen, and with that avoid re-entering
>> Fast Retransmit if initial (2) happen. It's at the cost of leaving the fast
>> retransmit an ack later but if (2) happens the impact would be much worse,
>> AFAICS.
>
> Yes, that's my sense.
>
>> Cool, thanks Neal. If Yuchung is okay with it, I'll proceed with just
>> zeroing that tstamp as initially proposed.
>
> Yes, that sounds good to me for a short-term fix for the "net" branch,
> as long as it's:
>
> +  if (!tcp_any_retrans_done(sk))
> +    tp->retrans_stamp = 0;
>
> Longer-term ("net-next"?) perhaps it makes sense to remove the hold
> state and protect against this spurious FR situation at the time we
> decide to enter Fast Recovery, which seems to be the model the RFC is
> suggesting.
Thanks for checking. So my suggested fix of removing the hold state is
the "less careful variant" that RFC does not recommend. I would rather
have the proposed 2-liner fix than implementing the section 6
heuristics to detect spurious retransmit. It's not worth the effort.
Everyone should use SACK.

>
> neal

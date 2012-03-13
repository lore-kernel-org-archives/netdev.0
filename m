From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH] tcp: fix syncookie regression
Date: Tue, 13 Mar 2012 12:44:00 -0400
Message-ID: <CADVnQynM5F=B60-7AMFHn0A9g-jvcBzo+dSg-C0isDBo_UMyjw@mail.gmail.com>
References: <20120310122725.GA31129@hostway.ca>
	<1331401490.2453.28.camel@edumazet-laptop>
	<1331402182.2453.30.camel@edumazet-laptop>
	<1331407221.2453.42.camel@edumazet-laptop>
	<20120313072643.GA32306@hostway.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Simon Kirby <sim@netnation.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:39457 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755534Ab2CMQoC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2012 12:44:02 -0400
Received: by eekc41 with SMTP id c41so397769eek.19
        for <netdev@vger.kernel.org>; Tue, 13 Mar 2012 09:44:01 -0700 (PDT)
In-Reply-To: <20120313072643.GA32306@hostway.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 13, 2012 at 3:26 AM, Simon Kirby <sim@netnation.com> wrote:
>
> While deploying this on top of 3.2.9, we hit what seems to be the bug
> fixed by 4648dc97af9d496218a05353b0e442b3dfa6aaab in 3.3. I see 3.2.9=
 has
> daef52bab1fd26e24e8e9578f8fb33ba1d0cb412, so maybe this is exposed in=
 3.2
> now?
=2E..
> net/ipv4/tcp_input.c:
> =A0 =A0 3438 #if FASTRETRANS_DEBUG > 0
> ---> 3439 =A0 =A0 =A0 =A0 WARN_ON((int)tp->sacked_out < 0);
> =A0 =A0 3440 =A0 =A0 =A0 =A0 WARN_ON((int)tp->lost_out < 0);
> =A0 =A0 3441 =A0 =A0 =A0 =A0 WARN_ON((int)tp->retrans_out < 0);
> =A0 =A0 3442 =A0 =A0 =A0 =A0 if (!tp->packets_out && tcp_is_sack(tp))=
 {
> ...
> =A0 =A0 3057 =A0 =A0 =A0 =A0 /* D. Check consistency of the current s=
tate. */
> ---> 3058 =A0 =A0 =A0 =A0 tcp_verify_left_out(tp);

Yes, exactly. 3.2.9 and 3.2.10 have
daef52bab1fd26e24e8e9578f8fb33ba1d0cb412 but not the
4648dc97af9d496218a05353b0e442b3dfa6aaab that fixes the resulting
issue with sacked_out going negative, and these lines you've flagged
are exactly the symptoms we'd expect because of that. The fix is
queued up for the -stable series already, so it should be in 3.2.11, I
presume. The fix is already in 3.3-rc7.

> Oops two seconds later, scrolled off console, didn't get written to d=
isk
> or remote syslog server, all we have is syslog-broadcasted Oops and C=
ode
> lines due to broken printk priorities:

As you can imagine, the oops is probably connected to sacked_out going
negative; others have reported an oops along with sacked_out going
negative. The fix should take care of that.

neal

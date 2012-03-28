From: Chao Pei <peichao85@gmail.com>
Subject: Re: a F-RTO question
Date: Wed, 28 Mar 2012 11:49:43 +0800
Message-ID: <CAJkE24+qgK4_cGtiEi6hWDFS2EVYPajHY3pigwh_RqguwsedNg@mail.gmail.com>
References: <4F7281ED.1060603@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Li Yu <raise.sail@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:40866 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756579Ab2C1Dto convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2012 23:49:44 -0400
Received: by lahj13 with SMTP id j13so684893lah.19
        for <netdev@vger.kernel.org>; Tue, 27 Mar 2012 20:49:43 -0700 (PDT)
In-Reply-To: <4F7281ED.1060603@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Hi,
>
> =A0 =A0 =A0 =A0I have a question about tcp_process_frto(), the below =
source
> code :
>
> static int tcp_process_frto(struct sock *sk, int flag)
> {
> =A0 =A0 =A0 =A0.....
>
> =A0 =A0 =A0 =A0if (!before(tp->snd_una, tp->frto_highmark)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tcp_enter_frto_loss(sk, ...);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 1;
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0.....
>
> }
>
> =A0 =A0 =A0 =A0As my understanding, the tp->frto_highmark likes tp->h=
igh_seq,
> it saves the seqno SND_NXT when a TCP connection enters F-RTO phase,
> is it the variable "recovery" in NewReno? So I think that if snd_una =
is
> equal with or after frto_highmark, which means peer ack new data, so
> why we enter Loss state here?
>
> =A0 =A0 =A0 =A0Thanks!
>
> Yu
>
>

If snd_una advances to frto_highmark, it is likely that the hole was
filled by the retransimitted packet, which means the original packet
was likely to have been lost.
So, we should enter loss state.

From: Neal Cardwell <ncardwell@google.com>
Subject: Re: Get amount of fast retransmissions from TCP info
Date: Wed, 3 May 2017 16:01:03 -0400
Message-ID: <CADVnQymNJeeA5F8+5gfxzVRcAEpq9DwipMMDGzp2vQnypH1QdQ@mail.gmail.com>
References: <CAF0XkCCFwxuyJ5bc4SUHjdDJb_E-CqYC-3k3nzi+0i3H9D2zPA@mail.gmail.com>
 <CADVnQyk9-OGKBKBvQ76itP5JwbVBPt40S8KJ+6oY506hVpMEYA@mail.gmail.com>
 <CAF0XkCDTexCTxPmGvM4+FZtVhQg13Ggsbm0QSbcKCSR5LGbs9w@mail.gmail.com>
 <CADVnQyn=6wYbVP0m3mepGU23LcEn_BK_TKoSNxVf=TUz9Q+f8g@mail.gmail.com>
 <CAF0XkCAZJd7adZf6VHdDc2yesyKQ8DqQnDOv_uk8o8mOVGMRyA@mail.gmail.com>
 <8D257A7F-6045-46C5-AEED-A4630D10CD5A@simula.no> <CAF0XkCD_US9yVxsU8GDpEqoH3y3LLOGQF0K8fu5cNbjTewXuNw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Andreas Petlund <apetlund@simula.no>,
        LKML <linux-kernel@vger.kernel.org>,
        Netdev <netdev@vger.kernel.org>
To: =?UTF-8?Q?Lars_Erik_Storbuk=C3=A5s?= <storbukas.dev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:35564 "EHLO
        mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932348AbdECUBf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 16:01:35 -0400
Received: by mail-io0-f175.google.com with SMTP id r16so196781358ioi.2
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 13:01:35 -0700 (PDT)
In-Reply-To: <CAF0XkCD_US9yVxsU8GDpEqoH3y3LLOGQF0K8fu5cNbjTewXuNw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 3, 2017 at 3:47 PM, Lars Erik Storbuk=C3=A5s
<storbukas.dev@gmail.com> wrote:
> I also want to count the amount of ECN signals received. Do anyone
> have any input on where to place an ECN signal count?
>
> Is any of these locations a logical place to increase the ECN counter
> (which I've created in tcp_sock)? Both locations are in the
> tcp_input.c.
>
> /* In tcp_fastretrans_alert() */
> if (flag & FLAG_ECE) {
>     tp->prior_ssthresh =3D 0;
>     tp->ecn_count +=3D 1; // ECN counter
> }

This approach sounds good to me.

> or
>
> /* In tcp_enter_recovery() */
> if (!tcp_in_cwnd_reduction(sk)) {
>     if (!ece_ack)
>         tp->prior_ssthresh =3D tcp_current_ssthresh(sk);
>     else
>        tp->ecn_count +=3D 1; // ECN counter
>     tcp_init_cwnd_reduction(sk);
> }
> tcp_set_ca_state(sk, TCP_CA_Recovery);

This location would only count ECE marks we happened to get at the
moment we enter loss recovery.

neal

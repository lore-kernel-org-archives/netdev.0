From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [RFC v2] tcp: Export TCP Delayed ACK parameters to user
Date: Fri, 28 Oct 2011 14:53:29 -0700
Message-ID: <CALCETrUbWiRLXtpny-M6=ufaSXwgXXNpKKBFm-hGomo6G_sg3g@mail.gmail.com>
References: <1319756841-2051-1-git-send-email-dbaluta@ixiacom.com>
	<1319836443-4419-1-git-send-email-dbaluta@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, eric.dumazet@gmail.com, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, rick.jones2@hp.com
To: Daniel Baluta <dbaluta@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:33820 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933452Ab1J1Vxa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2011 17:53:30 -0400
Received: by ywm3 with SMTP id 3so4050154ywm.19
        for <netdev@vger.kernel.org>; Fri, 28 Oct 2011 14:53:29 -0700 (PDT)
In-Reply-To: <1319836443-4419-1-git-send-email-dbaluta@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 28, 2011 at 2:14 PM, Daniel Baluta <dbaluta@ixiacom.com> wr=
ote:
> RFC2581 ($4.2) specifies when an ACK should be generated as follows:
>
> " .. an ACK SHOULD be generated for at least every second
> =A0full-sized segment, and MUST be generated within 500 ms
> =A0of the arrival of the first unacknowledged packet.
> "
>
> We export the number of segments and the timeout limits
> specified above, so that a user can tune them according
> to its needs.
>
> Specifically:
> =A0 =A0 =A0 =A0* /proc/sys/net/ipv4/tcp_delack_segs, represents
> =A0 =A0 =A0 =A0the threshold for the number of segments.
> =A0 =A0 =A0 =A0* /proc/sys/net/ipv4/tcp_delack_min, specifies
> =A0 =A0 =A0 =A0the minimum timeout value
> =A0 =A0 =A0 =A0* /proc/sys/net/ipv4/tcp_delack_max, specifies
> =A0 =A0 =A0 =A0the maximum timeout value.

This is neat, but IMO it should be per socket -- I (and possibly most
other people who would use it) want to do this kind of tuning per
flow, not per-route or per-interface.

--Andy

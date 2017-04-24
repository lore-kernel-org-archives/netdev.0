From: Neal Cardwell <ncardwell@google.com>
Subject: Re: Get amount of fast retransmissions from TCP info
Date: Mon, 24 Apr 2017 15:42:24 -0400
Message-ID: <CADVnQyk9-OGKBKBvQ76itP5JwbVBPt40S8KJ+6oY506hVpMEYA@mail.gmail.com>
References: <CAF0XkCCFwxuyJ5bc4SUHjdDJb_E-CqYC-3k3nzi+0i3H9D2zPA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: LKML <linux-kernel@vger.kernel.org>,
        Netdev <netdev@vger.kernel.org>
To: =?UTF-8?Q?Lars_Erik_Storbuk=C3=A5s?= <storbukas.dev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:35584 "EHLO
        mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S974793AbdDXTm4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 15:42:56 -0400
Received: by mail-oi0-f48.google.com with SMTP id j201so147866720oih.2
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 12:42:56 -0700 (PDT)
In-Reply-To: <CAF0XkCCFwxuyJ5bc4SUHjdDJb_E-CqYC-3k3nzi+0i3H9D2zPA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 24, 2017 at 3:11 PM, Lars Erik Storbuk=C3=A5s
<storbukas.dev@gmail.com> wrote:
> I'm trying to get amount of congestion events in TCP caused by
> DUPACK's (fast retransmissions), and can't seem to find any variable
> in the TCP info struct which hold that value. There are three
> variables in the TCP info struct that seem to hold similar congestion
> values: __u8 tcpi_retransmits;__u32 tcpi_retrans; __u32
> tcpi_total_retrans;
>
> Does anyone have any pointers on how to find this value in the TCP code?
>
> Please CC me personally if answering this question. Any help is
> greatly appreciated.

[I'm cc-ing the netdev list.]

Do you need this per-socket? On a per-socket basis, I do not think
there are separate totals for fast retransmits and timeout
retransmits.

If a global number is good enough, then you can get that number from
the global network statistics. In "nstat" output they look like:

  TcpExtTCPFastRetrans =3D packets sent in fast retransmit / fast recovery

  TcpExtTCPSlowStartRetrans =3D packets sent in timeout recovery

It sounds like TcpExtTCPFastRetrans is what you are after.

Hope that helps,
neal

From: =?UTF-8?B?QXVyw6lsaWVu?= <footplus@gmail.com>
Subject: Re: Prioritize a vlan on another
Date: Fri, 4 Sep 2015 12:52:45 +0200
Message-ID: <CAPN4dA_N+tLcSRWPcYmoxgLAkmv2HT2aDb8w8se=qH3id4z_Kw@mail.gmail.com>
References: <266BF78D-5C37-40E1-A065-1426CC2325E2@gmail.com>
Reply-To: footplus@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f42.google.com ([209.85.218.42]:34422 "EHLO
	mail-oi0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755326AbbIDKxF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2015 06:53:05 -0400
Received: by oiev17 with SMTP id v17so9652909oie.1
        for <netdev@vger.kernel.org>; Fri, 04 Sep 2015 03:53:04 -0700 (PDT)
In-Reply-To: <266BF78D-5C37-40E1-A065-1426CC2325E2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 1, 2015 at 11:07 PM, <footplus@gmail.com> wrote:
>
> Hello,
>
> I'm not sure if this is the right place to ask this, but i'm stuck on=
 a trafic priority problem since some time.
>
> I have 2 10Gb interfaces (bnx2x) bonded in a 802.3ad aggregate. On th=
is aggregate, 2 vlans are configured (let's INT and EXT) I need to ensu=
re that, when sending traffic at near line rate via EXT, all packets ta=
rgeted to INT are sent in priority (dropping EXT traffic as needed).
>

Replying to myself:

It seems that all I was needing was a -j CLASSIFY --set-class 0:6 in ip=
tables.

This sufficed to classifiy the traffic in band 0 within 8 prio qdisc
(with default priomap/bands) attached below the 8 first classes of mq.
However, the packet TOS does not seem to affect the priority inside
the VLAN/bonding with mq in any way.

Problem solved for me.

Thanks,
Best regards,

--=20
Aur=C3=A9lien Guillaume

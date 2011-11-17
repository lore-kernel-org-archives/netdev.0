From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH net-next] r8169: Add 64bit statistics
Date: Thu, 17 Nov 2011 15:27:58 +0100
Message-ID: <1321540078.2751.38.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <AE90C24D6B3A694183C094C60CF0A2F6D8AECB@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Junchang Wang <junchangwang@gmail.com>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>,
	netdev@vger.kernel.org, romieu@fr.zoreil.com,
	nic swsd <nic_swsd@realtek.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:32769 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757480Ab1KQO2C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 09:28:02 -0500
Received: by bke11 with SMTP id 11so2046634bke.19
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2011 06:28:01 -0800 (PST)
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6D8AECB@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 17 novembre 2011 =C3=A0 14:01 +0000, David Laight a =C3=A9crit=
 :

> Ah yes ...
>=20
> Both u64_stats_update_begin & _end increment a numeric field
> with an appropriate memory barrier. So the 'update' path
> has two extra read-modify-write sequences (possibly the
> 2nd read can be optimised out), and two smp_wmb() that may
> introduce bus delays.
>=20
> Would be fine if it were guaranteed to work!
> Consider the following sequence of events:
>        u64_stats_update_begin()
>        calculate 'count+1'
>                                 read_seqcount_begin()
>                                 read count_hi
>        write count_lo
>                                 read count_lo
>        write count_hi
>                                 read_seqcount_retry()
>        ... update other counters ...
>        u64_stats_update_end()
> The reader gets an invalid value since it reads the same
> 'sequence' both times.
>=20
> Could be fixed by using '|=3D 1' in update_begin and
> looping on odd values in read_seqcount_begin().
>=20

I am a bit tired of this discussion.

You obviously dont understand how the thing is working.

Spend some time on it before claiming there are bugs.

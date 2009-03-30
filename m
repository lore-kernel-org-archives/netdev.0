From: Li Yang <leoli@freescale.com>
Subject: Re: [PATCH] ucc_geth: Move freeing of TX packets to NAPI context.
Date: Mon, 30 Mar 2009 16:34:47 +0800
Message-ID: <2a27d3730903300134q673de9cbg6c92e981efc12695@mail.gmail.com>
References: <1237987849.2194.9.camel@gentoo-jocke.transmode.se>
	 <20090325142540.GA20944@oksana.dev.rtsoft.ru>
	 <OF3C4E8131.4223FD1A-ONC1257584.0061D2E6-C1257584.0062233E@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: avorontsov@ru.mvista.com,
	linuxppc-dev Development <linuxppc-dev@ozlabs.org>,
	Netdev <netdev@vger.kernel.org>
To: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.237]:9351 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753198AbZC3Iet convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2009 04:34:49 -0400
Received: by rv-out-0506.google.com with SMTP id f9so2339061rvb.1
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2009 01:34:47 -0700 (PDT)
In-Reply-To: <OF3C4E8131.4223FD1A-ONC1257584.0061D2E6-C1257584.0062233E@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 26, 2009 at 1:51 AM, Joakim Tjernlund
<Joakim.Tjernlund@transmode.se> wrote:
> Anton Vorontsov <avorontsov@ru.mvista.com> wrote on 25/03/2009 15:25:=
40:
>> On Wed, Mar 25, 2009 at 02:30:49PM +0100, Joakim Tjernlund wrote:
>> > >>From 1c2f23b1f37f4818c0fd0217b93eb38ab6564840 Mon Sep 17 00:00:0=
0
> 2001
>> > From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
>> > Date: Tue, 24 Mar 2009 10:19:27 +0100
>> > Subject: [PATCH] ucc_geth: Move freeing of TX packets to NAPI cont=
ext.
>> > =C2=A0Also increase NAPI weight somewhat.
>> > =C2=A0This will make the system alot more responsive while
>> > =C2=A0ping flooding the ucc_geth ethernet interaface.
>>
>> Some time ago I've tried a similar thing for this driver, but during
>> tcp (or udp I don't quite remember) netperf tests I was getting tx
>> watchdog timeouts after ~2-5 minutes of work. I was testing with a
>> gigabit and 100 Mbit link, with 100 Mbit link the issue was not
>> reproducible.
>>
>> Though, I recalling I was doing a bit more than your patch: I was
>> also clearing the TX events in the ucce register before calling
>> ucc_geth_tx, that way I was trying to avoid stale interrupts. That
>> helped to increase an overall performance (not only responsiveness),
>> but as I said my approach didn't pass the tests.
>>
>> I don't really think that your patch may cause this, but can you
>> try netperf w/ this patch applied anyway? And see if it really
>> doesn't cause any issues under stress?
>
> Does the line(in ucc_geth_tx()) look OK to you:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if ((bd =3D=3D ugeth->txBd[txQ]) && (netif=
_queue_stopped(dev) =3D=3D 0))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0break;
>
> Sure does look fishy to me.

There are two cases when txBd=3DConfBd: the BD ring is full or empty.
The condition used here ensures that it is the empty case.  Because in
hard_start_xmit, the queue will be stopped when the BD ring is full.
Maybe some comment is needed here.

- Leo

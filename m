From: Daniel Borkmann <danborkmann@iogearbox.net>
Subject: Re: mmap RX_RING socket issue 32b application running on 64b kernel.
Date: Wed, 7 Nov 2012 19:26:24 +0100
Message-ID: <CAD6jFURNbY4BkcUeykrkO2PU17+G_mOD7Dw3KrEx0BAaOpqiSA@mail.gmail.com>
References: <CAMJ=MEfeMDC3H2bjKz9XA4072Vo7U17108N4bK77q0GvUEF09w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Ronny Meeus <ronny.meeus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:60656 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752043Ab2KGS0c convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 13:26:32 -0500
Received: from [78.46.5.204] (helo=sslproxy02.your-server.de)
	by www62.your-server.de with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.74)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1TWAKd-0001zk-6s
	for netdev@vger.kernel.org; Wed, 07 Nov 2012 19:26:31 +0100
Received: from [74.125.83.46] (helo=mail-ee0-f46.google.com)
	by sslproxy02.your-server.de with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.72)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1TWAKZ-0005yv-TY
	for netdev@vger.kernel.org; Wed, 07 Nov 2012 19:26:27 +0100
Received: by mail-ee0-f46.google.com with SMTP id b15so1086930eek.19
        for <netdev@vger.kernel.org>; Wed, 07 Nov 2012 10:26:24 -0800 (PST)
In-Reply-To: <CAMJ=MEfeMDC3H2bjKz9XA4072Vo7U17108N4bK77q0GvUEF09w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 7, 2012 at 6:58 PM, Ronny Meeus <ronny.meeus@gmail.com> wro=
te:
> I have an application using raw Ethernet sockets in combination with
> the mmaped RX_RING.
> The application is running on a Cavium MIPS processor (64bit) and the
> application code is compiled with the N32 ABI.
>
> Since the ring buffer is shared between the Linux kernel and the
> application there is a conflict in the way the data is presented.
> Each buffer in the ring has a header that has following structure:
> (File http://lxr.free-electrons.com/source/include/linux/if_packet.h =
)
> 103 struct tpacket_hdr {
> 104         unsigned long   tp_status;
> 105         unsigned int    tp_len;
> 106         unsigned int    tp_snaplen;
> 107         unsigned short  tp_mac;
> 108         unsigned short  tp_net;
> 109         unsigned int    tp_sec;
> 110         unsigned int    tp_usec;
> 111 };
>
> The status field indicates that the buffer belongs to the kernel or t=
o
> the user. Note that an unsigned long is used to represent the field.
> In the kernel the long is 64 bit while in application space the long
> is only 32bit, so the bits do not match.
>
> After adapting the code to take this into account my program works we=
ll.
> In my test program I have defined a new struct where I change the
> =93unsigned long=94 into an =93unsigned long long=94:
>
> struct tpacket_hdr_64 {
>   unsigned long long tp_status;
>   unsigned int tp_len;
>   unsigned int tp_snaplen;
>   unsigned short tp_mac;
>   unsigned short tp_net;
>   unsigned int tp_sec;
>   unsigned int tp_usec;
> };
>
> In my opinion this is not a correct solution. It should be solved
> somewhere in the include file I used so that it is transparent for th=
e
> application.
> Please comment.

Have you tried to use packet_mmap with TPACKET version 2  [1]?

In my understanding, it was introduced because of such issues that you
described.

[1] E.g. http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux.git=
;a=3Dcommitdiff;h=3Dbbd6ef87c544d88c30e4b762b1b61ef267a7d279

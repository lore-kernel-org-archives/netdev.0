From: "Erich E. Hoover" <ehoover@mines.edu>
Subject: Re: [PATCH] Implement IP_UNICAST_IF socket option.
Date: Fri, 27 Jan 2012 08:30:30 -0700
Message-ID: <CAEU2+vrtmuMADSwCdpftXuyQkmYfJpjL11KbB=LOtVQ2SCUhJA@mail.gmail.com>
References: <1327622268-15602-1-git-send-email-ehoover@mines.edu>
	<e75bbc09f45a13abdaccb7ef0de5e7e0@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev <netdev@vger.kernel.org>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from izzard.Mines.EDU ([138.67.132.197]:33416 "EHLO izzard.mines.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754239Ab2A0Pab convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 10:30:31 -0500
Received: from mail-vx0-f174.google.com (mail-vx0-f174.google.com [209.85.220.174])
	(authenticated bits=0)
	by izzard.mines.edu (8.13.8/8.13.8) with ESMTP id q0RFUUtH011426
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <netdev@vger.kernel.org>; Fri, 27 Jan 2012 08:30:30 -0700
Received: by vcbgb30 with SMTP id gb30so1244165vcb.19
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2012 07:30:30 -0800 (PST)
In-Reply-To: <e75bbc09f45a13abdaccb7ef0de5e7e0@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 27, 2012 at 2:01 AM, Hagen Paul Pfeifer <hagen@jauu.net> wr=
ote:
> On Thu, 26 Jan 2012 16:57:48 -0700, "Erich E. Hoover" wrote:
>> The IP_UNICAST_IF feature is needed by the Wine project. =A0This pat=
ch
>> implements the feature by setting the outgoing interface in the same
>> fashion as that of IP_PKTINFO.
>
> Why duplicate functionality - rewrite your application and use IP_PKT=
INFO
> or bind() your socket. This patch duplicate already existing function=
ality
> (and bloat inet_sock unnecessarily).

The IP_UNICAST_IF feature works on broadcast packets, so bind() won't
do the trick.  Also, native Windows applications have the ability to
use both IP_PKTINFO and IP_UNICAST_IF on the same socket, so using
IP_PKTINFO to implement IP_UNICAST_IF might break some applications.
Even so, I did attempt to do this and Alexandre was unsatisfied with
the approach since it required a significant amount of extra code and
the extra communication between the "server" and "user" components of
Wine significantly slowed down socket performance.  Alexendre
indicated that I need to get this functionality added to the kernel to
implement the feature properly, so here I am.

I'm hoping that I can also use this feature, combined with Linux
Socket Filtering, to allow Windows applications to use bind() and have
the socket still work with broadcast packets.  IP_UNICAST_IF is a
relatively new feature, older Windows applications used bind() instead
(Windows bind() still captures broadcast packets).  I've been working
on different ways to get Wine to handle this capability for a long
time and I'd really like to be able to finally check this bug off of
my list.

Anyway, thank you for taking the time to look at my patch.  I really
appreciate and I hope that I've satisfactorily answered your question.

Erich Hoover
ehoover@mines.edu

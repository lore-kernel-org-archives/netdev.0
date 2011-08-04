From: Tom London <selinux@gmail.com>
Subject: Re: return of ip_rt_bug()
Date: Thu, 4 Aug 2011 10:48:22 -0700
Message-ID: <CAFiZG+W9-vV6o9EbuVEwztW4sQ1QV-MxD+xCHFw7TbNAryzN6A@mail.gmail.com>
References: <20110802170942.GA17164@redhat.com>
	<alpine.LFD.2.00.1108041422510.1495@ja.ssi.bg>
	<CAFiZG+X0oyTOXqm4b0g_UEGYK_0JCW3=WOR5d_7GfbJrTMhMzg@mail.gmail.com>
	<alpine.LFD.2.00.1108042034540.1495@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dave Jones <davej@redhat.com>, netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:42136 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755029Ab1HDRsY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2011 13:48:24 -0400
Received: by qwk3 with SMTP id 3so1131706qwk.19
        for <netdev@vger.kernel.org>; Thu, 04 Aug 2011 10:48:23 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.00.1108042034540.1495@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 4, 2011 at 10:37 AM, Julian Anastasov <ja@ssi.bg> wrote:
>
> =A0 =A0 =A0 =A0Hello,
>
> On Thu, 4 Aug 2011, Tom London wrote:
>
>> How else can I help?
>
> =A0 =A0 =A0 =A0From your bug report at
> https://bugzilla.redhat.com/show_bug.cgi?id=3D712632 I see that
> the application is xsane, "Manufacturer: EPSON". I downloaded
> some sources and in sane-backends-git20110804/sanei/sanei_udp.c
> I see some UDP usage.
>
> =A0 =A0 =A0 =A0For example, sane-backends-git20110804/backend/epson2.=
c
> calls sanei_udp_open_broadcast (UDP socket with SO_BROADCAST).
> The socket is not bound, not connected, application sends packet to
> 255.255.255.255:3289 in blocking mode and waits for reply for
> 1 second. It is done for "net autodiscovery" config. As the socket
> is not bound, kernel should search source address for every packet.
> Nothing special so far. Not sure why your report has 2 oopses in
> period of 1 second, may be config has 2 lines "net autodiscovery"
> and 2 packets are sent?
>
> =A0 =A0 =A0 =A0Your first report was for 192.168.2.5 but
> I don't see the IP from your last report that is with
> kernel-3.1.0-0.rc0.git12.1.fc17.x86_64. Now you show local IP is
> 192.168.2.6. Do you have 192.168.2.5 as local IP, what shows
> 'ip addr' ?
>
> =A0 =A0 =A0 =A0Can you confirm that the IP you see in oops is always
> configured (ip addr). Or may be it comes from DHCP and now is
> 192.168.2.6?
>
> =A0 =A0 =A0 =A0Can you start 'ip monitor' in one console while
> attaching the USB device, so that we can know if any IP
> addresses are reconfigured due to some events. For example,
> script that restarts DHCP.
>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
>

Sure.  I'll set this up when I get back home this evening.

Not sure about the 192.168.2.5  vs 192.168.2.6 confusion.  My laptop
is connected to a Belkin router, and uses DHCP.  I sometimes have the
wireless interface connected as well, so perhaps this sometimes occurs
when only the wired NIC is connected and sometimes when both the wired
and wireless NICs are connected?  I'll also see if I can uncover any
DHCP history

I'll try to follow the above instructions, and will report out about 8P=
M PDT.

tom
--=20
Tom London

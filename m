From: Julian Anastasov <ja@ssi.bg>
Subject: Re: return of ip_rt_bug()
Date: Thu, 4 Aug 2011 20:37:43 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1108042034540.1495@ja.ssi.bg>
References: <20110802170942.GA17164@redhat.com> <alpine.LFD.2.00.1108041422510.1495@ja.ssi.bg> <CAFiZG+X0oyTOXqm4b0g_UEGYK_0JCW3=WOR5d_7GfbJrTMhMzg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Dave Jones <davej@redhat.com>, netdev@vger.kernel.org
To: Tom London <selinux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:34598 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753889Ab1HDRdW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Aug 2011 13:33:22 -0400
In-Reply-To: <CAFiZG+X0oyTOXqm4b0g_UEGYK_0JCW3=WOR5d_7GfbJrTMhMzg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Thu, 4 Aug 2011, Tom London wrote:

> How else can I help?

	From your bug report at
https://bugzilla.redhat.com/show_bug.cgi?id=712632 I see that
the application is xsane, "Manufacturer: EPSON". I downloaded
some sources and in sane-backends-git20110804/sanei/sanei_udp.c
I see some UDP usage.

	For example, sane-backends-git20110804/backend/epson2.c
calls sanei_udp_open_broadcast (UDP socket with SO_BROADCAST).
The socket is not bound, not connected, application sends packet to
255.255.255.255:3289 in blocking mode and waits for reply for
1 second. It is done for "net autodiscovery" config. As the socket
is not bound, kernel should search source address for every packet.
Nothing special so far. Not sure why your report has 2 oopses in
period of 1 second, may be config has 2 lines "net autodiscovery"
and 2 packets are sent?

	Your first report was for 192.168.2.5 but
I don't see the IP from your last report that is with
kernel-3.1.0-0.rc0.git12.1.fc17.x86_64. Now you show local IP is
192.168.2.6. Do you have 192.168.2.5 as local IP, what shows
'ip addr' ?

	Can you confirm that the IP you see in oops is always
configured (ip addr). Or may be it comes from DHCP and now is
192.168.2.6?

	Can you start 'ip monitor' in one console while
attaching the USB device, so that we can know if any IP
addresses are reconfigured due to some events. For example,
script that restarts DHCP.

Regards

--
Julian Anastasov <ja@ssi.bg>

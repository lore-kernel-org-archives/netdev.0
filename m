From: "Gabriele Beltrame" <belgab@drvsource.net>
Subject: RE: Random packet loss using IPsec with AES128-SHA1
Date: Thu, 17 Dec 2015 16:36:06 +0100
Message-ID: <005901d138e0$a6a7a750$f3f6f5f0$@drvsource.net>
References: <000a01d137e2$afedd130$0fc97390$@drvsource.net> <20151216095954.GN29565@gauss.secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: "'Steffen Klassert'" <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ip209.psaruba.com ([94.23.150.209]:35641 "EHLO webs.psaruba.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751420AbbLQPgK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 10:36:10 -0500
In-Reply-To: <20151216095954.GN29565@gauss.secunet.com>
Content-Language: it
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Steffen,

I don't think it's IPsec (I can see the outbound packet in tcpdump), no=
t
alone at least but the XEN /AWS Ethernet driver (or multiple things
concurring to the issue) actually... the odd thing is that it does seem=
 to
affect AES-CBS only (3DES-CBS, AES-GCM are fine)
This is the short discussion on the Strongswan support wiki:
https://wiki.strongswan.org/issues/1220

Thanks,
Gabriele

-----Original Message-----
=46rom: Steffen Klassert [mailto:steffen.klassert@secunet.com]=20
Sent: mercoled=EC 16 dicembre 2015 11:00
To: Gabriele Beltrame <belgab@drvsource.net>
Cc: netdev@vger.kernel.org
Subject: Re: Random packet loss using IPsec with AES128-SHA1

On Wed, Dec 16, 2015 at 10:17:54AM +0100, Gabriele Beltrame wrote:
> Hi,
>=20
> I'm running a few Strongswan 5.3.* CentOS (Kernel 3.16.7, 4.2.6,=20
> 4.1.*) instances on AWS to terminate VPNs between each other and/or t=
o=20
> other devices across the Internet.
> While investigating some application issues, I've noticed that on=20
> every VPNs I have random packet losses (from 1% to 4% over 100 to 300
requests sent).
> This only happens when the two following conditions are met: (a) AES=20
> encryption used, (b) IP packet size shorter than about (150+8+20)Byte=
s.

I've never seen this.

If xfrm statistics are compiled in, a counter is bumped for each packet
dropped by IPsec. You can check these counters in /proc/net/xfrm_stat.

This will tell you at least whether IPsec is the reason for your packet
loss.


---
This email has been checked for viruses by Avast antivirus software.
https://www.avast.com/antivirus

From: Aurelien Jarno <aurelien@aurel32.net>
Subject: Re: [PATCH] SSB PCI core driver fixes
Date: Thu, 09 Aug 2007 02:38:24 +0200
Message-ID: <46BA6200.4060306@aurel32.net>
References: <20070809002353.GA4594@hall.aurel32.net> <200708090227.06510.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hall.aurel32.net ([88.191.38.19]:47613 "EHLO hall.aurel32.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754175AbXHIB0S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Aug 2007 21:26:18 -0400
In-Reply-To: <200708090227.06510.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch a =E9crit :
> On Thursday 09 August 2007, Aurelien Jarno wrote:
>>  - Add some delay between the configuration of the PCI controller=20
>>    and its registration.
>=20
> Why? It is _huge_ and people won't like it ;)
> At least add a comment why this is needed.

It is need, otherwise the PCI controller gets confused, which causes a
reset of the machine. Then CFE goes into a loop booting again and again
without being able to get up to the prompt.

I agree this is a huge value, so I will try to find the minimum value
and then add some margin.

I will send an updated patch.

>> @@ -340,6 +345,7 @@
>>  	 * The following needs change, if we want to port hostmode
>>  	 * to non-MIPS platform. */
>>  	set_io_port_base((unsigned long)ioremap_nocache(SSB_PCI_MEM, 0x040=
00000));
>> +	mdelay(300);
>>  	register_pci_controller(&ssb_pcicore_controller);
>>  }
>>
>=20
>=20
>=20


--=20
  .''`.  Aurelien Jarno	            | GPG: 1024D/F1BCDB73
 : :' :  Debian developer           | Electrical Engineer
 `. `'   aurel32@debian.org         | aurelien@aurel32.net
   `-    people.debian.org/~aurel32 | www.aurel32.net

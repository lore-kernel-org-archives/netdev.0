From: =?ISO-8859-1?Q?Andr=E9_Detsch?= <adetsch@br.ibm.com>
Subject: Re: [E1000-devel] [PATCH] Fix link test for e1000 and e1000e when
 iface is down
Date: Fri, 13 Feb 2009 10:08:38 -0200
Message-ID: <499562C6.3060001@br.ibm.com>
References: <200902101435.58331.adetsch@br.ibm.com> <9929d2390902121710q681f7143i16b5c98001279cc1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp02.br.ibm.com ([32.104.18.86]:44083 "EHLO
	e24smtp02.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752114AbZBMMIv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2009 07:08:51 -0500
Received: from d24relay01.br.ibm.com (d24relay01.br.ibm.com [9.8.31.16])
	by e24smtp02.br.ibm.com (8.13.1/8.13.1) with ESMTP id n1DCHN2Q009753
	for <netdev@vger.kernel.org>; Fri, 13 Feb 2009 10:17:23 -0200
Received: from d24av02.br.ibm.com (d24av02.br.ibm.com [9.18.232.47])
	by d24relay01.br.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n1DD8AQx3579992
	for <netdev@vger.kernel.org>; Fri, 13 Feb 2009 10:08:12 -0300
Received: from d24av02.br.ibm.com (loopback [127.0.0.1])
	by d24av02.br.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n1DC8hTx000470
	for <netdev@vger.kernel.org>; Fri, 13 Feb 2009 10:08:44 -0200
In-Reply-To: <9929d2390902121710q681f7143i16b5c98001279cc1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher wrote:
> I guess this comes down to what the definition of a Link test should
> be doing.  My $0.02 is that it should be testing if the interface has
> a link, in which case if you ifdown the interface before running the
> Link test, I would expect it to fail.
>=20
> With this patch, if you bring down the device and run the ethtool dia=
g
> tests, the Link test would come back as passing which is something I
> would not expect.

With the current code, e1000_reset is called during the test anyway, so=
=20
ethtool -t fails only the first time it is run (after ifconfig down). I=
s that=20
the expected behavior for the test?


# ifconfig eth0 up; ifconfig eth0 down; ethtool -t eth0

The test result is FAIL
The test extra info:
Register test  (offline)         0
Eeprom test    (offline)         0
Interrupt test (offline)         0
Loopback test  (offline)         0
Link test   (on/offline)         1


# ethtool -t eth0

The test result is PASS
The test extra info:
Register test  (offline)         0
Eeprom test    (offline)         0
Interrupt test (offline)         0
Loopback test  (offline)         0
Link test   (on/offline)         0


Thanks for the feedback.

--=20
Andr=E9 Detsch
Kernel Software Engineer
Linux Technology Center Brazil

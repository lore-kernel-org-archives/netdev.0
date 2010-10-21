From: Debashis Dutt <ddutt@Brocade.COM>
Subject: RE: Question w.r.t debugfs / netdevice pass-through IOCTL
Date: Thu, 21 Oct 2010 13:29:59 -0700
Message-ID: <F363E7AC84E1B646A0358B281A46F4AEABA0FFCFFC@HQ1-EXCH03.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:60142 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756740Ab0JUUaB convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Oct 2010 16:30:01 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



----Original Message-----
=46rom: Stephen Hemminger [mailto:shemminger@vyatta.com]=20
Sent: Wednesday, October 20, 2010 9:19 PM
To: Debashis Dutt
Cc: netdev@vger.kernel.org
Subject: Re: Question w.r.t debugfs / netdevice pass-through IOCTL

On Wed, 20 Oct 2010 20:26:50 -0700
Debashis Dutt <ddutt@Brocade.COM> wrote:

> Hi,=20
>=20
> For the Brocade 10G Ethernet driver (bna) we want to implement a set =
of operations which is not supported by current tools like ethtool.=20
>=20
> Examples of such operations would be=20
> =A0=A0=A0=A0=A0=A0 a) Queries related to CEE, if the link is CEE.
> =A0=A0=A0=A0=A0=A0 b) Get traces from firmware.

>=20
> I was wondering what would be right approach to take here:
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 a) use debugfs (like th=
e Chelsio cxgb4 driver)
Works as long as they are really debug operations. The debugfs isn't al=
ways
available, and support should be a config option for your driver.

> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 b) use SIOCDEVPRIVATE f=
or the pass through IOCTL defined in
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0 struct net_de=
vice_ops{}

The problem with ioctl is it doesn't work for 32 bit user space
compatiablity. The ioctl compat layer does not have enough context
to translate SIOCDEVPRIVATE

> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0 As per commen=
ts in the header file, b) should not be used
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0 since this IO=
CTL is supposed to be deprecated.
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 c) use procfs / sysfs (=
these may not scale, in our opinion)

Although less common, there were drivers putting things in /proc/net/xx=
x/ethX


Thanks Stephen for the suggestions.

--Debashis
--=20

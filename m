From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net-next v6 0/3] The huawei_cdc_ncm driver / E3276 problem
Date: Fri, 14 Mar 2014 09:58:43 +0100
Message-ID: <87siqlnol8.fsf@nemi.mork.no>
References: <1383555049-24834-1-git-send-email-bjorn@mork.no>
	<20140313202557.GV3200@reaktio.net>
	<1394746907.15946.8.camel@dcbw.local>
	<20140313220812.GW3200@reaktio.net>
	<20140314075548.GX3200@reaktio.net> <87wqfxnppc.fsf@nemi.mork.no>
	<20140314084159.GA3200@reaktio.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dan Williams <dcbw@redhat.com>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Enrico Mioso <mrkiko.rs@gmail.com>,
	Oliver Neukum <oliver@neukum.org>
To: Pasi =?utf-8?B?S8Okcmtrw6RpbmVu?= <pasik@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:48150 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755476AbaCNI7D convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 04:59:03 -0400
In-Reply-To: <20140314084159.GA3200@reaktio.net> ("Pasi =?utf-8?Q?K=C3=A4r?=
 =?utf-8?Q?kk=C3=A4inen=22's?= message
	of "Fri, 14 Mar 2014 10:41:59 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pasi K=C3=A4rkk=C3=A4inen <pasik@iki.fi> writes:

> ^NDISSTAT:1,,,"IPV4"
> ^RSSI: 21
>
> <I send: AT^DHCP?>
> ^DHCP: CCDB080A,F8FFFFFF,C9DB080A,C9DB080A,E67B59C0,E77B59C0,85600,85=
600


The hex numbers are IPv4 addresses in little endian. The decimal number=
s
at the end are speed down/up IIRC.

Printed in a more readable form, this is:

 10.8.219.204,255.255.255.248,10.8.219.201,10.8.219.201,192.89.123.230,=
192.89.123.231,85600,85600

I believe this is to be interpreted as

 yourip, netmask, gw, gw?, dns1, dns2


Do stuff work if you manually configure the interface with the
10.8.219.204 address and set the default route to 10.8.219.201?

This is one way to rewrite the addresses if you need to for a new
connection:

 perl -e 'print join(".", reverse map {hex} unpack("(A2)*", shift)),"\n=
"' C9DB080A



Bj=C3=B8rn

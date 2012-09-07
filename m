From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: MBIM
Date: Fri, 07 Sep 2012 10:53:02 +0200
Message-ID: <87392u1afl.fsf@nemi.mork.no>
References: <2791550.LhGu6po6Xy@linux-lqwf.site> <87ehmf36qd.fsf@nemi.mork.no>
	<3121990.L41g6gGrVV@linux-lqwf.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: alexey.orishko@stericsson.com, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: Oliver Neukum <oneukum@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:36571 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753066Ab2IGIxM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Sep 2012 04:53:12 -0400
In-Reply-To: <3121990.L41g6gGrVV@linux-lqwf.site> (Oliver Neukum's message of
	"Fri, 07 Sep 2012 09:40:59 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Neukum <oneukum@suse.de> writes:
> On Thursday 06 September 2012 10:17:46 Bj=C3=B8rn Mork wrote:
>> Not really related, but I am still worrying how MBIM is going to fit
>> into the usbnet model where you have a strict relation between one
>> netdev and one USB interface.  Do you see any way usbnet could be
>> extended to manage a list of netdevs?
>>=20
>> All the netdev related functions doing
>>=20
>>         struct usbnet           *dev =3D netdev_priv(net);
>>=20
>> would still work.  But all the USB related functions using dev->net =
to
>> get the netdev would fail.  Maybe this will be too difficult to
>> implement within the usbnet framework at all?
>
> It depends on how much support we get from upper layers.
> You can give two IPs to an ethernet card as well.

Yes, of course.  But I don't think that fits the MBIM model, where
multiple independent connections (Internet, VoIP, MMS, VPN1, VPN2, etc)
to different APNs will be multiplexed over the same USB endpoints.  And
to make this not fly at all: Some of these may be IPv4, some IPv6 and
some dual stack.  You cannot support that on a single netdev.  Mixing
them all together on the host will not do.  When the driver sees an IPv=
6
multicast packet (RS, ND, whatever) on the netdev, which MBIM session
should it forward that packet too?

If I understand MBIM correctly, we will see device configurations with
_one_ CDC data interface carrying all data traffic for multiple device
functions.  A MBIM driver must de-multiplex this, and each IP function
should be routed to its own netdev IMHO.

> It would be best if you could come up with some preliminary code
> at least.

Yup.  Finally got a device.  Will start playing.


Bj=C3=B8rn

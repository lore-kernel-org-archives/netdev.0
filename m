From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] CDC_NCM adding support IFF_NOARP for infineon modem platform
Date: Tue, 15 Jan 2013 09:34:07 +0100
Message-ID: <87hamikfpc.fsf@nemi.mork.no>
References: <1357990479-5836-1-git-send-email-cpuwolf@gmail.com>
	<20130112.153533.1713284383322153346.davem@davemloft.net>
	<1358183953.1713.28.camel@dcbw.foobar.com>
	<20130114.133412.479351928049237212.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dcbw@redhat.com, cpuwolf@gmail.com, gregkh@linuxfoundation.org,
	alexey.orishko@stericsson.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:59412 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755158Ab3AOIe0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2013 03:34:26 -0500
In-Reply-To: <20130114.133412.479351928049237212.davem@davemloft.net> (David
	Miller's message of "Mon, 14 Jan 2013 13:34:12 -0500 (EST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:
> From: Dan Williams <dcbw@redhat.com>
>=20
>> IFF_NOARP is already done for other WWAN devices (sierra_net, hso,
>> cdc-ether, cdc-phonet, lg-vl600, etc) so there is some precedent.  S=
ome
>> drivers (phonet, hso) set *both* POINTTOPOINT and NOARP.  Is that
>> redundant, and should all WWAN drivers be moved to only POINTTOPOINT=
?
>>=20
>> (aside: usbnet has FLAG_POINTTOPOINT, but that's nothing to do with
>> IFF_POINTTOPOINT, it only controls whether the interface is named us=
bX
>> or ethX.  Confusing.)
>
> I can't answer any of your questions unless you tell me what the
> real limitation of these devices is.
>
> For the second time, is the problem that these devices cannot
> support broadcast packets properly?

The main problem is that these devices don't support ethernet.  They
support IP (v4 and _maybe_ v6) with an ethernet header.  Many of them
will do ARP (and IPv6 ND) as well to complete the picture, but some of
them don't and that's what these drivers try to deal with.

Note that most of the devices will run a DHCP server, so there is some
sort of IP broadcast support.  Whether that qualifies as proper etherne=
t
broadcast support is another question...

These devices are attempting to bridge an IP-only point-to-point
interface and an ethernet over USB interface, with the intention to mak=
e
the point-to-point interface look like ethernet to applications and
users. This is of course always going to be imperfect.  But I believe
that we should aim to help the firmware achive this goal when writing
drivers instead of working against it.  Setting IFF_NOARP and not
IFF_POINTTOPOINT is one way to do that.



Bj=C3=B8rn

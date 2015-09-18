From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH net 2/2]  8139cp: reset BQL when ring tx ring cleared
Date: Fri, 18 Sep 2015 02:04:36 +0100
Message-ID: <1442538276.97487.21.camel@infradead.org>
References: <20130520095443.2d18b2cb@nehalam.linuxnetplumber.net>
	 <20130520213728.GA28252@electric-eye.fr.zoreil.com>
	 <20130520172749.2a4447b6@nehalam.linuxnetplumber.net>
	 <1442232308.30875.6.camel@infradead.org>
	 <20150914215913.GA24962@electric-eye.fr.zoreil.com>
	 <1442489793.131189.142.camel@infradead.org>
	 <1442502391.131189.160.camel@infradead.org>
	 <20150917204449.GA22105@electric-eye.fr.zoreil.com>
	 <1442528065.97487.6.camel@infradead.org>
	 <20150917234449.GA25782@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="sha-1"; protocol="application/x-pkcs7-signature";
	boundary="=-vy6G6re9lqrEyld9CeOK"
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:38882 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752043AbbIRBEn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 21:04:43 -0400
In-Reply-To: <20150917234449.GA25782@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-vy6G6re9lqrEyld9CeOK
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2015-09-18 at 01:44 +0200, Francois Romieu wrote:
> The TxDmaOkLowDesc register may tell if the Tx dma part is still=20
> making any progress. I have added a TxPoll request. See below.

I've just added that into the original TX timeout handler, since that
doesn't seem to be crashing the box for me as long as I avoid the IRQ
storm.

Not sure what we learn from it ('desc 6550' printed as hex)... I've
also made it dump the TX descriptor ring (skb, addr, opts1, opts2):

[ 1733.027156] 8139cp 0000:00:0b.0 eth1: Transmit timeout, status  c   2b h=
ead 25 tail 22 desc 6550    0 80ff
[ 1733.036819] TX ring 00:   (null) 1dd68d8c 3000cb67 0                    =
    =20
[ 1733.037040] TX ring 01:   (null) 1dd8774c 3000cb67 0                    =
    =20
[ 1733.037040] TX ring 02:   (null) 1dd86e7c 30000a08 0                    =
    =20
[ 1733.037040] TX ring 03:   (null) 1dd865ac 30000a08 0                    =
    =20
[ 1733.037040] TX ring 04:   (null) 1dd8540c 30000a08 0                    =
    =20
[ 1733.037040] TX ring 05:   (null) 1dd85cdc 30000a08 0                    =
    =20
[ 1733.037040] TX ring 06:   (null) 1dd84b3c 30000a08 0                    =
    =20
[ 1733.037040] TX ring 07:   (null) 1dd8399c 30000a08 0                    =
    =20
[ 1733.037040] TX ring 08:   (null) 1dd8426c 30000a08 0                    =
    =20
[ 1733.037040] TX ring 09:   (null) 1dd830cc 30000a08 0                    =
    =20
[ 1733.037040] TX ring 10:   (null) 1dd81f2c 30000a08 0                    =
    =20
[ 1733.037040] TX ring 11:   (null) 1dd8165c 30000a08 0                    =
    =20
[ 1733.037040] TX ring 12:   (null) 1dd827fc 30000a08 0                    =
    =20
[ 1733.037040] TX ring 13:   (null) 1dd80d8c 30000a08 0                    =
    =20
[ 1733.037040] TX ring 14:   (null) 1dd804bc 30000a08 0                    =
    =20
[ 1733.037040] TX ring 15:   (null) 1dd6ee7c 30000a08 0                    =
    =20
[ 1733.037040] TX ring 16:   (null) 1dd6f74c 30000a08 0                    =
    =20
[ 1733.037040] TX ring 17:   (null) 1dd6e5ac 30000a08 0                    =
    =20
[ 1733.037040] TX ring 18:   (null) 1dd6dcdc 30000a08 0                    =
    =20
[ 1733.037040] TX ring 19:   (null) 1dd6cb3c 3000f804 0                    =
    =20
[ 1733.037040] TX ring 20:   (null) 1dd8de02 300083da 0                    =
    =20
[ 1733.037040] TX ring 21:   (null) 1dd8da02 30000000 0                    =
    =20
[ 1733.037040] TX ring 22: defcc240 1dd6d40c b00005ea 0                    =
    =20
[ 1733.037040] TX ring 23: decdb900 1dd6b99c b0000046 0                    =
    =20
[ 1733.037040] TX ring 24: ddd27c00 1dd6b0cc b00005ea 0                    =
    =20
[ 1733.037040] TX ring 25:   (null) 1dd6e5ac 3000ca24 0                    =
    =20
[ 1733.037040] TX ring 26:   (null) 1dd6dcdc 3000ca24 0                    =
    =20
[ 1733.037040] TX ring 27:   (null) 1dd6d40c 3000ca24 0                    =
    =20
[ 1733.037040] TX ring 28:   (null) 1dd6cb3c 3000ca24 0                    =
    =20
[ 1733.037040] TX ring 29:   (null) 1dd6c26c 3000ca24 0                    =
    =20
[ 1733.037040] TX ring 30:   (null) 1dd6b99c 3000ca24 0                    =
    =20
[ 1733.037040] TX ring 31:   (null) 1dd6b0cc 3000ca24 0                    =
    =20
[ 1733.037040] TX ring 32:   (null) 1dd6a7fc 3000ca24 0                    =
    =20
[ 1733.037040] TX ring 33:   (null) 1dd69f2c 3000ca24 0                    =
    =20
[ 1733.037040] TX ring 34:   (null) 1dd68d8c 3000ca24 0                    =
    =20
[ 1733.037040] TX ring 35:   (null) 1dd6965c 3000cb67 0                    =
    =20
[ 1733.037040] TX ring 36:   (null) 1dd684bc 3000cb67 0                    =
    =20
[ 1733.037040] TX ring 37:   (null) 1dd86e7c 3000cb67 0                    =
    =20
[ 1733.037040] TX ring 38:   (null) 1dd8774c 3000cb67 0                    =
    =20
[ 1733.037040] TX ring 39:   (null) 1dd865ac 3000cb67 0                    =
    =20
[ 1733.037040] TX ring 40:   (null) 1dd85cdc 3000cb67 0                    =
    =20
[ 1733.037040] TX ring 41:   (null) 1dd8540c 3000cb67 0                    =
    =20
[ 1733.037040] TX ring 42:   (null) 1dd84b3c 3000cb67 0                    =
    =20
[ 1733.037040] TX ring 43:   (null) 1dd8426c 3000cb67 0                    =
    =20
[ 1733.037040] TX ring 44:   (null) 1dd8399c 3000cb67 0                    =
    =20
[ 1733.037040] TX ring 45:   (null) 1dd830cc 3000cb67 0                    =
    =20
[ 1733.037040] TX ring 46:   (null) 1dd81f2c 3000cb67 0                    =
    =20
[ 1733.037040] TX ring 47:   (null) 1dd827fc 3000cb67 0                    =
    =20
[ 1733.037040] TX ring 48:   (null) 1dd8165c 3000cb67 0                    =
    =20
[ 1733.037040] TX ring 49:   (null) 1dd80d8c 3000cb67 0                    =
    =20
[ 1733.037040] TX ring 50:   (null) 1dd804bc 3000cb67 0                    =
    =20
[ 1733.037040] TX ring 51:   (null) 1dd6f74c 3000cb67 0                    =
    =20
[ 1733.037040] TX ring 52:   (null) 1dd6ee7c 3000cb67 0                    =
    =20
[ 1733.037040] TX ring 53:   (null) 1dd6dcdc 3000cb67 0                    =
    =20
[ 1733.037040] TX ring 54:   (null) 1dd6d40c 3000cb67 0                    =
    =20
[ 1733.037040] TX ring 55:   (null) 1dd6e5ac 3000cb67 0                    =
    =20
[ 1733.037040] TX ring 56:   (null) 1dd6cb3c 3000cb67 0                    =
    =20
[ 1733.037040] TX ring 57:   (null) 1dd6c26c 3000cb67 0                    =
    =20
[ 1733.037040] TX ring 58:   (null) 1dd6b99c 3000cb67 0                    =
    =20
[ 1733.037040] TX ring 59:   (null) 1dd6b0cc 3000cb67 0                    =
    =20
[ 1733.037040] TX ring 60:   (null) 1dd6a7fc 3000cb67 0                    =
    =20
[ 1733.037040] TX ring 61:   (null) 1dd69f2c 3000cb67 0                    =
    =20
[ 1733.037040] TX ring 62:   (null) 1dd6965c 3000cb67 0                    =
    =20
[ 1733.037040] TX ring 63:   (null) 1dd684bc 7000cb67 0          =20


And another time...
[ 3436.024610] 8139cp 0000:00:0b.0 eth1: Transmit timeout, status  c   2b h=
ead 6 tail 1 desc 1400    0 80ff                                           =
         =20
[ 3436.034101] TX ring 00:   (null) 1dc4dcdc 30000888 0                    =
    =20
[ 3436.034494] TX ring 01: deffff00 1dc64e02 b000006a 0                    =
    =20
[ 3436.034494] TX ring 02: ddc35180 1dc4d40c b0000036 0                    =
    =20
[ 3436.034494] TX ring 03: ddc35480 1dc4cb3c b0000036 0                    =
    =20
[ 3436.034494] TX ring 04: defff780 1dc4b99c b0000249 0                    =
    =20
[ 3436.034494] TX ring 05: defff900 1dc4c26c b00005ea 0                    =
    =20
[ 3436.034494] TX ring 06:   (null) 1dc64e02 30003c30 0                    =
    =20
[ 3436.034494] TX ring 07:   (null) 1dc5165c 30003c30 0                    =
    =20
[ 3436.034494] TX ring 08:   (null) 1dc64e02 30000000 0                    =
    =20
[ 3436.034494] TX ring 09:   (null) 1dc64e0a 30000000 0                    =
    =20
[ 3436.034494] TX ring 10:   (null) 1dc504bc 30000000 0                    =
    =20
[ 3436.034494] TX ring 11:   (null) 1dc64e0a 30000000 0                    =
    =20
[ 3436.034494] TX ring 12:   (null) 1dc64e02 30004881 0                    =
    =20
[ 3436.034494] TX ring 13:   (null) 1dc64e0a 3000fb66 0                    =
    =20
[ 3436.034494] TX ring 14:   (null) 1dc64e02 3000c031 0                    =
    =20
[ 3436.034494] TX ring 15:   (null) 1dc64e02 3000c031 0                    =
    =20
[ 3436.034494] TX ring 16:   (null) 1dc64e0a 30000100 0                    =
    =20
[ 3436.034494] TX ring 17:   (null) 1dc64e0a 3000a684 0                    =
    =20
[ 3436.034494] TX ring 18:   (null) 1dc50d8c 30000100 0                    =
    =20
[ 3436.034494] TX ring 19:   (null) 1dc5f74c 30000100 0                    =
    =20
[ 3436.034494] TX ring 20:   (null) 1dc64e02 30000100 0                    =
    =20
[ 3436.034494] TX ring 21:   (null) 1dc64e02 30000327 0                    =
    =20
[ 3436.034494] TX ring 22:   (null) 1dc64e02 30002100 0                    =
    =20
[ 3436.034494] TX ring 23:   (null) 1dc64e0a 3000bd84 0                    =
    =20
[ 3436.034494] TX ring 24:   (null) 1dc64e0a 30000000 0                    =
    =20
[ 3436.034494] TX ring 25:   (null) 1dc64e0a 30000000 0                    =
    =20
[ 3436.034494] TX ring 26:   (null) 1dc64e02 30004881 0                    =
    =20
[ 3436.034494] TX ring 27:   (null) 1dc64e0a 30000a00 0                    =
    =20
[ 3436.034494] TX ring 28:   (null) 1dc64e02 30000a00 0                    =
    =20
[ 3436.034494] TX ring 29:   (null) 1dc64e0a 3000ed83 0                    =
    =20
[ 3436.034494] TX ring 30:   (null) 1dc64e02 30009600 0                    =
    =20
[ 3436.034494] TX ring 31:   (null) 1dc64e0a 30001b98 0                    =
    =20
[ 3436.034494] TX ring 32:   (null) 1dc64e02 30000008 0                    =
    =20
[ 3436.034494] TX ring 33:   (null) 1dc64e0a 30000000 0                    =
    =20
[ 3436.034494] TX ring 34:   (null) 1dc64e02 3000dd86 0                    =
    =20
[ 3436.034494] TX ring 35:   (null) 1dc64e0a 30000000 0                    =
    =20
[ 3436.034494] TX ring 36:   (null) 1dc64e02 30000000 0                    =
    =20
[ 3436.034494] TX ring 37:   (null) 1dc64e0a 30000000 0                    =
    =20
[ 3436.034494] TX ring 38:   (null) 1dc64e02 3000b963 0                    =
    =20
[ 3436.034494] TX ring 39:   (null) 1dc64e0a 30000100 0                    =
    =20
[ 3436.034494] TX ring 40:   (null) 1dc64e02 3000b263 0                    =
    =20
[ 3436.034494] TX ring 41:   (null) 1dc64e0a 3000b008 0                    =
    =20
[ 3436.034494] TX ring 42:   (null) 1dc64e02 30000000 0                    =
    =20
[ 3436.034494] TX ring 43:   (null) 1dc64e0a 30004011 0                    =
    =20
[ 3436.034494] TX ring 44:   (null) 1dc64e02 30000000 0                    =
    =20
[ 3436.034494] TX ring 45:   (null) 1dc64e0a 30004011 0                    =
    =20
[ 3436.034494] TX ring 46:   (null) 1dc64e02 30000000 0                    =
    =20
[ 3436.034494] TX ring 47:   (null) 1dc64e0a 30004011 0                    =
    =20
[ 3436.034494] TX ring 48:   (null) 1dc5e5ac 30005f06 0                    =
    =20
[ 3436.034494] TX ring 49:   (null) 1dc5ee7c 30002fc0 0                    =
    =20
[ 3436.034494] TX ring 50:   (null) 1dc5dcdc 3000b008 0                    =
    =20
[ 3436.034494] TX ring 51:   (null) 1dc5d40c 30006364 0                    =
    =20
[ 3436.034494] TX ring 52:   (null) 1dc5cb3c 30006364 0                    =
    =20
[ 3436.034494] TX ring 53:   (null) 1dc5c26c 30000300 0                    =
    =20
[ 3436.034494] TX ring 54:   (null) 1dc5b99c 30000300 0                    =
    =20
[ 3436.034494] TX ring 55:   (null) 1dc5b0cc 30003500 0                    =
    =20
[ 3436.034494] TX ring 56:   (null) 1dc64e02 30000888 0                    =
    =20
[ 3436.034494] TX ring 57:   (null) 1dc5a7fc 3000f1d3 0                    =
    =20
[ 3436.034494] TX ring 58:   (null) 1dc59f2c 3000f1d3 0                    =
    =20
[ 3436.034494] TX ring 59:   (null) 1dc5965c 3000f1d3 0                    =
    =20
[ 3436.034494] TX ring 60:   (null) 1dc58d8c 3000f1d3 0                    =
    =20
[ 3436.034494] TX ring 61:   (null) 1dc4f74c 30002e33 0                    =
    =20
[ 3436.034494] TX ring 62:   (null) 1dc4ee7c 30002e33 0                    =
    =20
[ 3436.034494] TX ring 63:   (null) 1dc4e5ac 70000888 0                    =
    =20

... and another (without all the extra debugging, and without the
WARN_ON, it does seem to survive without triggering the IRQ storm)

[ 3551.027167] 8139cp 0000:00:0b.0 eth1: Transmit timeout, status  c   2b h=
ead 19 tail 16 desc 14f0    0 80ff                                         =
        =20
[ 3551.036837] TX ring 00:   (null) 1dce04bc 30000000 0                    =
    =20
[ 3551.037058] TX ring 01:   (null) 1dce0d8c 30000000 0                    =
    =20
[ 3551.037058] TX ring 02:   (null) 1dd6f74c 30000b66 0                    =
    =20
[ 3551.037058] TX ring 03:   (null) 1dd6ee7c 30000b66 0                    =
    =20
[ 3551.037058] TX ring 04:   (null) 1dd6e5ac 30000b66 0                    =
    =20
[ 3551.037058] TX ring 05:   (null) 1dd6d40c 30000b66 0                    =
    =20
[ 3551.037058] TX ring 06:   (null) 1dd6dcdc 30000b66 0                    =
    =20
[ 3551.037058] TX ring 07:   (null) 1dd6c26c 30000000 0                    =
    =20
[ 3551.037058] TX ring 08:   (null) 1dd6cb3c 30000000 0                    =
    =20
[ 3551.037058] TX ring 09:   (null) 1dd6b99c 3000f804 0                    =
    =20
[ 3551.037058] TX ring 10:   (null) 1dd6b0cc 30001105 0                    =
    =20
[ 3551.037058] TX ring 11:   (null) 1dd6a7fc 30001105 0                    =
    =20
[ 3551.037058] TX ring 12:   (null) 1dd69f2c 30001105 0                    =
    =20
[ 3551.037058] TX ring 13:   (null) 1dd6965c 3000493b 0                    =
    =20
[ 3551.037058] TX ring 14:   (null) 1dd68d8c 3000cea5 0                    =
    =20
[ 3551.037058] TX ring 15:   (null) 1dc4f74c 30001b55 0                    =
    =20
[ 3551.037058] TX ring 16: ddd2f9c0 1dd684bc b00005ea 0                    =
    =20
[ 3551.037058] TX ring 17: defc76c0 1dc4e5ac b00005ea 0                    =
    =20
[ 3551.037058] TX ring 18: ddd38300 1dc4ee7c b00005ea 0                    =
    =20
[ 3551.037058] TX ring 19:   (null) 1dc49f2c 3000b838 0                    =
    =20
[ 3551.037058] TX ring 20:   (null) 1dc48d8c 300035ae 0                    =
    =20
[ 3551.037058] TX ring 21:   (null) 1dc4965c 300035ae 0                    =
    =20
[ 3551.037058] TX ring 22:   (null) 1dc484bc 300085b9 0                    =
    =20
[ 3551.037058] TX ring 23:   (null) 2774c 300085b9 0                       =
    =20
[ 3551.037058] TX ring 24:   (null) 26e7c 300085b9 0                       =
    =20
[ 3551.037058] TX ring 25:   (null) 25cdc 3000d5c4 0                       =
    =20
[ 3551.037058] TX ring 26:   (null) 1dc1fe02 300025d0 0                    =
    =20
[ 3551.037058] TX ring 27:   (null) 265ac 300025d0 0                       =
    =20
[ 3551.037058] TX ring 28:   (null) 2540c 3000b838 0                       =
    =20
[ 3551.037058] TX ring 29:   (null) 2426c 3000b838 0                       =
    =20
[ 3551.037058] TX ring 30:   (null) 24b3c 3000b838 0                       =
    =20
[ 3551.037058] TX ring 31:   (null) 2399c 3000b838 0                       =
    =20
[ 3551.037058] TX ring 32:   (null) 230cc 3000b838 0                       =
    =20
[ 3551.037058] TX ring 33:   (null) 227fc 30000040 0                       =
    =20
[ 3551.037058] TX ring 34:   (null) 21f2c 30000040 0                       =
    =20
[ 3551.037058] TX ring 35:   (null) 2165c 30000040 0                       =
    =20
[ 3551.037058] TX ring 36:   (null) 204bc 3000b838 0                       =
    =20
[ 3551.037058] TX ring 37:   (null) 20d8c 3000b838 0                       =
    =20
[ 3551.037058] TX ring 38:   (null) 1dc4f74c 3000b838 0                    =
    =20
[ 3551.037058] TX ring 39:   (null) 1dc4ee7c 3000b838 0                    =
    =20
[ 3551.037058] TX ring 40:   (null) 1dc4dcdc 3000b838 0                    =
    =20
[ 3551.037058] TX ring 41:   (null) 1dc4d40c 3000b838 0                    =
    =20
[ 3551.037058] TX ring 42:   (null) 1dc4e5ac 3000b838 0                    =
    =20
[ 3551.037058] TX ring 43:   (null) 1dc4c26c 3000b838 0                    =
    =20
[ 3551.037058] TX ring 44:   (null) 1dc4b99c 3000b838 0                    =
    =20
[ 3551.037058] TX ring 45:   (null) 1dc4cb3c 3000b838 0                    =
    =20
[ 3551.037058] TX ring 46:   (null) 1dc4b0cc 30000008 0                    =
    =20
[ 3551.037058] TX ring 47:   (null) 1dc4a7fc 30000008 0                    =
    =20
[ 3551.037058] TX ring 48:   (null) 1dc49f2c 30000008 0                    =
    =20
[ 3551.037058] TX ring 49:   (null) 1dc48d8c 30000a00 0                    =
    =20
[ 3551.037058] TX ring 50:   (null) 1dc4965c 30000a00 0                    =
    =20
[ 3551.037058] TX ring 51:   (null) 1dc484bc 30000a00 0                    =
    =20
[ 3551.037058] TX ring 52:   (null) 1dce774c 30000a00 0                    =
    =20
[ 3551.037058] TX ring 53:   (null) 1dce6e7c 30000a00 0                    =
    =20
[ 3551.037058] TX ring 54:   (null) 1dce5cdc 30000a00 0                    =
    =20
[ 3551.037058] TX ring 55:   (null) 1dce65ac 30000000 0                    =
    =20
[ 3551.037058] TX ring 56:   (null) 1dce540c 30000000 0                    =
    =20
[ 3551.037058] TX ring 57:   (null) 1dce426c 30000a66 0                    =
    =20
[ 3551.037058] TX ring 58:   (null) 1dce4b3c 30000a66 0                    =
    =20
[ 3551.037058] TX ring 59:   (null) 1dce399c 30000a66 0                    =
    =20
[ 3551.037058] TX ring 60:   (null) 1dce30cc 30000a66 0                    =
    =20
[ 3551.037058] TX ring 61:   (null) 1dce27fc 30000000 0                    =
    =20
[ 3551.037058] TX ring 62:   (null) 1dce165c 30000000 0                    =
    =20
[ 3551.037058] TX ring 63:   (null) 1dce1f2c 70000000 0                    =
    =20



--=20
dwmw2


--=-vy6G6re9lqrEyld9CeOK
Content-Type: application/x-pkcs7-signature; name="smime.p7s"
Content-Disposition: attachment; filename="smime.p7s"
Content-Transfer-Encoding: base64

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIISjjCCBicw
ggUPoAMCAQICAw3vNzANBgkqhkiG9w0BAQUFADCBjDELMAkGA1UEBhMCSUwxFjAUBgNVBAoTDVN0
YXJ0Q29tIEx0ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRlIFNpZ25pbmcx
ODA2BgNVBAMTL1N0YXJ0Q29tIENsYXNzIDEgUHJpbWFyeSBJbnRlcm1lZGlhdGUgQ2xpZW50IENB
MB4XDTE1MDUwNTA5NDM0MVoXDTE2MDUwNTA5NTMzNlowQjEcMBoGA1UEAwwTZHdtdzJAaW5mcmFk
ZWFkLm9yZzEiMCAGCSqGSIb3DQEJARYTZHdtdzJAaW5mcmFkZWFkLm9yZzCCASIwDQYJKoZIhvcN
AQEBBQADggEPADCCAQoCggEBAMkbm9kPbx1j/X4RVyf/pPKSYwelcco69TvnQQbKM8m8xkWjXJI1
jpJ1jMaGUZGFToINMSZi7lZawUozudWbXSKy1SikENSTJHffsdRAIlsp+hR8vWvjsKUry6sEdqPG
doa5RY7+N4WRusWZDYW/RRWE6i9EL9qV86CVPYqw22UBOUw4/j/HVGCV6TSB8yE5iEwhk/hUuzRr
FZm1MJMR7mCS7BCR8Lr5jFY61lWpBiXNXIxLZCvDc26KR5L5tYX43iUVO3fzES1GRVoYnxxk2tmz
fcsZG5vK+Trc9L8OZJfkYrEHH3+Iw41MQ0w/djVtYr1+HYldx0QmYXAtnhIj+UMCAwEAAaOCAtkw
ggLVMAkGA1UdEwQCMAAwCwYDVR0PBAQDAgSwMB0GA1UdJQQWMBQGCCsGAQUFBwMCBggrBgEFBQcD
BDAdBgNVHQ4EFgQUszC96C3w5/2+d+atSr0IpT26YI4wHwYDVR0jBBgwFoAUU3Ltkpzg2ssBXHx+
ljVO8tS4UYIwHgYDVR0RBBcwFYETZHdtdzJAaW5mcmFkZWFkLm9yZzCCAUwGA1UdIASCAUMwggE/
MIIBOwYLKwYBBAGBtTcBAgMwggEqMC4GCCsGAQUFBwIBFiJodHRwOi8vd3d3LnN0YXJ0c3NsLmNv
bS9wb2xpY3kucGRmMIH3BggrBgEFBQcCAjCB6jAnFiBTdGFydENvbSBDZXJ0aWZpY2F0aW9uIEF1
dGhvcml0eTADAgEBGoG+VGhpcyBjZXJ0aWZpY2F0ZSB3YXMgaXNzdWVkIGFjY29yZGluZyB0byB0
aGUgQ2xhc3MgMSBWYWxpZGF0aW9uIHJlcXVpcmVtZW50cyBvZiB0aGUgU3RhcnRDb20gQ0EgcG9s
aWN5LCByZWxpYW5jZSBvbmx5IGZvciB0aGUgaW50ZW5kZWQgcHVycG9zZSBpbiBjb21wbGlhbmNl
IG9mIHRoZSByZWx5aW5nIHBhcnR5IG9ibGlnYXRpb25zLjA2BgNVHR8ELzAtMCugKaAnhiVodHRw
Oi8vY3JsLnN0YXJ0c3NsLmNvbS9jcnR1MS1jcmwuY3JsMIGOBggrBgEFBQcBAQSBgTB/MDkGCCsG
AQUFBzABhi1odHRwOi8vb2NzcC5zdGFydHNzbC5jb20vc3ViL2NsYXNzMS9jbGllbnQvY2EwQgYI
KwYBBQUHMAKGNmh0dHA6Ly9haWEuc3RhcnRzc2wuY29tL2NlcnRzL3N1Yi5jbGFzczEuY2xpZW50
LmNhLmNydDAjBgNVHRIEHDAahhhodHRwOi8vd3d3LnN0YXJ0c3NsLmNvbS8wDQYJKoZIhvcNAQEF
BQADggEBAHMQmxHHodpS85X8HRyxhvfkys7r+taCNOaNU9cxQu/cZ/6k5nS2qGNMzZ6jb7ueY/V7
7p+4DW/9ZWODDTf4Fz00mh5SSVc20Bz7t+hhxwHd62PZgENh5i76Qq2tw48U8AsYo5damHby1epf
neZafLpUkLLO7AGBJIiRVTevdvyXQ0qnixOmKMWyvrhSNGuVIKVdeqLP+102Dwf+dpFyw+j1hz28
jEEKpHa+NR1b2kXuSPi/rMGhexwlJOh4tK8KQ6Ryr0rIN//NSbOgbyYZrzc/ZUWX9V5OA84ChFb2
vkFl0OcYrttp/rhDBLITwffPxSZeoBh9H7zYzkbCXKL3BUIwggYnMIIFD6ADAgECAgMN7zcwDQYJ
KoZIhvcNAQEFBQAwgYwxCzAJBgNVBAYTAklMMRYwFAYDVQQKEw1TdGFydENvbSBMdGQuMSswKQYD
VQQLEyJTZWN1cmUgRGlnaXRhbCBDZXJ0aWZpY2F0ZSBTaWduaW5nMTgwNgYDVQQDEy9TdGFydENv
bSBDbGFzcyAxIFByaW1hcnkgSW50ZXJtZWRpYXRlIENsaWVudCBDQTAeFw0xNTA1MDUwOTQzNDFa
Fw0xNjA1MDUwOTUzMzZaMEIxHDAaBgNVBAMME2R3bXcyQGluZnJhZGVhZC5vcmcxIjAgBgkqhkiG
9w0BCQEWE2R3bXcyQGluZnJhZGVhZC5vcmcwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
AQDJG5vZD28dY/1+EVcn/6TykmMHpXHKOvU750EGyjPJvMZFo1ySNY6SdYzGhlGRhU6CDTEmYu5W
WsFKM7nVm10istUopBDUkyR337HUQCJbKfoUfL1r47ClK8urBHajxnaGuUWO/jeFkbrFmQ2Fv0UV
hOovRC/alfOglT2KsNtlATlMOP4/x1Rglek0gfMhOYhMIZP4VLs0axWZtTCTEe5gkuwQkfC6+YxW
OtZVqQYlzVyMS2Qrw3NuikeS+bWF+N4lFTt38xEtRkVaGJ8cZNrZs33LGRubyvk63PS/DmSX5GKx
Bx9/iMONTENMP3Y1bWK9fh2JXcdEJmFwLZ4SI/lDAgMBAAGjggLZMIIC1TAJBgNVHRMEAjAAMAsG
A1UdDwQEAwIEsDAdBgNVHSUEFjAUBggrBgEFBQcDAgYIKwYBBQUHAwQwHQYDVR0OBBYEFLMwvegt
8Of9vnfmrUq9CKU9umCOMB8GA1UdIwQYMBaAFFNy7ZKc4NrLAVx8fpY1TvLUuFGCMB4GA1UdEQQX
MBWBE2R3bXcyQGluZnJhZGVhZC5vcmcwggFMBgNVHSAEggFDMIIBPzCCATsGCysGAQQBgbU3AQID
MIIBKjAuBggrBgEFBQcCARYiaHR0cDovL3d3dy5zdGFydHNzbC5jb20vcG9saWN5LnBkZjCB9wYI
KwYBBQUHAgIwgeowJxYgU3RhcnRDb20gQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkwAwIBARqBvlRo
aXMgY2VydGlmaWNhdGUgd2FzIGlzc3VlZCBhY2NvcmRpbmcgdG8gdGhlIENsYXNzIDEgVmFsaWRh
dGlvbiByZXF1aXJlbWVudHMgb2YgdGhlIFN0YXJ0Q29tIENBIHBvbGljeSwgcmVsaWFuY2Ugb25s
eSBmb3IgdGhlIGludGVuZGVkIHB1cnBvc2UgaW4gY29tcGxpYW5jZSBvZiB0aGUgcmVseWluZyBw
YXJ0eSBvYmxpZ2F0aW9ucy4wNgYDVR0fBC8wLTAroCmgJ4YlaHR0cDovL2NybC5zdGFydHNzbC5j
b20vY3J0dTEtY3JsLmNybDCBjgYIKwYBBQUHAQEEgYEwfzA5BggrBgEFBQcwAYYtaHR0cDovL29j
c3Auc3RhcnRzc2wuY29tL3N1Yi9jbGFzczEvY2xpZW50L2NhMEIGCCsGAQUFBzAChjZodHRwOi8v
YWlhLnN0YXJ0c3NsLmNvbS9jZXJ0cy9zdWIuY2xhc3MxLmNsaWVudC5jYS5jcnQwIwYDVR0SBBww
GoYYaHR0cDovL3d3dy5zdGFydHNzbC5jb20vMA0GCSqGSIb3DQEBBQUAA4IBAQBzEJsRx6HaUvOV
/B0csYb35MrO6/rWgjTmjVPXMULv3Gf+pOZ0tqhjTM2eo2+7nmP1e+6fuA1v/WVjgw03+Bc9NJoe
UklXNtAc+7foYccB3etj2YBDYeYu+kKtrcOPFPALGKOXWph28tXqX53mWny6VJCyzuwBgSSIkVU3
r3b8l0NKp4sTpijFsr64UjRrlSClXXqiz/tdNg8H/naRcsPo9Yc9vIxBCqR2vjUdW9pF7kj4v6zB
oXscJSToeLSvCkOkcq9KyDf/zUmzoG8mGa83P2VFl/VeTgPOAoRW9r5BZdDnGK7baf64QwSyE8H3
z8UmXqAYfR+82M5Gwlyi9wVCMIIGNDCCBBygAwIBAgIBHjANBgkqhkiG9w0BAQUFADB9MQswCQYD
VQQGEwJJTDEWMBQGA1UEChMNU3RhcnRDb20gTHRkLjErMCkGA1UECxMiU2VjdXJlIERpZ2l0YWwg
Q2VydGlmaWNhdGUgU2lnbmluZzEpMCcGA1UEAxMgU3RhcnRDb20gQ2VydGlmaWNhdGlvbiBBdXRo
b3JpdHkwHhcNMDcxMDI0MjEwMTU1WhcNMTcxMDI0MjEwMTU1WjCBjDELMAkGA1UEBhMCSUwxFjAU
BgNVBAoTDVN0YXJ0Q29tIEx0ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRl
IFNpZ25pbmcxODA2BgNVBAMTL1N0YXJ0Q29tIENsYXNzIDEgUHJpbWFyeSBJbnRlcm1lZGlhdGUg
Q2xpZW50IENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxwmDzM4t2BqxKaQuE6uW
vooyg4ymiEGWVUet1G8SD+rqvyNH4QrvnEIaFHxOhESip7vMz39ScLpNLbL1QpOlPW/tFIzNHS3q
d2XRNYG5Sv9RcGE+T4qbLtsjjJbi6sL7Ls/f/X9ftTyhxvxWkf8KW37iKrueKsxw2HqolH7GM6FX
5UfNAwAu4ZifkpmZzU1slBhyWwaQPEPPZRsWoTb7q8hmgv6Nv3Hg9rmA1/VPBIOQ6SKRkHXG0Hhm
q1dOFoAFI411+a/9nWm5rcVjGcIWZ2v/43Yksq60jExipA4l5uv9/+Hm33mbgmCszdj/Dthf13tg
Av2O83hLJ0exTqfrlwIDAQABo4IBrTCCAakwDwYDVR0TAQH/BAUwAwEB/zAOBgNVHQ8BAf8EBAMC
AQYwHQYDVR0OBBYEFFNy7ZKc4NrLAVx8fpY1TvLUuFGCMB8GA1UdIwQYMBaAFE4L7xqkQFulF2mH
MMo0aEPQQa7yMGYGCCsGAQUFBwEBBFowWDAnBggrBgEFBQcwAYYbaHR0cDovL29jc3Auc3RhcnRz
c2wuY29tL2NhMC0GCCsGAQUFBzAChiFodHRwOi8vd3d3LnN0YXJ0c3NsLmNvbS9zZnNjYS5jcnQw
WwYDVR0fBFQwUjAnoCWgI4YhaHR0cDovL3d3dy5zdGFydHNzbC5jb20vc2ZzY2EuY3JsMCegJaAj
hiFodHRwOi8vY3JsLnN0YXJ0c3NsLmNvbS9zZnNjYS5jcmwwgYAGA1UdIAR5MHcwdQYLKwYBBAGB
tTcBAgEwZjAuBggrBgEFBQcCARYiaHR0cDovL3d3dy5zdGFydHNzbC5jb20vcG9saWN5LnBkZjA0
BggrBgEFBQcCARYoaHR0cDovL3d3dy5zdGFydHNzbC5jb20vaW50ZXJtZWRpYXRlLnBkZjANBgkq
hkiG9w0BAQUFAAOCAgEACoMIfXirLAZcuGOMXq4cuSN3TaFx2H2GvD5VSy/6rV55BYHbWNaPeQn3
oBSU8KgQZn/Kck1JxbLpAxVCNtsxeW1R87ifhsYZ0qjdrA9anrW2MAWCtosmAOT4OxK9QPoSjCMx
M3HbkZCDJgnlE8jMopH21BbyAYr7b5EfGRQJNtgWcvqSXwKHnTutR08+Kkn0KAkXCzeQNLeA5LlY
UzFyM7kPAp8pIRMQ+seHunmyG642S2+y/qHEdMuGIwpfz3eDF1PdctL04qYK/zu+Qg1Bw0RwgigV
Zs/0c5HP2/e9DBHh7eSwtzYlk4AUr6yxLlcwSjOfOmKEQ/Q8tzh0IFiNu9IPuTGAPBn4CPxD0+Ru
8T2wg8/s43R/PT3kd1OEqOJUl7q+h+r6fpvU0Fzxd2tC8Ga6fDEPme+1Nbi+03pVjuZQKbGwKJ66
gEn06WqaxVZC+J8hh/jR0k9mST1iAZPNYulcNJ8tKmVtjYsv0L1TSm2+NwON58tO+pIVzu3DWwSE
XSf+qkDavQam+QtEOZxLBXI++aMUEapSn+k3Lxm48ZCYfAWLb/Xj7F5JQMbZvCexglAbYR0kIHqW
5DnsYSdMD/IplJMojx0NBrxJ3fN9dvX2Y6BIXRsF1du4qESm4/3CKuyUV7p9DW3mPlHTGLvYxnyK
Qy7VFBkoLINszBrOUeIxggNvMIIDawIBATCBlDCBjDELMAkGA1UEBhMCSUwxFjAUBgNVBAoTDVN0
YXJ0Q29tIEx0ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRlIFNpZ25pbmcx
ODA2BgNVBAMTL1N0YXJ0Q29tIENsYXNzIDEgUHJpbWFyeSBJbnRlcm1lZGlhdGUgQ2xpZW50IENB
AgMN7zcwCQYFKw4DAhoFAKCCAa8wGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0B
CQUxDxcNMTUwOTE4MDEwNDM2WjAjBgkqhkiG9w0BCQQxFgQU03gKDHlZS6/wn1J/8v4Hu4Rmyw4w
gaUGCSsGAQQBgjcQBDGBlzCBlDCBjDELMAkGA1UEBhMCSUwxFjAUBgNVBAoTDVN0YXJ0Q29tIEx0
ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRlIFNpZ25pbmcxODA2BgNVBAMT
L1N0YXJ0Q29tIENsYXNzIDEgUHJpbWFyeSBJbnRlcm1lZGlhdGUgQ2xpZW50IENBAgMN7zcwgacG
CyqGSIb3DQEJEAILMYGXoIGUMIGMMQswCQYDVQQGEwJJTDEWMBQGA1UEChMNU3RhcnRDb20gTHRk
LjErMCkGA1UECxMiU2VjdXJlIERpZ2l0YWwgQ2VydGlmaWNhdGUgU2lnbmluZzE4MDYGA1UEAxMv
U3RhcnRDb20gQ2xhc3MgMSBQcmltYXJ5IEludGVybWVkaWF0ZSBDbGllbnQgQ0ECAw3vNzANBgkq
hkiG9w0BAQEFAASCAQCUH7G7BGKN17zUv73WWvNo20mMdaMlPa3BfQmrvjtug58IHTIhZoECupV4
IhIwU0y1eXDWNh048NAURwdWSp28togwbpV3ZIiSBpXZNYQXR1atyIbFyknOSaIjxgZt1CnXzFqt
b0wFPNOPnqK4R9up/OH7AWaPXeZK4dU+RvrGNXtUyRP+nE5GTg7LfVFiqOakMa7L0Q9GUan3IFXR
k/lBAvGbP7PxmvypS1xhfC92/6EyzeFotGIW3nkg4Syp9pgnn7T7bld3SJGCm66X7H8pnBjyqRDl
+uk0/wO3lJhXJEij43AR6zJe9ygEsVWoOL4bOYTeK5Ufa8cXbf6qPrt6AAAAAAAA


--=-vy6G6re9lqrEyld9CeOK--

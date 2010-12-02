From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: jme: UDP checksum error, and lots of them
Date: Fri, 3 Dec 2010 00:54:06 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1012030044440.22334@obet.zrqbmnf.qr>
References: <alpine.LNX.2.01.1012020430190.4157@obet.zrqbmnf.qr> <20101201.200935.71110482.davem@davemloft.net> <20101202042820.M98672@cooldavid.org> <20101201.215916.104055114.davem@davemloft.net> <20101202231546.GA3507@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, cooldavid@cooldavid.org,
	netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:39968 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757895Ab0LBXyI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Dec 2010 18:54:08 -0500
In-Reply-To: <20101202231546.GA3507@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 2010-12-03 00:15, Francois Romieu wrote:

>David Miller <davem@davemloft.net> :
>[...]
>> Something isn't right here.  The only thing that makes sense is if
>> the tcpdump checksum validation is wrong for some reason.  Because
>> only then could we give a reason for the UDP frames to not be
>> dropped before vpnc can see them.
>
>Wild guess : 192.168... is the local address and tcpdump chokes on
>an outgoing, yet-not-checksummed packet.

Then the checksums of all other packets I am emitting would also be 0000 
or wrong, which isn't the case.

Also, when I am running vpnc on my desktop machine (unlike the
laptop, it has sis900 and is i586), tcpdump agrees with the checksum
it seems.
So either it's due to x86_64, or it is in fact jme..

00:48:10.954007 IP 192.168.13.37.4500 > 134.76.22.1.4500: UDP-encap:
ESP(spi=0x2224e306,seq=0x225a), length 164
        0x0000:  4500 00c0 4582 4000 4011 8a90 c0a8 0d25  E...E.@.@......%
        0x0010:  864c 1601 1194 1194 00ac b0e4 2224 e306  .L.........."$..
        0x0020:  0000 225a 70d8 8311 d5f4 0936 1a1c 1664  .."Zp......6...d
        0x0030:  f4b9 9281 a9a3 6b91 41eb 1deb 737e defd  ......k.A...s~..
        0x0040:  d5cc 9a76 976c 4216 bdf3 4f23 50b7 deda  ...v.lB...O#P...
        0x0050:  dcf2 489f 223d 9e24 21fb b5f4 5829 ec4c  ..H."=.$!...X).L
        0x0060:  f90b 25b2 588f 82e1 131c b273 07e0 7234  ..%.X......s..r4
        0x0070:  957c 69e8 6e56 353c 7ce8 446a 52a2 fe2f  .|i.nV5<|.DjR../
        0x0080:  ea75 c9ac e7e3 df40 bca5 2ca9 e376 29ea  .u.....@..,..v).
        0x0090:  080b 2329 c1b7 1111 0e4b 8c13 af98 4d5e  ..#).....K....M^
        0x00a0:  1708 a911 9962 d023 9dff 4df6 58fd e035  .....b.#..M.X..5
        0x00b0:  5386 4198 ea07 376d 8c96 3466 394d c7e6  S.A...7m..4f9M..

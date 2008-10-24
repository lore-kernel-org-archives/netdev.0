From: Manfred Scherer <manfred.scherer.mhm@t-online.de>
Subject: Re: [Bugme-new] [Bug 11754] New: tlan network driver does not work
Date: Fri, 24 Oct 2008 06:12:12 +0200
Message-ID: <200810240612.13247.manfred.scherer.mhm@t-online.de>
References: <bug-11754-10286@http.bugzilla.kernel.org/> <200810211634.02138.manfred.scherer.mhm@t-online.de> <e6d1cecd0810211540l7182c270l88de14cf18cfcd50@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	"Robert Fitzsimons" <robfitz@273k.net>
To: "Michal Ostrowski" <mostrows@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout07.t-online.de ([194.25.134.83]:58339 "EHLO
	mailout07.t-online.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751673AbYJXMOT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2008 08:14:19 -0400
In-Reply-To: <e6d1cecd0810211540l7182c270l88de14cf18cfcd50@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I had a look on the ethernet pci-card LAN-LED and the DSL-Modem LAN-LED. 
It seems to be that the packets were sent out are going over the
wire, the ethernet pci-card LAN-LED and the DSL-Modem LAN-LED blinks
three times. It seems so that the replayed packets are dropped.

Manfred Scherer
_____________________________________________________________________________

Am Mittwoch, 22. Oktober 2008 00:40 schrieb Michal Ostrowski:
> As far as linux is concerned 3 "PADI" packets were sent out; in other words
> 3 such
> packets were given to the driver.
> 
> Given that there's no "PADO" reply, then either the driver dropped the
> packet transmission, or
> it dropped the reply.
> 
> 
> --
> Michal Ostrowski
> mostrows@gmail.com
> 
> 
> On Tue, Oct 21, 2008 at 9:34 AM, Manfred Scherer <
> manfred.scherer.mhm@t-online.de> wrote:
> 
> >
> > I did this test again. This time I get an output for
> > tcpdump but I don't understand why. Anyway maybe it helps.
> >
> > Original kernel 2.6.27:
> >
> > pc1:/var/log # tcpdump -i eth1 -vv
> > tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
> > listening on eth1, link-type EN10MB (Ethernet), capture size 96 bytes
> > 16:08:19.131281 PPPoE PADI [Service-Name] [Host-Uniq 0xC55D0000]
> > 16:08:24.130603 PPPoE PADI [Service-Name] [Host-Uniq 0xC55D0000]
> > 16:08:34.129227 PPPoE PADI [Service-Name] [Host-Uniq 0xC55D0000]
> > ^C
> > 3 packets captured
> > 3 packets received by filter
> > 0 packets dropped by kernel
> > pc1:/var/log #
> >
> >
> > And now with the tlan module from kernel 2.6.26 compiled and tested
> > in kernel 2.6.27:
> >
> > pc1:/var/log # tcpdump -i eth1 -vv
> > tcpdump: listening on eth1, link-type EN10MB (Ethernet), capture size 96
> > bytes
> > 16:21:34.890207 PPPoE PADI [Service-Name] [Host-Uniq 0xA7670000]
> > 16:21:35.011875 PPPoE PADO [AC-Name "MANX48-erx"] [Host-Uniq 0xA7670000]
> > [Service-Name] [AC-Cookie 0xCE73D7BB289D47261BF087A3B4AD1699]
> > 16:21:35.011955 PPPoE PADR [Service-Name] [Host-Uniq 0xA7670000] [AC-Cookie
> > 0xCE73D7BB289D47261BF087A3B4AD1699]
> > 16:21:35.087761 PPPoE PADS [ses 0xc0b] [Service-Name] [Host-Uniq
> > 0xA7670000] [AC-Name "MANX48-erx"] [AC-Cookie
> > 0xCE73D7BB289D47261BF087A3B4AD1699]
> > 16:21:35.125039 PPPoE  [ses 0xc0b] LCP, Conf-Request (0x01), id 1, MRU
> >  1492, Magic-Num  0xe1c8a370, length 14
> >        0x0000:  c021 0101 000e 0104 05d4 0506 e1c8 a370
> > 16:21:35.276745 PPPoE  [ses 0xc0b] LCP, Conf-Request (0x01), id 176, MRU
> >  1492, Auth-Prot  PAP, Magic-Num  0x6ef0246c, length 18
> >        0x0000:  c021 01b0 0012 0104 05d4 0304 c023 0506
> >        0x0010:  6ef0 246c
> > 16:21:35.276824 PPPoE  [ses 0xc0b] LCP, Conf-Ack (0x02), id 176, MRU  1492,
> > Auth-Prot  PAP, Magic-Num  0x6ef0246c, length 18
> >        0x0000:  c021 02b0 0012 0104 05d4 0304 c023 0506
> >        0x0010:  6ef0 246c
> > 16:21:35.277259 PPPoE  [ses 0xc0b] LCP, Conf-Ack (0x02), id 1, MRU  1492,
> > Magic-Num  0xe1c8a370, length 14
> >        0x0000:  c021 0201 000e 0104 05d4 0506 e1c8 a370
> > 16:21:35.277357 PPPoE  [ses 0xc0b] LCP, Echo-Request (0x09), id 0,
> > Magic-Num 0xe1c8a370, length 8
> >        0x0000:  c021 0900 0008 e1c8 a370
> > 16:21:35.277387 PPPoE  [ses 0xc0b] Auth-Req(1), Peer 000012341234123434#
> > 0001@t-online.de, Name XXXXXX
> > 16:21:35.320362 PPPoE  [ses 0xc0b] LCP, Echo-Reply (0x0a), id 0, Magic-Num
> > 0x6ef0246c, length 8
> >        0x0000:  c021 0a00 0008 6ef0 246c
> >
> >
> > Manfred Scherer
> >

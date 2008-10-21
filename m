From: Manfred Scherer <manfred.scherer.mhm@t-online.de>
Subject: Re: [Bugme-new] [Bug 11754] New: tlan network driver does not work
Date: Tue, 21 Oct 2008 16:34:01 +0200
Message-ID: <200810211634.02138.manfred.scherer.mhm@t-online.de>
References: <bug-11754-10286@http.bugzilla.kernel.org/> <200810210836.18765.manfred.scherer.mhm@t-online.de> <e6d1cecd0810210843pfaa2d46h66b05a63398b2e03@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	"Robert Fitzsimons" <robfitz@273k.net>
To: "Michal Ostrowski" <mostrows@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout06.t-online.de ([194.25.134.19]:35153 "EHLO
	mailout06.t-online.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751127AbYJUWhM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2008 18:37:12 -0400
In-Reply-To: <e6d1cecd0810210843pfaa2d46h66b05a63398b2e03@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I did this test again. This time I get an output for
tcpdump but I don't understand why. Anyway maybe it helps.

Original kernel 2.6.27:

pc1:/var/log # tcpdump -i eth1 -vv
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth1, link-type EN10MB (Ethernet), capture size 96 bytes
16:08:19.131281 PPPoE PADI [Service-Name] [Host-Uniq 0xC55D0000]
16:08:24.130603 PPPoE PADI [Service-Name] [Host-Uniq 0xC55D0000]
16:08:34.129227 PPPoE PADI [Service-Name] [Host-Uniq 0xC55D0000]
^C
3 packets captured
3 packets received by filter
0 packets dropped by kernel
pc1:/var/log # 


And now with the tlan module from kernel 2.6.26 compiled and tested
in kernel 2.6.27:

pc1:/var/log # tcpdump -i eth1 -vv
tcpdump: listening on eth1, link-type EN10MB (Ethernet), capture size 96 bytes
16:21:34.890207 PPPoE PADI [Service-Name] [Host-Uniq 0xA7670000]
16:21:35.011875 PPPoE PADO [AC-Name "MANX48-erx"] [Host-Uniq 0xA7670000] [Service-Name] [AC-Cookie 0xCE73D7BB289D47261BF087A3B4AD1699]
16:21:35.011955 PPPoE PADR [Service-Name] [Host-Uniq 0xA7670000] [AC-Cookie 0xCE73D7BB289D47261BF087A3B4AD1699]
16:21:35.087761 PPPoE PADS [ses 0xc0b] [Service-Name] [Host-Uniq 0xA7670000] [AC-Name "MANX48-erx"] [AC-Cookie 0xCE73D7BB289D47261BF087A3B4AD1699]
16:21:35.125039 PPPoE  [ses 0xc0b] LCP, Conf-Request (0x01), id 1, MRU  1492, Magic-Num  0xe1c8a370, length 14
        0x0000:  c021 0101 000e 0104 05d4 0506 e1c8 a370
16:21:35.276745 PPPoE  [ses 0xc0b] LCP, Conf-Request (0x01), id 176, MRU  1492, Auth-Prot  PAP, Magic-Num  0x6ef0246c, length 18
        0x0000:  c021 01b0 0012 0104 05d4 0304 c023 0506
        0x0010:  6ef0 246c
16:21:35.276824 PPPoE  [ses 0xc0b] LCP, Conf-Ack (0x02), id 176, MRU  1492, Auth-Prot  PAP, Magic-Num  0x6ef0246c, length 18
        0x0000:  c021 02b0 0012 0104 05d4 0304 c023 0506
        0x0010:  6ef0 246c
16:21:35.277259 PPPoE  [ses 0xc0b] LCP, Conf-Ack (0x02), id 1, MRU  1492, Magic-Num  0xe1c8a370, length 14
        0x0000:  c021 0201 000e 0104 05d4 0506 e1c8 a370
16:21:35.277357 PPPoE  [ses 0xc0b] LCP, Echo-Request (0x09), id 0, Magic-Num 0xe1c8a370, length 8
        0x0000:  c021 0900 0008 e1c8 a370
16:21:35.277387 PPPoE  [ses 0xc0b] Auth-Req(1), Peer 000012341234123434#0001@t-online.de, Name XXXXXX
16:21:35.320362 PPPoE  [ses 0xc0b] LCP, Echo-Reply (0x0a), id 0, Magic-Num 0x6ef0246c, length 8
        0x0000:  c021 0a00 0008 6ef0 246c


Manfred Scherer
_________________________________________________________________________________

Am Dienstag, 21. Oktober 2008 17:43 schrieb Michal Ostrowski:
> The strace shows that the rp-pppoe daemon did send a packet out over the
> raw socket.  The problem here appears to be that nothing showed up in the
> tcpdump
> output --- indicating the packet never hit the wire.
> 
> --
> Michal Ostrowski
> mostrows@gmail.com
> 
> 
> On Tue, Oct 21, 2008 at 1:36 AM, Manfred Scherer <
> manfred.scherer.mhm@t-online.de> wrote:
> 
> >
> > In the SuSE-9.2 distribution is the approach to connect to the
> > Internet via DSL a bit tricky. There are a bunch of human interfaces,
> > like kinternet (KDE), cinternet (commandline tool), and so on.
> > All these human interfaces uses the same service smpppd.
> >
> > I use the commandline tool cinternet in shell scripts to do
> > the connect to the internet.
> >
> > pc1:~ # ps -ef|grep ppp
> > root      4721     1  0 Oct18 ?        00:01:23 /usr/sbin/smpppd
> >
> > It makes no sense to start cinternet via strace but control smpppd
> > via strace:
> > strace -f -p 4721 -o /var/log/strace_pppd_2_6_27_.log
> >
> > I've done both cases, in the some way. In my last mail was an extract
> > from these trace files. Here are now the complete one as attachment.
> >
> > bug_11754_logfiles_2.zip:
> > -rw-r--r--  1 root root 684114 Oct 19 16:35 strace_pppd_2_6_26_.log
> > -rw-r--r--  1 root root 807244 Oct 19 16:36 strace_pppd_2_6_27_.log
> >
> >
> > Manfred Scherer
> >
> >
> > _____________________________________________________________________________
> >
> > Am Sonntag, 19. Oktober 2008 21:52 schrieb Michal Ostrowski:
> > > One interesting thing to note is that there are no packets in the 2.6.27
> > > tcpdump -- which indicates that
> > > the initial transmission by pppoe did not result in a packet going out.
> > >
> > > It might be interesting to see an strace, but one done with the  "-f"
> > flag.
> > > These straces don't show
> > > the pppoe process that pppd spawns.
> > >
> > >
> > > --
> > > Michal Ostrowski
> > > mostrows@gmail.com
> > >
> > >
> > > On Wed, Oct 15, 2008 at 9:06 AM, Manfred Scherer <
> > > manfred.scherer.mhm@t-online.de> wrote:
> > >
> > > >
> > > > here some logfiles (bug_11754_logfiles.zip) for compare 2.6.26 to
> > 2.6.27:
> > > >
> > > > -rw-r--r--  1 root root   6465 Oct 15 15:52 pppd_2_6_26.log
> > > > -rw-r--r--  1 root root    566 Oct 15 13:24 pppd_2_6_27.log
> > > > -rw-r--r--  1 root root 130438 Oct 15 15:41 strace_pppd_2_6_26_7719.log
> > > > -rw-r--r--  1 root root  28123 Oct 15 15:41 strace_pppd_2_6_27_8852.log
> > > > -rw-r--r--  1 root root  14337 Oct 15 13:12 tcpdump_eth1_2_6_26.log
> > > > -rw-r--r--  1 root root      0 Oct 15 13:21 tcpdump_eth1_2_6_27.log
> > (is
> > > > empty because no output)
> > > >
> > > > Manfred Scherer
> > > >
> > > >
> > __________________________________________________________________________________
> > > >
> > > > Am Dienstag, 14. Oktober 2008 15:52 schrieb Michal Ostrowski:
> > > > > The failure occurs during PPPOE negotiation.
> > > > > The pppoe kernel driver does not do the negotiation phase, which is
> > done
> > > > in
> > > > > user space.
> > > > > At this stage we're just using a raw socket to grab those packets
> > from
> > > > the
> > > > > eth device,
> > > > > and it appears we were not able to receive the first packet from the
> > > > server
> > > > > - there's no
> > > > > indication that any packets came in over the eth device at all.
> > > > >
> > > > > To debug this one would need:  verbose logs from pppd/rp-pppoe and a
> > > > tcpdump
> > > > > trace
> > > > > showing packets on the specified interface.
> > > > >
> > > > >
> > > > > --
> > > > > Michal Ostrowski
> > > > > mostrows@gmail.com
> > > > >
> > > > >
> > > > > On Tue, Oct 14, 2008 at 7:32 AM, Andrew Morton <
> > > > akpm@linux-foundation.org>wrote:
> > > > >
> > > > > >
> > > > > > (switched to email.  Please respond via emailed reply-to-all, not
> > via
> > > > the
> > > > > > bugzilla web interface).
> > > > > >
> > > > > > > On Mon, 13 Oct 2008 15:26:04 -0700 (PDT)
> > > > > > bugme-daemon@bugzilla.kernel.org wrote:
> > > > > > > http://bugzilla.kernel.org/show_bug.cgi?id=11754
> > > > > > >
> > > > > > >            Summary: tlan network driver does not work
> > > > > > >            Product: Drivers
> > > > > > >            Version: 2.5
> > > > > > >      KernelVersion: 2.6.27
> > > > > > >           Platform: All
> > > > > > >         OS/Version: Linux
> > > > > > >               Tree: Mainline
> > > > > > >             Status: NEW
> > > > > > >           Severity: high
> > > > > > >           Priority: P1
> > > > > > >          Component: Network
> > > > > > >         AssignedTo: jgarzik@pobox.com
> > > > > > >         ReportedBy: Manfred.Scherer.Mhm@t-online.de
> > > > > > >
> > > > > > >
> > > > > > > Latest working kernel version: 2.6.26
> > > > > > > Earliest failing kernel version: 2.6.27
> > > > > >
> > > > > > A 2.6.27 regression.
> > > > > >
> > > > > > Not much has happened in tlan.c - a single fix from Robert.  This
> > > > > > regression might be in pppoe?
> > > > > >
> > > > > >
> > > > > > > Distribution: SuSE 9.2
> > > > > > > Hardware Environment:
> > > > > > > /var/log/boot.msg:
> > > > > > > <6>ThunderLAN driver v1.15
> > > > > > > <6>tlan 0000:00:0d.0: found PCI INT A -> IRQ 11
> > > > > > > <6>tlan 0000:00:0d.0: sharing IRQ 11 with 0000:00:09.0
> > > > > > > <6>TLAN: eth1 irq=11, io=c400, Compaq Netelligent 10/100 TX PCI
> > UTP,
> > > > Rev.
> > > > > > 16
> > > > > > > <6>TLAN: 1 device installed, PCI: 1  EISA: 0
> > > > > > > ...
> > > > > > > Setting up network interfaces:
> > > > > > >     lo
> > > > > > >     lo        IP address: 127.0.0.1/8
> > > > > > > done    eth0      device: Realtek Semiconductor Co., Ltd.
> > > > RTL-8029(AS)
> > > > > > >     eth0      configuration: eth-id-52:54:00:db:15:ff
> > > > > > >     eth0      IP address: 192.168.0.99/24
> > > > > > > done    eth1      device: Compaq Computer Corporation Compaq
> > > > Netelligent
> > > > > > 10/100
> > > > > > > TX PCI UTP TLAN 2.3 (rev 10)
> > > > > > >     eth1      IP address: 192.168.1.22/24
> > > > > > > done    dsl0
> > > > > > >     dsl0      Startmode is 'manual'
> > > > > > >
> > > > > > >
> > > > > > > Software Environment:
> > > > > > >
> > > > > > > Problem Description:
> > > > > > >
> > > > > > > PPPoe does not work
> > > > > > > see /var/log/messages:
> > > > > > >
> > > > > > > Oct 13 14:39:06 pc1 pppd[10123]: Plugin rp-pppoe.so loaded.
> > > > > > > Oct 13 14:39:06 pc1 kernel: PPP generic driver version 2.4.2
> > > > > > > Oct 13 14:39:06 pc1 pppd[10123]: RP-PPPoE plugin version 3.3
> > compiled
> > > > > > against
> > > > > > > pp
> > > > > > > pd 2.4.2
> > > > > > > Oct 13 14:39:06 pc1 pppd[10123]: Plugin passwordfd.so loaded.
> > > > > > > Oct 13 14:39:06 pc1 kernel: NET: Registered protocol family 17
> > > > > > > Oct 13 14:39:06 pc1 pppd[10123]: pppd 2.4.2 started by root, uid
> > 0
> > > > > > > Oct 13 14:39:41 pc1 pppd[10123]: Timeout waiting for PADO packets
> > > > > > > Oct 13 14:39:41 pc1 pppd[10123]: Unable to complete PPPoE
> > Discovery
> > > > > > > Oct 13 14:39:41 pc1 pppd[10123]: Exit.
> > > > > > >
> > > > > > >
> > > > > > > Steps to reproduce:
> > > > > > >
> > > > > > > start dsl-connection to internet.
> > > > > > >
> > > > > >
> > > > > >
> > > > >
> > > >
> > >
> >
> 

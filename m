From: Manfred Scherer <manfred.scherer.mhm@t-online.de>
Subject: Re: [Bug 11754] tlan network driver does not work
Date: Sun, 19 Oct 2008 12:24:21 +0200
Message-ID: <200810191224.21758.manfred.scherer.mhm@t-online.de>
References: <20081014135215.5A024108057@picon.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, mostrows@earthlink.net,
	robfitz@273k.net
To: mostrows@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout09.t-online.de ([194.25.134.84]:41178 "EHLO
	mailout09.t-online.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751518AbYJSSZV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Oct 2008 14:25:21 -0400
In-Reply-To: <20081014135215.5A024108057@picon.linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've did some more tests belonging this bug.

1st.
http request to the DSL-modem (admin-Interface). Here is the tcpdump,

kernel 2.6.26:
pc1:~ # tcpdump -i eth1 -vvv
tcpdump: listening on eth1, link-type EN10MB (Ethernet), capture size 96 bytes
12:43:10.201543 arp who-has 192.168.1.1 tell 192.168.1.22
12:43:10.201779 arp reply 192.168.1.1 is-at 00:19:15:47:0e:11
12:43:10.201798 IP (tos 0x8, ttl  64, id 24982, offset 0, flags [DF], length: 60) 192.168.1.22.25219 > 192.168.1.1.http: S [tcp sum ok] 824562007:824562007(0) win 5840 <mss 1460,sackOK,timestamp 4294881473 0,nop,wscale 6>
12:43:10.202300 arp who-has 192.168.1.22 tell 192.168.1.1
12:43:10.202319 arp reply 192.168.1.22 is-at 00:08:c7:28:5a:96
12:43:10.202820 IP (tos 0x0, ttl 100, id 2152, offset 0, flags [none], length: 44) 192.168.1.1.http > 192.168.1.22.25219: S [tcp sum ok] 0:0(0) ack 824562008 win 49152 <mss 1400>
12:43:10.202895 IP (tos 0x8, ttl  64, id 24983, offset 0, flags [DF], length: 40) 192.168.1.22.25219 > 192.168.1.1.http: . [tcp sum ok] 1:1(0) ack 1 win 5840
12:43:10.203330 IP (tos 0x0, ttl 100, id 2153, offset 0, flags [none], length: 40) 192.168.1.1.http > 192.168.1.22.25219: . [tcp sum ok] 1:1(0) ack 1 win 49152
...


kernel 2.6.27:

pc1:~ # tcpdump -i eth1 -vvv
tcpdump: listening on eth1, link-type EN10MB (Ethernet), capture size 96 bytes
12:36:50.434395 arp who-has 192.168.1.1 tell 192.168.1.22
12:36:51.434178 arp who-has 192.168.1.1 tell 192.168.1.22
12:36:52.434029 arp who-has 192.168.1.1 tell 192.168.1.22
^C
3 packets captured
3 packets received by filter
0 packets dropped by kernel
pc1:~ #


2nd. 
I used the tlan.c and tlan.h from kernel source 2.6.26 in the
kernel source 2.6.27 to build a kernel. Result is:
- http request to the DSLModem operates
- pppoe operates (as proof this mail)

Manfred Scherer

Am Dienstag, 14. Oktober 2008 15:52 schrieb bugme-daemon@bugzilla.kernel.org:
> http://bugzilla.kernel.org/show_bug.cgi?id=11754
> 
> 
> 
> 
> 
> ------- Comment #2 from anonymous@kernel-bugs.osdl.org  2008-10-14 06:52 -------
> Reply-To: mostrows@gmail.com
> 
> The failure occurs during PPPOE negotiation.
> The pppoe kernel driver does not do the negotiation phase, which is done in
> user space.
> At this stage we're just using a raw socket to grab those packets from the
> eth device,
> and it appears we were not able to receive the first packet from the server
> - there's no
> indication that any packets came in over the eth device at all.
> 
> To debug this one would need:  verbose logs from pppd/rp-pppoe and a tcpdump
> trace
> showing packets on the specified interface.
> 
> 
> --
> Michal Ostrowski
> mostrows@gmail.com
> 
> 
> On Tue, Oct 14, 2008 at 7:32 AM, Andrew Morton
> <akpm@linux-foundation.org>wrote:
> 
> >
> > (switched to email.  Please respond via emailed reply-to-all, not via the
> > bugzilla web interface).
> >
> > > On Mon, 13 Oct 2008 15:26:04 -0700 (PDT)
> > bugme-daemon@bugzilla.kernel.org wrote:
> > > http://bugzilla.kernel.org/show_bug.cgi?id=11754
> > >
> > >            Summary: tlan network driver does not work
> > >            Product: Drivers
> > >            Version: 2.5
> > >      KernelVersion: 2.6.27
> > >           Platform: All
> > >         OS/Version: Linux
> > >               Tree: Mainline
> > >             Status: NEW
> > >           Severity: high
> > >           Priority: P1
> > >          Component: Network
> > >         AssignedTo: jgarzik@pobox.com
> > >         ReportedBy: Manfred.Scherer.Mhm@t-online.de
> > >
> > >
> > > Latest working kernel version: 2.6.26
> > > Earliest failing kernel version: 2.6.27
> >
> > A 2.6.27 regression.
> >
> > Not much has happened in tlan.c - a single fix from Robert.  This
> > regression might be in pppoe?
> >
> >
> > > Distribution: SuSE 9.2
> > > Hardware Environment:
> > > /var/log/boot.msg:
> > > <6>ThunderLAN driver v1.15
> > > <6>tlan 0000:00:0d.0: found PCI INT A -> IRQ 11
> > > <6>tlan 0000:00:0d.0: sharing IRQ 11 with 0000:00:09.0
> > > <6>TLAN: eth1 irq=11, io=c400, Compaq Netelligent 10/100 TX PCI UTP, Rev.
> > 16
> > > <6>TLAN: 1 device installed, PCI: 1  EISA: 0
> > > ...
> > > Setting up network interfaces:
> > >     lo
> > >     lo        IP address: 127.0.0.1/8
> > > done    eth0      device: Realtek Semiconductor Co., Ltd. RTL-8029(AS)
> > >     eth0      configuration: eth-id-52:54:00:db:15:ff
> > >     eth0      IP address: 192.168.0.99/24
> > > done    eth1      device: Compaq Computer Corporation Compaq Netelligent
> > 10/100
> > > TX PCI UTP TLAN 2.3 (rev 10)
> > >     eth1      IP address: 192.168.1.22/24
> > > done    dsl0
> > >     dsl0      Startmode is 'manual'
> > >
> > >
> > > Software Environment:
> > >
> > > Problem Description:
> > >
> > > PPPoe does not work
> > > see /var/log/messages:
> > >
> > > Oct 13 14:39:06 pc1 pppd[10123]: Plugin rp-pppoe.so loaded.
> > > Oct 13 14:39:06 pc1 kernel: PPP generic driver version 2.4.2
> > > Oct 13 14:39:06 pc1 pppd[10123]: RP-PPPoE plugin version 3.3 compiled
> > against
> > > pp
> > > pd 2.4.2
> > > Oct 13 14:39:06 pc1 pppd[10123]: Plugin passwordfd.so loaded.
> > > Oct 13 14:39:06 pc1 kernel: NET: Registered protocol family 17
> > > Oct 13 14:39:06 pc1 pppd[10123]: pppd 2.4.2 started by root, uid 0
> > > Oct 13 14:39:41 pc1 pppd[10123]: Timeout waiting for PADO packets
> > > Oct 13 14:39:41 pc1 pppd[10123]: Unable to complete PPPoE Discovery
> > > Oct 13 14:39:41 pc1 pppd[10123]: Exit.
> > >
> > >
> > > Steps to reproduce:
> > >
> > > start dsl-connection to internet.
> > >
> >
> >
> <div dir="ltr">The failure occurs during PPPOE negotiation.<br>The pppoe kernel
> driver does not do the negotiation phase, which is done in user space.<br>At
> this stage we&#39;re just using a raw socket to grab those packets from the eth
> device,<br>
> and it appears we were not able to receive the first packet from the server -
> there&#39;s no<br>indication that any packets came in over the eth device at
> all.<br><br>To debug this one would need:&nbsp; verbose logs from pppd/rp-pppoe
> and a tcpdump trace<br>
> showing packets on the specified interface.<br><br><br clear="all">--<br>Michal
> Ostrowski<br><a href="mailto:mostrows@gmail.com">mostrows@gmail.com</a><br>
> <br><br><div class="gmail_quote">On Tue, Oct 14, 2008 at 7:32 AM, Andrew Morton
> <span dir="ltr">&lt;<a
> href="mailto:akpm@linux-foundation.org">akpm@linux-foundation.org</a>&gt;</span>
> wrote:<br><blockquote class="gmail_quote" style="border-left: 1px solid
> rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;">
> <br>
> (switched to email. &nbsp;Please respond via emailed reply-to-all, not via
> the<br>
> bugzilla web interface).<br>
> <br>
> &gt; On Mon, 13 Oct 2008 15:26:04 -0700 (PDT) <a
> href="mailto:bugme-daemon@bugzilla.kernel.org">bugme-daemon@bugzilla.kernel.org</a>
> wrote:<br>
> &gt; <a href="http://bugzilla.kernel.org/show_bug.cgi?id=11754"
> target="_blank">http://bugzilla.kernel.org/show_bug.cgi?id=11754</a><br>
> &gt;<br>
> &gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;Summary: tlan network driver does
> not work<br>
> &gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;Product: Drivers<br>
> &gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;Version: 2.5<br>
> &gt; &nbsp; &nbsp; &nbsp;KernelVersion: 2.6.27<br>
> &gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; Platform: All<br>
> &gt; &nbsp; &nbsp; &nbsp; &nbsp; OS/Version: Linux<br>
> &gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; Tree: Mainline<br>
> &gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; Status: NEW<br>
> &gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; Severity: high<br>
> &gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; Priority: P1<br>
> &gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;Component: Network<br>
> &gt; &nbsp; &nbsp; &nbsp; &nbsp; AssignedTo: <a
> href="mailto:jgarzik@pobox.com">jgarzik@pobox.com</a><br>
> &gt; &nbsp; &nbsp; &nbsp; &nbsp; ReportedBy: <a
> href="mailto:Manfred.Scherer.Mhm@t-online.de">Manfred.Scherer.Mhm@t-online.de</a><br>
> &gt;<br>
> &gt;<br>
> &gt; Latest working kernel version: 2.6.26<br>
> &gt; Earliest failing kernel version: 2.6.27<br>
> <br>
> A 2.6.27 regression.<br>
> <br>
> Not much has happened in tlan.c - a single fix from Robert. &nbsp;This<br>
> regression might be in pppoe?<br>
> <br>
> <br>
> &gt; Distribution: SuSE 9.2<br>
> &gt; Hardware Environment:<br>
> &gt; /var/log/boot.msg:<br>
> &gt; &lt;6&gt;ThunderLAN driver v1.15<br>
> &gt; &lt;6&gt;tlan 0000:00:0d.0: found PCI INT A -&gt; IRQ 11<br>
> &gt; &lt;6&gt;tlan 0000:00:0d.0: sharing IRQ 11 with 0000:00:09.0<br>
> &gt; &lt;6&gt;TLAN: eth1 irq=11, io=c400, Compaq Netelligent 10/100 TX PCI UTP,
> Rev. 16<br>
> &gt; &lt;6&gt;TLAN: 1 device installed, PCI: 1 &nbsp;EISA: 0<br>
> &gt; ...<br>
> &gt; Setting up network interfaces:<br>
> &gt; &nbsp; &nbsp; lo<br>
> &gt; &nbsp; &nbsp; lo &nbsp; &nbsp; &nbsp; &nbsp;IP address: <a
> href="http://127.0.0.1/8" target="_blank">127.0.0.1/8</a><br>
> &gt; done &nbsp; &nbsp;eth0 &nbsp; &nbsp; &nbsp;device: Realtek Semiconductor
> Co., Ltd. RTL-8029(AS)<br>
> &gt; &nbsp; &nbsp; eth0 &nbsp; &nbsp; &nbsp;configuration:
> eth-id-52:54:00:db:15:ff<br>
> &gt; &nbsp; &nbsp; eth0 &nbsp; &nbsp; &nbsp;IP address: <a
> href="http://192.168.0.99/24" target="_blank">192.168.0.99/24</a><br>
> &gt; done &nbsp; &nbsp;eth1 &nbsp; &nbsp; &nbsp;device: Compaq Computer
> Corporation Compaq Netelligent 10/100<br>
> &gt; TX PCI UTP TLAN 2.3 (rev 10)<br>
> &gt; &nbsp; &nbsp; eth1 &nbsp; &nbsp; &nbsp;IP address: <a
> href="http://192.168.1.22/24" target="_blank">192.168.1.22/24</a><br>
> &gt; done &nbsp; &nbsp;dsl0<br>
> &gt; &nbsp; &nbsp; dsl0 &nbsp; &nbsp; &nbsp;Startmode is &#39;manual&#39;<br>
> &gt;<br>
> &gt;<br>
> &gt; Software Environment:<br>
> &gt;<br>
> &gt; Problem Description:<br>
> &gt;<br>
> &gt; PPPoe does not work<br>
> &gt; see /var/log/messages:<br>
> &gt;<br>
> &gt; Oct 13 14:39:06 pc1 pppd[10123]: Plugin rp-pppoe.so loaded.<br>
> &gt; Oct 13 14:39:06 pc1 kernel: PPP generic driver version 2.4.2<br>
> &gt; Oct 13 14:39:06 pc1 pppd[10123]: RP-PPPoE plugin version 3.3 compiled
> against<br>
> &gt; pp<br>
> &gt; pd 2.4.2<br>
> &gt; Oct 13 14:39:06 pc1 pppd[10123]: Plugin passwordfd.so loaded.<br>
> &gt; Oct 13 14:39:06 pc1 kernel: NET: Registered protocol family 17<br>
> &gt; Oct 13 14:39:06 pc1 pppd[10123]: pppd 2.4.2 started by root, uid 0<br>
> &gt; Oct 13 14:39:41 pc1 pppd[10123]: Timeout waiting for PADO packets<br>
> &gt; Oct 13 14:39:41 pc1 pppd[10123]: Unable to complete PPPoE Discovery<br>
> &gt; Oct 13 14:39:41 pc1 pppd[10123]: Exit.<br>
> &gt;<br>
> &gt;<br>
> &gt; Steps to reproduce:<br>
> &gt;<br>
> &gt; start dsl-connection to internet.<br>
> &gt;<br>
> <br>
> </blockquote></div><br></div>
> 
> 

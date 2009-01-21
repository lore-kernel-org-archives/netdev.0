From: Ingo Molnar <mingo@elte.hu>
Subject: Re: e1000e regression (interface hang) with latest -git
Date: Wed, 21 Jan 2009 19:25:04 +0100
Message-ID: <20090121182504.GA14259@elte.hu>
References: <20090121102840.GA24967@elte.hu> <8DD2590731AB5D4C9DBF71A877482A900DABEA6F@orsmsx509.amr.corp.intel.com> <20090121175158.GA7302@elte.hu> <20090121180344.GA13675@elte.hu> <Pine.WNT.4.64.0901211010250.6372@ppwaskie-MOBL2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Allan, Bruce W" <bruce.w.allan@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:47967 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753133AbZAUSZN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jan 2009 13:25:13 -0500
Content-Disposition: inline
In-Reply-To: <Pine.WNT.4.64.0901211010250.6372@ppwaskie-MOBL2.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Waskiewicz Jr, Peter P <peter.p.waskiewicz.jr@intel.com> wrote:

> > * Ingo Molnar <mingo@elte.hu> wrote:
> > 
> > > The same point remains though: it worked before (and works fine with a 
> > > distro kernel, 2.6.28-0.140.rc9.git1.fc11.x86_64) and doesnt work with 
> > > latest -git.
> > > 
> > > I'll capture some debug data and send it to you.
> > 
> > find attached the debug data:
> > 
> >   ethtool.dump.eth0.before
> >   ethtool.dump.eth0.after
> >   ethtool.dump.eth0.after2
> >   boot.log
> >   config
> > 
> > the 'before' dump is before the hang, shortly after bootup. It also 
> > includes 'ifconfig eth0' output.
> > 
> > the 'after' dump is after the hang - while the interface is hung.
> > 
> > 'after2' dump is after a 'service network restart' - which brought the 
> > interface back.
> > 
> > Note if i wait long enough (half an hour or so), then not even 'service 
> > network restart' will bring back the device.
> > 
> > The kernel i tested is: v2.6.29-rc2-13-gf3b8436
> 
> As Bruce stated, this is an igb issue, not e1000e.  From your boot.log:

(yes, as i said it too two mails ago - it is an igb.)

> igb: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX
> igb: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX
> 
> One other piece of info (in addition to what Bruce requested) that would 
> be useful is after you've done ifconfig eht0 up, cat /proc/interrupts | 
> grep eth0 and send that output (I want to see your MSI-X configuration).

here it is:

 79:         35          0       9836       7451       1197       1360        766          0       2196        995        770          0       2051        863       4714       1879   PCI-MSI-edge      eth0-tx-0
 80:       2335          0       2718       3651       5024       9850        533          0       1405       1095          0          0       4421       1229          0       2002   PCI-MSI-edge      eth0-tx-1
 81:         33          0          0       5478       1125       6585       4865       6306          0          0          0        714       3757          0       2662       1020   PCI-MSI-edge      eth0-tx-2
 82:         21       1428       3136       3783       4249       6833          0          0       4175          0          0       1465       1940       1780       6286          0   PCI-MSI-edge      eth0-tx-3
 83:         40          0          0       4788          0       1486          0       7185       3998       8637       1409       6785          0          0          0      10060   PCI-MSI-edge      eth0-rx-0
 84:         70       1441       2606       1342          0       1678       4301       1839          0       6507       6910      16470          0       1484       1004          0   PCI-MSI-edge      eth0-rx-1
 85:         40       1368          0       3560       5022       2040          5       1719          0       2037        956         40          0      17264       6456       2833   PCI-MSI-edge      eth0-rx-2
 86:         44        414          5       1164         30       4513       4595       1542          0      10033       1151          0       4961       4203          0      10703   PCI-MSI-edge      eth0-rx-3
 87:          1          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0   PCI-MSI-edge      eth0

	Ingo

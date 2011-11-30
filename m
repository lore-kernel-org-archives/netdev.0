From: Chris Wright <chrisw@redhat.com>
Subject: Re: [net-next-2.6 PATCH 0/6 v4] macvlan: MAC Address filtering
 support for passthru mode
Date: Wed, 30 Nov 2011 15:39:26 -0800
Message-ID: <20111130233926.GF29071@x200.localdomain>
References: <1321638038.2883.28.camel@bwh-desktop>
 <4ECA8D50.9080603@intel.com>
 <1322584544.2684.20.camel@bwh-desktop>
 <1322587170.2684.26.camel@bwh-desktop>
 <4ED6691D.9070606@intel.com>
 <1322678890.2762.26.camel@bwh-desktop>
 <20111130210454.GC29071@x200.localdomain>
 <1322688843.2762.45.camel@bwh-desktop>
 <20111130230049.GE29071@x200.localdomain>
 <4ED6BCA6.8040701@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Wright <chrisw@redhat.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Roopa Prabhu <roprabhu@cisco.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"dragos.tatulea@gmail.com" <dragos.tatulea@gmail.com>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"arnd@arndb.de" <arnd@arndb.de>, "mst@redhat.com" <mst@redhat.com>,
	"mchan@broadcom.com" <mchan@broadcom.com>,
	"dwang2@cisco.com" <dwang2@cisco.com>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"benve@cisco.com" <benve@cisco.com>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46841 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752283Ab1K3Xjl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Nov 2011 18:39:41 -0500
Content-Disposition: inline
In-Reply-To: <4ED6BCA6.8040701@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Sridhar Samudrala (sri@us.ibm.com) wrote:
> On 11/30/2011 3:00 PM, Chris Wright wrote:
> >        physical port
> >              |
> >+------------+------------+
> >|         +-----+         |
> >|         | VEB |         |
> >|         +-----+         |
> >|        /   |   \        |
> >|       /    |    \       |
> >|      /     |     \      |
> >+-----+------+------+-----+
> >       |      |       |
> >      PF    VF 1    VF 2
> >      /       |       |
> >  +---+---+  VM4  +---+---+
> >  |  sw   |       |macvtap|
> >  | switch|       +---+---+
> >  +-+-+-+-+           |
> >    / | \            VM5
> >   /  |  \
> >VM1 VM2 VM3
> >
> >This has VMs 1-3 hanging of the PF via a linux bridge (traditional hv
> >switching), VM4 directly owning VF1 (pci device assignement), and VM5
> >indirectly owning VF2 (macvtap passthrough, that started this whole
> >thing).
> >
> >So, I'm understanding you saying that VM4 or VM4 sending a packet to VM1
> >goes in to VEB, out PF, and into linux bridging code, rigth?  At which
> >point the PF is in promiscuous mode (btw, same does not work if bridge is
> >attached to VF, at least for some VFs, due to lack of promiscuous mode).
> >
> >>Packets sent from a guest with a VF to the address of another guest with
> >>a VF need to be forwarded similarly, but the driver should be able to
> >>infer that from (3).
> >Right, and that works currently for the case where both guests are like
> >VM4, they directly own the VF via PCI device assignement.  But for VM4
> >to talk to VM5, VF3 is not in promiscuous mode and has a different MAC
> >address than VM5's vNIC.  If the embedded bridge does not learn, and
> >nobody programmed it to fwd frames for VM5 via VF3...
> I think you are referring to VF2. There is no VF3 in your picture.

*sigh*  (also meant 'VM4 or VM5' up above, not 'VM4 or VM4')...

> In macvtap passthru mode, VF2 will be set to the same mac address as VM5's
> MAC.  So VM4 should be be able to talk to VM5.

yes (i think macvtap in bridging or vepa mode w/ single VM has that issue,
not passthru)

> >I believe this is what Roopa's patch will allow.  The question now is
> >whether there's a better way to handle this?
> My understanding is that Roopa's patch will allow setting additional mac
> addresses to
> VM5 without the need to put VF5 in promiscous mode.

Thanks for your corrections Sridar.

cheers,
-chris

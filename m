From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [patch net-next v6 4/4] igb/igbvf: implement
 ndo_get_phys_port_id
Date: Wed, 28 Aug 2013 02:26:28 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B73070A38@ORSMSX101.amr.corp.intel.com>
References: <1375114612-537-1-git-send-email-jiri@resnulli.us>
 <1375114612-537-5-git-send-email-jiri@resnulli.us>
 <1377167950.3939.57.camel@jtkirshe-mobl>
 <20130822131019.GB1421@minipsycho.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"Narendra_K@Dell.com" <Narendra_K@Dell.com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"or.gerlitz@gmail.com" <or.gerlitz@gmail.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	"amwang@redhat.com" <amwang@redhat.com>,
	"johannes@sipsolutions.net" <johannes@sipsolutions.net>
To: Jiri Pirko <jiri@resnulli.us>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:56419 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752113Ab3H1C0b convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 22:26:31 -0400
In-Reply-To: <20130822131019.GB1421@minipsycho.brq.redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry, I was out sick towards the end of last week and playing catch up for the last few days...  Info inline.

> From: Jiri Pirko [mailto:jiri@resnulli.us]
> Sent: Thursday, August 22, 2013 6:10 AM
> To: Kirsher, Jeffrey T
> Cc: Brown, Aaron F; netdev@vger.kernel.org; davem@davemloft.net;
> stephen@networkplumber.org; Narendra_K@Dell.com;
> bhutchings@solarflare.com; or.gerlitz@gmail.com; Wyborny, Carolyn; Rose,
> Gregory V; vyasevic@redhat.com; amwang@redhat.com;
> johannes@sipsolutions.net
> Subject: Re: [patch net-next v6 4/4] igb/igbvf: implement
> ndo_get_phys_port_id
> 
> Thu, Aug 22, 2013 at 12:39:10PM CEST, jeffrey.t.kirsher@intel.com wrote:
> >On Mon, 2013-07-29 at 18:16 +0200, Jiri Pirko wrote:
> >> igb driver generated random number which will identify physical port.
> >> This id is available via ndo_get_phys_port_id directly on igb netdev.
> >> Also, id is passed to igbvf using mailbox. After that, it is
> >> available via ndo_get_phys_port_id on igbvf netdev as well.
> >>
> >> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> >> ---
> >>  drivers/net/ethernet/intel/igb/e1000_mbx.h |  1 +
> >>  drivers/net/ethernet/intel/igb/igb.h       |  3 +++
> >>  drivers/net/ethernet/intel/igb/igb_main.c  | 37
> >> ++++++++++++++++++++++++++++-
> >>  drivers/net/ethernet/intel/igbvf/igbvf.h   |  4 ++++
> >>  drivers/net/ethernet/intel/igbvf/mbx.h     |  1 +
> >>  drivers/net/ethernet/intel/igbvf/netdev.c  | 38
> >> ++++++++++++++++++++++++++++++
> >>  drivers/net/ethernet/intel/igbvf/vf.c      | 34
> >> ++++++++++++++++++++++++++
> >>  drivers/net/ethernet/intel/igbvf/vf.h      |  1 +
> >>  8 files changed, 118 insertions(+), 1 deletion(-)
> >
> >Jiri-
> >
> >Validation ran into a couple of issues with this patch.  Here is what
> >Aaron found when testing this patch...
> 
> Interesting. So since igbvf_refresh_ppid() is called from igbvf_reset()
> and igbvf_probe(), I believed that is enough. Looks like perm_addr getting
> works in similar way. Can you please check if perm_addr is set correctly
> in the same time reading phys_port_id gives -EOPNOTSUPP?

By perm_addr do you mean the MAC Address of the vf?  Yes, it is set up (and I can view it vi ip link or sysconfig) when I see the op not supported message (after I fi vfs via sysfs, before bringing the vf interface up or reloading igbvf.)

> 
> 
> >
> >Aaron Brown wrote:
> >I think I have to fail this, it seems to have an issue with
> >initialization.  When I first create a vf via sysfs the pys_port_id
> >file is created along with the other sysfs files for the vf, however an
> >attempt to cat out the value returns " Operation not supported".  At
> >this point the vf is still down, if I bring it up (or simply unload /
> >reload the igbvf driver) I can then cat the file successfully and the
> >vf interface phys_port_id matches the phys_port_id of the pf.  This is
> >testing from bare metal, a console session showing this behavior
> >follows:
> >
> >u1304:[0]/sys> find . -iname phys_port_id
> >./devices/pci0000:00/0000:00:01.0/0000:07:00.0/net/eth0/phys_port_id
> >./devices/pci0000:00/0000:00:01.0/0000:07:00.1/net/eth1/phys_port_id
> >./devices/virtual/net/sit0/phys_port_id
> >./devices/virtual/net/lo/phys_port_id
> >u1304:[0]/sys> cat
> >devices/pci0000:00/0000:00:01.0/0000:07:00.0/net/eth0/phys_port_id
> >5ece9fbd9cd51546982e15c1f2c11e25
> >u1304:[0]/sys>
> >
> >So far so good, now make a few vfs and check for new phys_port_id sysfs
> files.
> >
> >u1304:[0]/sys> find . -iname sriov_numvfs
> >./devices/pci0000:00/0000:00:01.0/0000:07:00.0/sriov_numvfs
> >./devices/pci0000:00/0000:00:01.0/0000:07:00.1/sriov_numvfs
> >u1304:[0]/sys> echo 2 >
> devices/pci0000:00/0000:00:01.0/0000:07:00.0/sriov_numvfs
> >u1304:[0]/sys> find . -iname phys_port_id
> ./devices/pci0000:00/0000:00:01.0/0000:07:00.0/net/eth0/phys_port_id
> >./devices/pci0000:00/0000:00:01.0/0000:07:00.1/net/eth1/phys_port_id
> >./devices/pci0000:00/0000:00:01.0/0000:07:10.0/net/eth2/phys_port_id
> >./devices/pci0000:00/0000:00:01.0/0000:07:10.2/net/eth3/phys_port_id
> >./devices/virtual/net/sit0/phys_port_id
> >./devices/virtual/net/lo/phys_port_id
> >u1304:[0]/sys>
> >
> >The first vf is eth2, attempt to cat out it's phys_port_id
> >
> >u1304:[0]/sys> cat
> >./devices/pci0000:00/0000:00:01.0/0000:07:10.0/net/eth2/phys_port_id
> >cat:
> >./devices/pci0000:00/0000:00:01.0/0000:07:10.0/net/eth2/phys_port_id:
> >Operation not supported u1304:[0]/sys>
> >
> >But, if I bring the interface up (or unload / load the igbvf driver) I
> then am able to cat the phys_port_id of the vf and it matches the
> phys_port_id of the physical interface.
> >
> >u1304:[0]/sys> ifconfig eth2 u1304-2
> >u1304:[0]/sys> cat
> >./devices/pci0000:00/0000:00:01.0/0000:07:10.0/net/eth2/phys_port_id
> >5ece9fbd9cd51546982e15c1f2c11e25
> >u1304:[0]/sys>
> 

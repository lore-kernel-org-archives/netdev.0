From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v6 4/4] igb/igbvf: implement ndo_get_phys_port_id
Date: Fri, 21 Feb 2014 09:02:21 +0100
Message-ID: <20140221080221.GA2870@minipsycho.orion>
References: <1375114612-537-1-git-send-email-jiri@resnulli.us>
 <1375114612-537-5-git-send-email-jiri@resnulli.us>
 <1377167950.3939.57.camel@jtkirshe-mobl>
 <20130822131019.GB1421@minipsycho.brq.redhat.com>
 <309B89C4C689E141A5FF6A0C5FB2118B73070A38@ORSMSX101.amr.corp.intel.com>
 <20130828060558.GA1589@minipsycho.orion>
 <309B89C4C689E141A5FF6A0C5FB2118B73071317@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
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
To: "Brown, Aaron F" <aaron.f.brown@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f44.google.com ([74.125.83.44]:56033 "EHLO
	mail-ee0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753017AbaBUIC2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 03:02:28 -0500
Received: by mail-ee0-f44.google.com with SMTP id c13so1412367eek.17
        for <netdev@vger.kernel.org>; Fri, 21 Feb 2014 00:02:27 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <309B89C4C689E141A5FF6A0C5FB2118B73071317@ORSMSX101.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Aug 28, 2013 at 09:06:27PM CEST, aaron.f.brown@intel.com wrote:
>
>
>> -----Original Message-----
>> From: Jiri Pirko [mailto:jiri@resnulli.us]
>> Sent: Tuesday, August 27, 2013 11:06 PM
>> To: Brown, Aaron F
>> Cc: Kirsher, Jeffrey T; netdev@vger.kernel.org; davem@davemloft.net;
>> stephen@networkplumber.org; Narendra_K@Dell.com;
>> bhutchings@solarflare.com; or.gerlitz@gmail.com; Wyborny, Carolyn; Rose,
>> Gregory V; vyasevic@redhat.com; amwang@redhat.com;
>> johannes@sipsolutions.net
>> Subject: Re: [patch net-next v6 4/4] igb/igbvf: implement
>> ndo_get_phys_port_id
>> 
>> Wed, Aug 28, 2013 at 04:26:28AM CEST, aaron.f.brown@intel.com wrote:
>> >Sorry, I was out sick towards the end of last week and playing catch up
>> for the last few days...  Info inline.
>> >
>> >> From: Jiri Pirko [mailto:jiri@resnulli.us]
>> >> Sent: Thursday, August 22, 2013 6:10 AM
>> >> To: Kirsher, Jeffrey T
>> >> Cc: Brown, Aaron F; netdev@vger.kernel.org; davem@davemloft.net;
>> >> stephen@networkplumber.org; Narendra_K@Dell.com;
>> >> bhutchings@solarflare.com; or.gerlitz@gmail.com; Wyborny, Carolyn;
>> >> Rose, Gregory V; vyasevic@redhat.com; amwang@redhat.com;
>> >> johannes@sipsolutions.net
>> >> Subject: Re: [patch net-next v6 4/4] igb/igbvf: implement
>> >> ndo_get_phys_port_id
>> >>
>> >> Thu, Aug 22, 2013 at 12:39:10PM CEST, jeffrey.t.kirsher@intel.com
>> wrote:
>> >> >On Mon, 2013-07-29 at 18:16 +0200, Jiri Pirko wrote:
>> >> >> igb driver generated random number which will identify physical
>> port.
>> >> >> This id is available via ndo_get_phys_port_id directly on igb
>> netdev.
>> >> >> Also, id is passed to igbvf using mailbox. After that, it is
>> >> >> available via ndo_get_phys_port_id on igbvf netdev as well.
>> >> >>
>> >> >> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> >> >> ---
>> >> >>  drivers/net/ethernet/intel/igb/e1000_mbx.h |  1 +
>> >> >>  drivers/net/ethernet/intel/igb/igb.h       |  3 +++
>> >> >>  drivers/net/ethernet/intel/igb/igb_main.c  | 37
>> >> >> ++++++++++++++++++++++++++++-
>> >> >>  drivers/net/ethernet/intel/igbvf/igbvf.h   |  4 ++++
>> >> >>  drivers/net/ethernet/intel/igbvf/mbx.h     |  1 +
>> >> >>  drivers/net/ethernet/intel/igbvf/netdev.c  | 38
>> >> >> ++++++++++++++++++++++++++++++
>> >> >>  drivers/net/ethernet/intel/igbvf/vf.c      | 34
>> >> >> ++++++++++++++++++++++++++
>> >> >>  drivers/net/ethernet/intel/igbvf/vf.h      |  1 +
>> >> >>  8 files changed, 118 insertions(+), 1 deletion(-)
>> >> >
>> >> >Jiri-
>> >> >
>> >> >Validation ran into a couple of issues with this patch.  Here is
>> >> >what Aaron found when testing this patch...
>> >>
>> >> Interesting. So since igbvf_refresh_ppid() is called from
>> >> igbvf_reset() and igbvf_probe(), I believed that is enough. Looks
>> >> like perm_addr getting works in similar way. Can you please check if
>> >> perm_addr is set correctly in the same time reading phys_port_id gives
>> -EOPNOTSUPP?
>> >
>> >By perm_addr do you mean the MAC Address of the vf?  Yes, it is set up
>> >(and I can view it vi ip link or sysconfig) when I see the op not
>> >supported message (after I fi vfs via sysfs, before bringing the vf
>> >interface up or reloading igbvf.)
>> 
>> Can you please send me dmesg log from the system you are testing this?
>
>Attached, dmesg dump from a fresh boot to the eopnosupp. I've been using a .config with a whole bunch of debug junk in it and this is putting out tons of kobject messages, I can re-build and send something with less junk if it's pushing anything relevant off the top.


Hi Aaron, sorry for delay. I failed to find any error message related to
igb in the dmesg you attached. Can you please tell me what exact line do
you have in mind?

>
>> 
>> Looking at the code, it looks like whenever mac.ops.reset_hw() (which sets
>> up mac) is called, igbvf_refresh_ppid() is called as well.
>> 
>> Thanks
>> 
>> >
>> >>
>> >>
>> >> >
>> >> >Aaron Brown wrote:
>> >> >I think I have to fail this, it seems to have an issue with
>> >> >initialization.  When I first create a vf via sysfs the pys_port_id
>> >> >file is created along with the other sysfs files for the vf, however
>> >> >an attempt to cat out the value returns " Operation not supported".
>> >> >At this point the vf is still down, if I bring it up (or simply
>> >> >unload / reload the igbvf driver) I can then cat the file
>> >> >successfully and the vf interface phys_port_id matches the
>> >> >phys_port_id of the pf.  This is testing from bare metal, a console
>> >> >session showing this behavior
>> >> >follows:
>> >> >
>> >> >u1304:[0]/sys> find . -iname phys_port_id
>> >> >./devices/pci0000:00/0000:00:01.0/0000:07:00.0/net/eth0/phys_port_id
>> >> >./devices/pci0000:00/0000:00:01.0/0000:07:00.1/net/eth1/phys_port_id
>> >> >./devices/virtual/net/sit0/phys_port_id
>> >> >./devices/virtual/net/lo/phys_port_id
>> >> >u1304:[0]/sys> cat
>> >> >devices/pci0000:00/0000:00:01.0/0000:07:00.0/net/eth0/phys_port_id
>> >> >5ece9fbd9cd51546982e15c1f2c11e25
>> >> >u1304:[0]/sys>
>> >> >
>> >> >So far so good, now make a few vfs and check for new phys_port_id
>> >> >sysfs
>> >> files.
>> >> >
>> >> >u1304:[0]/sys> find . -iname sriov_numvfs
>> >> >./devices/pci0000:00/0000:00:01.0/0000:07:00.0/sriov_numvfs
>> >> >./devices/pci0000:00/0000:00:01.0/0000:07:00.1/sriov_numvfs
>> >> >u1304:[0]/sys> echo 2 >
>> >> devices/pci0000:00/0000:00:01.0/0000:07:00.0/sriov_numvfs
>> >> >u1304:[0]/sys> find . -iname phys_port_id
>> >> ./devices/pci0000:00/0000:00:01.0/0000:07:00.0/net/eth0/phys_port_id
>> >> >./devices/pci0000:00/0000:00:01.0/0000:07:00.1/net/eth1/phys_port_id
>> >> >./devices/pci0000:00/0000:00:01.0/0000:07:10.0/net/eth2/phys_port_id
>> >> >./devices/pci0000:00/0000:00:01.0/0000:07:10.2/net/eth3/phys_port_id
>> >> >./devices/virtual/net/sit0/phys_port_id
>> >> >./devices/virtual/net/lo/phys_port_id
>> >> >u1304:[0]/sys>
>> >> >
>> >> >The first vf is eth2, attempt to cat out it's phys_port_id
>> >> >
>> >> >u1304:[0]/sys> cat
>> >> >./devices/pci0000:00/0000:00:01.0/0000:07:10.0/net/eth2/phys_port_id
>> >> >cat:
>> >> >./devices/pci0000:00/0000:00:01.0/0000:07:10.0/net/eth2/phys_port_id:
>> >> >Operation not supported u1304:[0]/sys>
>> >> >
>> >> >But, if I bring the interface up (or unload / load the igbvf driver)
>> >> >I
>> >> then am able to cat the phys_port_id of the vf and it matches the
>> >> phys_port_id of the physical interface.
>> >> >
>> >> >u1304:[0]/sys> ifconfig eth2 u1304-2 u1304:[0]/sys> cat
>> >> >./devices/pci0000:00/0000:00:01.0/0000:07:10.0/net/eth2/phys_port_id
>> >> >5ece9fbd9cd51546982e15c1f2c11e25
>> >> >u1304:[0]/sys>
>> >>
>> >

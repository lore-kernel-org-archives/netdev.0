From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH net-next] sysfs: add entry to indicate network interfaces with random MAC address
Date: Thu, 22 Jul 2010 17:26:09 -0700
Message-ID: <2408F875-69BE-45D3-8605-4AE5CDA4601C@chelsio.com>
References: <20100721150732.GR7497@gospo.rdu.redhat.com> <20100721102816.4bef5ada@nehalam> <20100721.103249.107094774.davem@davemloft.net> <201007211129.48288.leedom@chelsio.com> <43F901BD926A4E43B106BF17856F0755F184620A@orsmsx508.amr.corp.intel.com> <4C47EAF3.3080602@redhat.com>
Mime-Version: 1.0 (Apple Message framework v1081)
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Rose, Gregory V" <gregory.v.rose@intel.com>,
	David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	andy@greyhouse.net, harald@redhat.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	gospo@redhat.com,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>
To: Stefan Assmann <sassmann@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:12881 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754994Ab0GWA02 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 20:26:28 -0400
In-Reply-To: <4C47EAF3.3080602@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Jul 21, 2010, at 11:53 PM, Stefan Assmann wrote:

> Using the VF in the host is a feature and I'm sure people will think =
of
> ways to make good use of it. However the actual problem we've seen is=
 a
> more practical one. So to pass-through a VF to a VM the host has to b=
e
> aware that the VF exists. Therefore you usually have to enable the VF=
 in
> the host (i.e. specify the max_vfs parameter). The device will be
> discovered by the system and because of the random MAC address udev
> ignores the new device. With the additional information we provide wi=
th
> our solution udev will be able to recognize the device by it's "devic=
e
> path" and handle it properly (until you decide to pass it to a VM or
> just be happy with it in the host).

 Or you simply don't have the VF Driver loaded in the "Domain 0" Contro=
l OS.  When we install the cxgb4 PF Driver with "num_vf=3D..." this ena=
bles the PCI-E SR-IOV Capabilities within the various PFs and the corre=
sponding VF PCI Devices are instantiated and discovered by the Domain 0=
 Linux OS.  But without a cxgb4vf VF Driver loaded, those devices just =
sit there =96 available for "Device Assignment" to VMs.

> Remember the issue that lead to the proposal of renaming VFs to vfeth=
?
> That's exactly the problem we try to fix. Additional benefit of an
> "address assignment type" as Ben likes to call it would be the handli=
ng
> of MAC address stealing NICs.

 The above was mostly to cope with some SR-IOV Drivers using random MAC=
 addresses for the VFs.

Casey
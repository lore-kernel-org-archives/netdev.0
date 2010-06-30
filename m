From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] igbvf: avoid name clash between PF and VF
Date: Wed, 30 Jun 2010 11:44:39 +0100
Message-ID: <1277894679.28819.60.camel@localhost>
References: <4C2B0614.9040004@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, e1000-devel@lists.sourceforge.net,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	gregory.v.rose@intel.com, jeffrey.t.kirsher@intel.com,
	Andy Gospodarek <gospo@redhat.com>
To: Stefan Assmann <sassmann@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:53572 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752367Ab0F3Koo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 06:44:44 -0400
In-Reply-To: <4C2B0614.9040004@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-06-30 at 10:53 +0200, Stefan Assmann wrote:
> From: Stefan Assmann <sassmann@redhat.com>
> 
> It looks like the VFs get initialized before all the PFs are. Therefore
> the udev mapping MAC <-> ethX (for PFs) gets screwed because the VFs
> may grab the ethX interface names (reserved by udev) for the PFs.
> 
> Example:
> igb max_vfs=0
> eth0      Link encap:Ethernet  HWaddr 00:13:20:F7:A5:9E
> eth1      Link encap:Ethernet  HWaddr 00:13:20:F7:A5:9F
> eth2      Link encap:Ethernet  HWaddr 00:13:20:F7:A5:A0
> eth3      Link encap:Ethernet  HWaddr 00:13:20:F7:A5:A1
> igb max_vfs=1
> eth0      Link encap:Ethernet  HWaddr 00:13:20:F7:A5:9E
> eth1      Link encap:Ethernet  HWaddr 0A:CF:41:69:F7:A9
> eth2      Link encap:Ethernet  HWaddr 3A:FE:20:4C:2A:3B
> eth3      Link encap:Ethernet  HWaddr C6:C3:B1:56:C9:A4
> eth3_rename Link encap:Ethernet  HWaddr 00:13:20:F7:A5:9F
> eth4      Link encap:Ethernet  HWaddr 6E:8A:8A:A3:5F:69
> eth4_rename Link encap:Ethernet  HWaddr 00:13:20:F7:A5:A0
> eth5_rename Link encap:Ethernet  HWaddr 00:13:20:F7:A5:A1
> 
> In the example above VF 0A:CF:41:69:F7:A9 grabs eth1 but udev
> has a rule that says eth1 should be assigned PF 00:13:20:F7:A5:9F
> (eth3_rename) and waits for the VF to disappear to rename eth3_rename
> to eth1. Unfortunately eth1 is not going to disappear.
> This is not a udev bug since udev doesn't create persistent rules for
> VFs as their MAC address changes every reboot.
[...]

I think it is a bug in the udev rules: udev should rename the VFs even
though their names won't be persistent.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


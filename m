From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding:update speed/duplex for NETDEV_CHANGE
Date: Mon, 31 Oct 2011 14:23:08 -0700
Message-ID: <16441.1320096188@death>
References: <4EAE0D9A.9060408@gmail.com> <e00468a2cbb8a25d7a89028e876769449454309f.1320070684.git.wpan@redhat.com> <1320084906.2735.9.camel@bwh-desktop> <14973.1320093129@death> <1320094108.2735.15.camel@bwh-desktop>
Cc: Weiping Pan <wpan@redhat.com>, netdev@vger.kernel.org,
	andy@greyhouse.net, linux-kernel@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <1320094108.2735.15.camel@bwh-desktop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Hutchings <bhutchings@solarflare.com> wrote:

>On Mon, 2011-10-31 at 13:32 -0700, Jay Vosburgh wrote:
>[...]
>> 	This particular case arises only during enslavement.  The call
>> to bond_update_speed_duplex call has failed, but the device is marked by
>> bonding to be up.  Bonding complains that the device isn't down, but it
>> cannot get speed and duplex, and therefore is assuming them to be
>> 100/Full.
>> 
>> 	The catch is that this happens only for the ARP monitor, because
>> it initially presumes a slave to be up regardless of actual carrier
>> state (for historical reasons related to very old 10 or 10/100 drivers,
>> prior to the introduction of netif_carrier_*).
>
>Right, I gathered that.  Is there any reason to use the ARP monitor when
>all slaves support link state notification?  Maybe the bonding
>documentation should recommend miimon in section 7, not just in section
>2.

	The ARP monitor can validate that traffic actually flows from
the slave to some destination in the switch domain (and back), so, for
example, it's useful in cases that multiple switch hops exist between
the host and the local router.  A link failure in the middle of the path
won't affect carrier on the local device, but still may cause a
communications break.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com

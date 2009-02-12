From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/3] tun: Limit amount of queued packets per device
Date: Thu, 12 Feb 2009 19:13:13 +0800
Message-ID: <20090212111313.GD13859@gondor.apana.org.au>
References: <20090204104825.GA21257@gondor.apana.org.au> <E1LUfJt-0005ZQ-4D@gondolin.me.apana.org.au> <1234290825.25178.100.camel@bling>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Alex Williamson <alex.williamson@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:54486 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754587AbZBLLNW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2009 06:13:22 -0500
Content-Disposition: inline
In-Reply-To: <1234290825.25178.100.camel@bling>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 10, 2009 at 11:33:45AM -0700, Alex Williamson wrote:
> 
> I'm getting a variety of Oopses, null pointer derefs, etc... from this
> patch when trying to run a qemu guest on net-next-2.6 using a standard
> tap/bridge config.  I've included a sample below.  Thanks,

Are you using the current net-next-2.6 (which already has the
patch) or an older net-next-2.6 with the patch added by hand?

> [  173.231609] BUG: unable to handle kernel paging request at ffffffffffff8871
> [  173.233252] IP: [<ffffffff8044875e>] skb_copy_datagram_from_iovec+0x1e/0x260
> [  173.233252] PGD 203067 PUD 204067 PMD 0 
> [  173.233252] Oops: 0000 [#1] SMP 
> [  173.233252] last sysfs file: /sys/kernel/uevent_seqnum
> [  173.233252] CPU 5 
> [  173.233252] Modules linked in: tun nfs lockd nfs_acl auth_rpcgss sunrpc iptable_filter ip_tables ebtable_broute bridge stp ebtable_nat ebtable_filter ebtables x_tables ib_iser rdma_cm ib_cm iw_cm ib_sa ib_mad ib_core ib_addr ipv6 iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi parport_pc lp parport loop af_packet ipmi_devintf hpilo ipmi_si ipmi_msghandler iTCO_wdt iTCO_vendor_support hpwdt i5000_edac serio_raw edac_core psmouse pcspkr shpchp button container i5k_amb pci_hotplug joydev evdev ext3 jbd mbcache usbhid hid sg sd_mod ehci_hcd uhci_hcd lpfc scsi_transport_fc usbcore cciss scsi_tgt scsi_mod bnx2 dm_mirror dm_region_hash dm_log dm_snapshot dm_mod thermal processor fan thermal_sys fuse
> [  173.233252] Pid: 6770, comm: qemu-system-x86 Not tainted 2.6.29-rc3 #4
> [  173.233252] RIP: 0010:[<ffffffff8044875e>]  [<ffffffff8044875e>] skb_copy_datagram_from_iovec+0x1e/0x260
> [  173.233252] RSP: 0018:ffff880827cbfc68  EFLAGS: 00010292
> [  173.233252] RAX: 0000000000000000 RBX: ffffffffffff8809 RCX: 0000000000000148
> [  173.233252] RDX: ffff880827cbfe78 RSI: 0000000000000000 RDI: ffffffffffff8809

This means that the skb argument (RDI) is bogus.  However, I can't
see how that can happen unless some other corruption happened
earlier.

Does this occur on the first packet written?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

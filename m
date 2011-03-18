From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: LRO disable warnings on kernel 2.6.38
Date: Fri, 18 Mar 2011 09:18:22 -0700
Message-ID: <4D8385CE.1060205@intel.com>
References: <1300446743.11985.317.camel@firesoul.comx.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>
To: Jesper Dangaard Brouer <jdb@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:19861 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756853Ab1CRQSY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Mar 2011 12:18:24 -0400
In-Reply-To: <1300446743.11985.317.camel@firesoul.comx.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/18/2011 4:12 AM, Jesper Dangaard Brouer wrote:
> Hi
>
> I'm seeing the LRO disable warnings using kernel 2.6.38:
>
> [    8.664759] NET: Registered protocol family 10
> [    8.838148] ADDRCONF(NETDEV_UP): eth71: link is not ready
> [    8.872639] ------------[ cut here ]------------
> [    8.872645] WARNING: at net/core/dev.c:1363 dev_disable_lro+0x7b/0x80()
> [    8.872647] Hardware name: ProLiant DL370 G6
> [    8.872648] Modules linked in: ipv6 nf_conntrack ip_tables loop i7core_edac edac_core ipmi_si ipmi_msghandler joydev hpilo pcspkr sg hpsa igb ata_piix netxen_nic dca [last unloaded: scsi_wait_scan]
> [    8.872660] Pid: 2221, comm: sysctl Not tainted 2.6.38-comx04 #2
> [    8.872662] Call Trace:
> [    8.872671]  [<ffffffff81056e1f>] ? warn_slowpath_common+0x7f/0xc0
> [    8.872675]  [<ffffffff81056e7a>] ? warn_slowpath_null+0x1a/0x20
> [    8.872680]  [<ffffffff8140c0ab>] ? dev_disable_lro+0x7b/0x80
> [    8.872686]  [<ffffffff81474f27>] ? devinet_sysctl_forward+0x147/0x180
> [    8.872691]  [<ffffffff811872f7>] ? proc_sys_call_handler+0x97/0xd0
> [    8.872700]  [<ffffffff81187344>] ? proc_sys_write+0x14/0x20
> [    8.872704]  [<ffffffff81124148>] ? vfs_write+0xc8/0x180
> [    8.872707]  [<ffffffff81124301>] ? sys_write+0x51/0x90
> [    8.872712]  [<ffffffff8100b8c2>] ? system_call_fastpath+0x16/0x1b
> [    8.872714] ---[ end trace 6245283cb8d484cc ]---
>
> The strange part is that I didn't see this warning on my testlab and
> pre-prod servers.  The warning is from the first production server,
> which got kernel 2.6.38 deployed this morning.
>
> The NIC driver is igb.
>
> The only difference in hardware between the production and
> pre-production server (which didn't show the warning), is the
> prod-server have an extra dual-port original Intel NIC, dev-named
> "eth71".  And its just after the init of eth71, the warning occurs.
>
> We usually use a 6 port NIC from Hotlava, which is based on the same
> chip 82576 and also uses the same igb driver.
>
> Intel orig NIC eth71
>   albpd4:~# ethtool -i eth71
>   driver: igb
>   version: 2.1.0-k2
>   firmware-version: 1.2-1
>   bus-info: 0000:21:00.0
>
> Hotlava Intel chip based NIC eth51:
>   albpd4:~# ethtool -i eth51
>   driver: igb
>   version: 2.1.0-k2
>   firmware-version: 1.2-1
>   bus-info: 0000:1d:00.1
>
> I don't understand why I don't see the warning on my pre-prod server,
> which only have the Hotlava NIC?!?
>

The error doesn't make any sense for igb to be triggering since it 
doesn't support setting the NETIF_F_LRO flag in the 2.6.38 kernel.

By any chance are there any ixgbe or other interfaces in the system?  I 
would suspect the error to come from a driver that at least contains the 
NETIF_F_LRO flag.

Thanks,

Alex


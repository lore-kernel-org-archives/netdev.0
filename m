From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 3/4] e1000e: Calculate the desc_len based
	on adapter type
Date: Thu, 22 Aug 2013 03:57:24 -0700
Message-ID: <CAL3LdT4K03_4sWWFuTer0TU4nY_sqbSyjK6ETxF14kijZzmkgQ@mail.gmail.com>
References: <1369037707-27026-1-git-send-email-weiyang@linux.vnet.ibm.com>
	<1369037707-27026-4-git-send-email-weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7431472021615306583=="
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	netdev <netdev@vger.kernel.org>
To: Wei Yang <weiyang@linux.vnet.ibm.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1369037707-27026-4-git-send-email-weiyang@linux.vnet.ibm.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

--===============7431472021615306583==
Content-Type: multipart/alternative; boundary=001a11c2e2beb63c6b04e487270d

--001a11c2e2beb63c6b04e487270d
Content-Type: text/plain; charset=UTF-8

Validation ran into issues with this patch and because we could not apply
patch 4 in this series without patch 3, I have had to drop patch 3 & 4 from
my queue.

Here is what validation had to say about this patch...

Aaron Brown wrote:

This patch introduces a call trace when the interface is up and then
the mtu is set over 1500, or if the mtu is set above 1500 when the
interface is down,
the call trace appears when the interface is brought up.  The trace is
captured to demsg and /var/log/messages:
---------------------------------------------------
17:14:52 u1307 kernel: Call Trace:
17:14:52 u1307 kernel: [<ffffffff813ffaeb>] dump_stack+0x19/0x1e
17:14:52 u1307 kernel: [<ffffffff8104ae80>] __might_sleep+0xe2/0xe4
17:14:52 u1307 kernel: [<ffffffff81400e63>] down_read+0x1f/0x31
17:14:52 u1307 kernel: [<ffffffff8102c1b7>] exit_mm+0x3a/0x164
17:14:52 u1307 kernel: [<ffffffff8102da09>] do_exit+0x1ef/0x2f7
17:14:52 u1307 kernel: [<ffffffff81403bce>] oops_end+0x8f/0x94
17:14:52 u1307 kernel: [<ffffffff81020ca5>] no_context+0x1a4/0x1b3
17:14:52 u1307 kernel: [<ffffffff81020e6c>] __bad_area_nosemaphore+0x1b8/0x1d8
17:14:52 u1307 kernel: [<ffffffff81020e9a>] bad_area_nosemaphore+0xe/0x10
17:14:52 u1307 kernel: [<ffffffff81405a69>] __do_page_fault+0x44f/0x48e
17:14:52 u1307 kernel: [<ffffffff81004494>] ? print_context_stack+0xa2/0xbe
17:14:52 u1307 kernel: [<ffffffff81003488>] ? dump_trace+0x282/0x2aa
17:14:52 u1307 kernel: [<ffffffff81402bf0>] ?
_raw_spin_unlock_irqrestore+0x1d/0x3a
17:14:52 u1307 kernel: [<ffffffff81405ab1>] do_page_fault+0x9/0xb
17:14:52 u1307 kernel: [<ffffffff814031e2>] page_fault+0x22/0x30
17:14:52 u1307 kernel: [<ffffffffa00238ef>] ?
e1000_alloc_rx_buffers_ps+0x1d9/0x421 [e1000e]
17:14:52 u1307 kernel: [<ffffffffa00238a3>] ?
e1000_alloc_rx_buffers_ps+0x18d/0x421 [e1000e]
17:14:52 u1307 kernel: [<ffffffffa0022bd6>] e1000_configure+0xe7/0xf0 [e1000e]
17:14:52 u1307 kernel: [<ffffffffa0022bee>] e1000e_up+0xf/0xe7 [e1000e]
17:14:52 u1307 kernel: [<ffffffffa00282da>]
e1000_change_mtu+0x142/0x162 [e1000e]
17:14:52 u1307 kernel: [<ffffffff8135a98b>] dev_set_mtu+0x3f/0x5e
17:14:52 u1307 kernel: [<ffffffff81369280>] dev_ifsioc+0xec/0x329
17:14:52 u1307 kernel: [<ffffffff81369a24>] dev_ioctl+0x309/0x3bd
17:14:52 u1307 kernel: [<ffffffff81348035>] sock_ioctl+0x21e/0x22b
17:14:52 u1307 kernel: [<ffffffff810ce1b4>] do_vfs_ioctl+0x28e/0x2aa
17:14:52 u1307 kernel: [<ffffffff810ce217>] SyS_ioctl+0x47/0x69
17:14:52 u1307 kernel: [<ffffffff81407b12>] system_call_fastpath+0x16/0x1b
17:14:52 u1307 kernel: ------------[ cut here ]------------
17:14:52 u1307 kernel: WARNING: at kernel/softirq.c:160
local_bh_enable_ip+0x3c/0x9a()
17:14:52 u1307 kernel: Modules linked in: bridge stp llc nfsd lockd
exportfs sunrpc e1000e ptp pps_core
17:14:52 u1307 kernel: CPU: 6 PID: 5289 Comm: ifconfig Tainted: G
D      3.10.0-rc1_net-next_e1000e_2850dce_regress-11638-gb471f26 #5
17:14:52 u1307 kernel: Hardware name: Supermicro
X9SCL/X9SCM/X9SCL/X9SCM, BIOS 2.0b 09/17/2012
17:14:52 u1307 kernel: ffffffff816e7023 ffff880222b2b808
ffffffff813ffaeb ffff880222b2b848
17:14:52 u1307 kernel: ffffffff810287e6 ffffffff81a25188
0000000000000000 ffff880221f91bc0
17:14:52 u1307 kernel: ffff880221f91dd8 ffff880221f91f70
0000000000000000 ffff880222b2b858
-------------------------------------------------------------------------------

The system remains up but unstable, attempts to access the network
interface causes a hang, attempts to login to a new session on the
console sometimes hang.
This is happening with all adapters I've tried so far, 82579, 82578,
82574, ich10, ich9...



On Mon, May 20, 2013 at 1:15 AM, Wei Yang <weiyang@linux.vnet.ibm.com>wrote:

> desc_len represents the size of descriptor in rx_ring. There are two kinds
> of
> rx descriptors, e1000_rx_desc_packet_split(32 byte) and
> e1000_rx_desc_extended(16 byte). Different adapter will use different rx
> descriptors.
>
> When allocating the dma space for this descriptor in current
> implementation,
> the code ignore the descriptor type and take it as
> e1000_rx_desc_packet_split
> in any case. This behavior will not effect the function, but will require
> double size of dma space.
>
> This patch will calculate the desc_len based on the adapter type.
>
> Tested on T420, which use e1000_rx_desc_extended and works fine.
>
> Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
> ---
>  drivers/net/ethernet/intel/e1000e/netdev.c |    7 ++++++-
>  1 files changed, 6 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c
> b/drivers/net/ethernet/intel/e1000e/netdev.c
> index 5cb8321..a2e8a53 100644
> --- a/drivers/net/ethernet/intel/e1000e/netdev.c
> +++ b/drivers/net/ethernet/intel/e1000e/netdev.c
> @@ -2364,7 +2364,12 @@ int e1000e_setup_rx_resources(struct e1000_ring
> *rx_ring)
>                         goto err_pages;
>         }
>
> -       desc_len = sizeof(union e1000_rx_desc_packet_split);
> +       if (adapter->rx_ps_pages) {
> +               /* this is a 32 byte descriptor */
> +               desc_len = sizeof(union e1000_rx_desc_packet_split);
> +       } else {
> +               desc_len = sizeof(union e1000_rx_desc_extended);
> +       }
>
>         /* Round up to nearest 4K */
>         rx_ring->size = rx_ring->count * desc_len;
> --
> 1.7.5.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>



-- 
Cheers,
Jeff

--001a11c2e2beb63c6b04e487270d--


--===============7431472021615306583==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Introducing Performance Central, a new site from SourceForge and 
AppDynamics. Performance Central is your source for news, insights, 
analysis and resources for efficient Application Performance Management. 
Visit us today!
http://pubads.g.doubleclick.net/gampad/clk?id=48897511&iu=/4140/ostg.clktrk
--===============7431472021615306583==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============7431472021615306583==--

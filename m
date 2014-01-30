From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: Re: [PATCH net] e100: Fix "disabling already-disabled
 device" warning
Date: Thu, 30 Jan 2014 20:17:15 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B7314BDA5@ORSMSX101.amr.corp.intel.com>
References: <1391079064-18411-1-git-send-email-michele@acksyn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"idirectscm@aim.com" <idirectscm@aim.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "michele@acksyn.org" <michele@acksyn.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1391079064-18411-1-git-send-email-michele@acksyn.org>
Content-Language: en-US
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Thu, 2014-01-30 at 10:51 +0000, Michele Baldessari wrote:
>                              From: 
> Michele Baldessari
> <michele@acksyn.org>
>                          Reply-to: 
> Michele Baldessari
> <michele@acksyn.org>
>                                To: 
> netdev@vger.kernel.org
>                                Cc: 
> e1000-devel@lists.sourceforge.net,
> idirectscm@aim.com, David S. Miller
> <davem@davemloft.net>, Michele
> Baldessari <michele@acksyn.org>
>                           Subject: 
> [PATCH net] e100: Fix "disabling
> already-disabled device" warning
>                              Date: 
> Thu, 30 Jan 2014 10:51:04 +0000
> (14-01-30 02:51:04 AM)
> 
> 
> In https://bugzilla.redhat.com/show_bug.cgi?id=994438 and
> https://bugzilla.redhat.com/show_bug.cgi?id=970480  we
> received different reports of e100 throwing the following
> warning:
> 
>  [<c06a0ba5>] ? pci_disable_device+0x85/0x90
>  [<c044a153>] warn_slowpath_fmt+0x33/0x40
>  [<c06a0ba5>] pci_disable_device+0x85/0x90
>  [<f7fdf7e0>] __e100_shutdown+0x80/0x120 [e100]
>  [<c0476ca5>] ? check_preempt_curr+0x65/0x90
>  [<f7fdf8d6>] e100_suspend+0x16/0x30 [e100]
>  [<c06a1ebb>] pci_legacy_suspend+0x2b/0xb0
>  [<c098fc0f>] ? wait_for_completion+0x1f/0xd0
>  [<c06a2d50>] ? pci_pm_poweroff+0xb0/0xb0
>  [<c06a2de4>] pci_pm_freeze+0x94/0xa0
>  [<c0767bb7>] dpm_run_callback+0x37/0x80
>  [<c076a204>] ? pm_wakeup_pending+0xc4/0x140
>  [<c0767f12>] __device_suspend+0xb2/0x1f0
>  [<c076806f>] async_suspend+0x1f/0x90
>  [<c04706e5>] async_run_entry_fn+0x35/0x140
>  [<c0478aef>] ? wake_up_process+0x1f/0x40
>  [<c0464495>] process_one_work+0x115/0x370
>  [<c0462645>] ? start_worker+0x25/0x30
>  [<c0464dc5>] ? manage_workers.isra.27+0x1a5/0x250
>  [<c0464f6e>] worker_thread+0xfe/0x330
>  [<c0464e70>] ? manage_workers.isra.27+0x250/0x250
>  [<c046a224>] kthread+0x94/0xa0
>  [<c0997f37>] ret_from_kernel_thread+0x1b/0x28
>  [<c046a190>] ? insert_kthread_work+0x30/0x30
> 
> This patch removes pci_disable_device() from __e100_shutdown().
> pci_clear_master() is enough.
> 
> Signed-off-by: Michele Baldessari <michele@acksyn.org>
> Tested-by: Mark Harig <idirectscm@aim.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
> ---
>  drivers/net/ethernet/intel/e100.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-) 
------------------------------------------------------------------------------
WatchGuard Dimension instantly turns raw network data into actionable 
security intelligence. It gives you real-time visual feedback on key
security issues and trends.  Skip the complicated setup - simply import
a virtual appliance and go from zero to informed in seconds.
http://pubads.g.doubleclick.net/gampad/clk?id=123612991&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

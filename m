From: nick <xerofoify@gmail.com>
Subject: Re: i40e: crash on NMI by continuous module reload
Date: Fri, 27 Feb 2015 09:02:07 -0500
Message-ID: <54F078DF.5020100@gmail.com>
References: <54F07630.1010802@kpanic.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: Stefan Assmann <sassmann@kpanic.de>, netdev <netdev@vger.kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <54F07630.1010802@kpanic.de>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org



On 2015-02-27 08:50 AM, Stefan Assmann wrote:
> When unloading/loading the driver in a loop with
> modprobe -r i40e ; modprobe i40e
> after a few cycles the driver no longer successfully probes and outputs
> the following.
> [  160.171944] i40e 0000:07:00.1 eth7: adding 68:05:ca:2a:3a:41 vid=0
> [  161.271487] i40e 0000:07:00.1: set phy mask fail, aq_err -54
> [  161.685505] i40e 0000:07:00.0 eth6: NIC Link is Down
> [  161.873172] i40e 0000:07:00.1: link restart failed, aq_err=0
> [  162.401255] i40e 0000:07:00.1: PCI-Express: Speed 8.0GT/s Width x8
> [  162.710082] i40e 0000:07:00.0: add filter failed, err -54, aq_err 0
> [  162.930801] i40e 0000:07:00.1: get phy abilities failed, aq_err -54, advertised speed settings may not be correct
> [  162.977599] i40e 0000:07:00.1: Features: PF-id[1] VFs: 32 VSIs: 34 QP: 32 RX: PS RSS FD_ATR FD_SB NTUPLE PTP
> [  163.238624] i40e 0000:07:00.0 eth6: NIC Link is Down
> [  163.244566] i40e 0000:07:00.2: Initial pf_reset failed: -15
> [  163.244607] i40e: probe of 0000:07:00.2 failed with error -15
> [  163.464911] i40e 0000:07:00.3: Initial pf_reset failed: -15
> [  163.490747] i40e: probe of 0000:07:00.3 failed with error -15
> [  163.518932] i40e 0000:07:00.1: i40e_ptp_stop: removed PHC on eth7
> [  163.746713] i40e 0000:07:00.1 eth7: NIC Link is Down
> [  164.270164] i40e 0000:07:00.1: add filter failed, err -54, aq_err 0
> [...]
> [  184.462907] i40e: Copyright (c) 2013 - 2014 Intel Corporation.
> [  184.711290] i40e 0000:07:00.0: Initial pf_reset failed: -15
> [  184.736457] i40e: probe of 0000:07:00.0 failed with error -15
> [  184.983109] i40e 0000:07:00.1: Initial pf_reset failed: -15
> [  185.009354] i40e: probe of 0000:07:00.1 failed with error -15
> [  185.256612] i40e 0000:07:00.2: Initial pf_reset failed: -15
> [  185.281990] i40e: probe of 0000:07:00.2 failed with error -15
> [  185.529085] i40e 0000:07:00.3: Initial pf_reset failed: -15
> [  185.555094] i40e: probe of 0000:07:00.3 failed with error -15
> 
> Followed by
> 
> [  188.178408] NMI: IOCK error (debug interrupt?) for reason 71 on CPU 0.
> [  188.214709] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.19.0+ #81
> [  188.245187] Hardware name: HP ProLiant DL360p Gen8, BIOS P71 08/02/2014
> [  188.276847] task: ffffffff81e13480 ti: ffffffff81e00000 task.ti: ffffffff81e00000
> [  188.313671] RIP: 0010:[<ffffffff8100d45b>]  [<ffffffff8100d45b>] default_idle+0x1b/0xb0
> [  188.351779] RSP: 0018:ffffffff81e03ea8  EFLAGS: 00000246
> [  188.377118] RAX: 0000000000000000 RBX: ffffffff81e00010 RCX: 0000000000000000
> [  188.412311] RDX: ffffffff81e00000 RSI: 0000000000000000 RDI: 0000000000000000
> [  188.448563] RBP: ffffffff81e03eb8 R08: 0000000000000000 R09: 00000000fffe4047
> [  188.482137] R10: ffffffff81a0e045 R11: 0000000000000000 R12: 0000000000000000
> [  188.518089] R13: ffffffff81efd970 R14: ffffffff81e00010 R15: 0000000000000000
> [  188.553382] FS:  0000000000000000(0000) GS:ffff880237a00000(0000) knlGS:0000000000000000
> [  188.594583] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  188.621056] CR2: 00007fbcb561bc88 CR3: 0000000235966000 CR4: 00000000001406f0
> [  188.656549] Stack:
> [  188.665693]  ffffffff81e00010 ffffffff81e00010 ffffffff81e03ec8 ffffffff8100cc3a
> [  188.700062]  ffffffff81e03f48 ffffffff810884b7 ffffffff81e13480 ffff880236538910
> [  188.734638]  ffffffff81e00000 ffffffff81e00010 ffffffff81e00010 ffffffff81e00000
> [  188.773067] Call Trace:
> [  188.784412]  [<ffffffff8100cc3a>] arch_cpu_idle+0xa/0x10
> [  188.808717]  [<ffffffff810884b7>] cpu_startup_entry+0x227/0x3b0
> [  188.837221]  [<ffffffff819d0a52>] rest_init+0x72/0x80
> [  188.860698]  [<ffffffff81f201bd>] start_kernel+0x41b/0x428
> [  188.887669]  [<ffffffff81f1fbc0>] ? set_init_arg+0x5d/0x5d
> [  188.914359]  [<ffffffff81f1f5ad>] x86_64_start_reservations+0x2a/0x2c
> [  188.945125]  [<ffffffff81f1f700>] x86_64_start_kernel+0x151/0x158
> [  188.972480] Code: c0 48 83 c8 08 0f 22 c0 eb ce 66 0f 1f 44 00 00 55 8b 05 a1 a8 ec 00 48 89 e5 41 54 65 44 8b 25 cc cc ff 7e 85 c0 5
> 3 7f 19 fb f4 <8b> 05 87 a8 ec 00 65 44 8b 25 b7 cc ff 7e 85 c0 7f 44 5b 41 5c
> 
> 
> I've tracked this down to the following hunk from this commit.
> commit cafa2ee6fbb1bbc2fecdeef990858d56646fc1bd
> Author: Anjali Singhai Jain <anjali.singhai@intel.com>
> Date:   Sat Sep 13 07:40:45 2014 +0000
> 
>     i40e: Fix a bug where Rx would stop after some time
> [...]
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
> index f7464e8..ff6d94d 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
> [...]
> @@ -9169,6 +9178,13 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>  	if (err)
>  		dev_info(&pf->pdev->dev, "set phy mask fail, aq_err %d\n", err);
> 
> +	msleep(75);
> +	err = i40e_aq_set_link_restart_an(&pf->hw, true, NULL);
> +	if (err) {
> +		dev_info(&pf->pdev->dev, "link restart failed, aq_err=%d\n",
> +			 pf->hw.aq.asq_last_status);
> +	}
> +
>  	/* The main driver is (mostly) up and happy. We need to set this state
>  	 * before setting up the misc vector or we get a race and the vector
>  	 * ends up disabled forever.
> 
> With this hunk removed the driver successfully unloaded/reloaded a
> couple of hundred times. Would it be safe to just remove this hunk?
> I haven't seen any negative effects by removing this yet.
> 
>   Stefan
> 
> ------------------------------------------------------------------------------
> Dive into the World of Parallel Programming The Go Parallel Website, sponsored
> by Intel and developed in partnership with Slashdot Media, is your hub for all
> things parallel software development, from weekly thought leadership blogs to
> news, videos, case studies, tutorials and more. Take a look and join the 
> conversation now. http://goparallel.sourceforge.net/
> _______________________________________________
> E1000-devel mailing list
> E1000-devel@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/e1000-devel
> To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
> 
Stefan,
I wouldn't remove them yet as this does look like a valid idea to check to see if the link is 
restarting successfully. On the other hand can you try removing the msleep line as this one is
most likely causing the issue due to sleeping for some long in a probe function is generally a
bad idea.
Thanks,
Nick

------------------------------------------------------------------------------
Dive into the World of Parallel Programming The Go Parallel Website, sponsored
by Intel and developed in partnership with Slashdot Media, is your hub for all
things parallel software development, from weekly thought leadership blogs to
news, videos, case studies, tutorials and more. Take a look and join the 
conversation now. http://goparallel.sourceforge.net/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

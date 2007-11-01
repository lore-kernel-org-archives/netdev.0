From: Steven Whitehouse <steve@chygwyn.com>
Subject: Re: [PATCH] decnet: "addr" module param can't be __initdata
Date: Thu, 1 Nov 2007 15:24:25 +0000
Message-ID: <20071101152425.GA20409@fogou.chygwyn.com>
References: <20071101153629.GA16499@localhost.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, devel@openvz.org
To: Alexey Dobriyan <adobriyan@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fogou.chygwyn.com ([195.171.2.24]:48860 "EHLO fogou.chygwyn.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751053AbXKAQtY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Nov 2007 12:49:24 -0400
Content-Disposition: inline
In-Reply-To: <20071101153629.GA16499@localhost.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Looks good, Feel free to add:

Acked-by: Steven Whitehouse <swhiteho@redhat.com>

Steve.

On Thu, Nov 01, 2007 at 06:36:29PM +0300, Alexey Dobriyan wrote:
> sysfs keeps references to module parameters via /sys/module/*/parameters,
> so marking them as __initdata can't work.
> 
> Steps to reproduce:
> 
> 	modprobe decnet
> 	cat /sys/module/decnet/parameters/addr
> 
> BUG: unable to handle kernel paging request at virtual address f88cd410
> printing eip: c043dfd1 *pdpt = 0000000000004001 *pde = 0000000004408067 *pte = 0000000000000000 
> Oops: 0000 [#1] PREEMPT SMP 
> Modules linked in: decnet sunrpc af_packet ipv6 binfmt_misc dm_mirror dm_multipath dm_mod sbs sbshc fan dock battery backlight ac power_supply parport loop rtc_cmos serio_raw rtc_core rtc_lib button amd_rng sr_mod cdrom shpchp pci_hotplug ehci_hcd ohci_hcd uhci_hcd usbcore
> Pid: 2099, comm: cat Not tainted (2.6.24-rc1-b1d08ac064268d0ae2281e98bf5e82627e0f0c56-bloat #6)
> EIP: 0060:[<c043dfd1>] EFLAGS: 00210286 CPU: 1
> EIP is at param_get_int+0x6/0x20
> EAX: c5c87000 EBX: 00000000 ECX: 000080d0 EDX: f88cd410
> ESI: f8a108f8 EDI: c5c87000 EBP: 00000000 ESP: c5c97f00
>  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
> Process cat (pid: 2099, ti=c5c97000 task=c641ee10 task.ti=c5c97000)
> Stack: 00000000 f8a108f8 c5c87000 c043db6b f8a108f1 00000124 c043de1a c043db2f 
>        f88cd410 ffffffff c5c87000 f8a16bc8 f8a16bc8 c043dd69 c043dd54 c5dd5078 
>        c043dbc8 c5cc7580 c06ee64c c5d679f8 c04c431f c641f480 c641f484 00001000 
> Call Trace:
>  [<c043db6b>] param_array_get+0x3c/0x62
>  [<c043de1a>] param_array_set+0x0/0xdf
>  [<c043db2f>] param_array_get+0x0/0x62
>  [<c043dd69>] param_attr_show+0x15/0x2d
>  [<c043dd54>] param_attr_show+0x0/0x2d
>  [<c043dbc8>] module_attr_show+0x1a/0x1e
>  [<c04c431f>] sysfs_read_file+0x7c/0xd9
>  [<c04c42a3>] sysfs_read_file+0x0/0xd9
>  [<c048d4b2>] vfs_read+0x88/0x134
>  [<c042090b>] do_page_fault+0x0/0x7d5
>  [<c048d920>] sys_read+0x41/0x67
>  [<c04080fa>] sysenter_past_esp+0x6b/0xc1
>  =======================
> Code: 00 83 c4 0c c3 83 ec 0c 8b 52 10 8b 12 c7 44 24 04 27 dd 6c c0 89 04 24 89 54 24 08 e8 ea 01 0c 00 83 c4 0c c3 83 ec 0c 8b 52 10 <8b> 12 c7 44 24 04 58 8c 6a c0 89 04 24 89 54 24 08 e8 ca 01 0c 
> EIP: [<c043dfd1>] param_get_int+0x6/0x20 SS:ESP 0068:c5c97f00
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@sw.ru>
> ---
> 
>  net/decnet/dn_dev.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- a/net/decnet/dn_dev.c
> +++ b/net/decnet/dn_dev.c
> @@ -1439,7 +1439,7 @@ static const struct file_operations dn_dev_seq_fops = {
>  
>  #endif /* CONFIG_PROC_FS */
>  
> -static int __initdata addr[2];
> +static int addr[2];
>  module_param_array(addr, int, NULL, 0444);
>  MODULE_PARM_DESC(addr, "The DECnet address of this machine: area,node");
>  
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

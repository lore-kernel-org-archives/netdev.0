From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: stmmac: Needs to check dma_map return values (oops when build
 with CONFIG_DMA_API_DEBUG)
Date: Mon, 18 Aug 2014 07:41:35 +0200
Message-ID: <53F1920F.1060600@st.com>
References: <53DB6348.70404@redhat.com> <CAOJe8K27X6jeZ78KyKf4Bfb9nPb-XatahqggpPNMJcYAEA-c6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Denis Kirjanov <kda@linux-powerpc.org>,
	Hans de Goede <hdegoede@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:40538 "EHLO
	mx08-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750762AbaHRFlr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2014 01:41:47 -0400
In-Reply-To: <CAOJe8K27X6jeZ78KyKf4Bfb9nPb-XatahqggpPNMJcYAEA-c6Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/1/2014 12:11 PM, Denis Kirjanov wrote:
> On 8/1/14, Hans de Goede <hdegoede@redhat.com> wrote:
>> Hi,
>>
>> When booting a Fedora rawhide kernel, which is build with
>> CONFIG_DMA_API_DEBUG enabled, I get the following oops:
>>
>> [  162.398116] ------------[ cut here ]------------
>> [  162.402770] WARNING: CPU: 0 PID: 0 at lib/dma-debug.c:1140
>> check_unmap+0x6ec/0x824()
>> [  162.410507] stmmaceth 1c50000.ethernet: DMA-API: device driver failed to
>> check map error[device address=0x0000000068a1d002] [size=90 bytes] [mapped
>> as single]
>> [  162.424480] Modules linked in: ip6t_rpfilter ip6t_REJECT xt_conntrack
>> cfg80211 rfkill ebtable_nat ebtable_broute bridge stp llc ebtable_filter
>> ebtables ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6
>> ip6table_mangle ip6table_security ip6table_raw ip6table_filter ip6_tables
>> iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack
>> iptable_mangle iptable_security iptable_raw stmmac ptp pps_core i2c_mv64xxx
>> sun4i_ts ohci_platform sunxi_sid rtc_sunxi phy_sun4i_usb sunxi_wdt leds_gpio
>> mmc_block sunxi_mmc mmc_core ehci_platform ahci_sunxi libahci_platform
>> [  162.476435] CPU: 0 PID: 0 Comm: swapper/0 Not tainted
>> 3.16.0-0.rc7.git1.1.fc22.armv7hl #1
>> [  162.484622] [<c02188dc>] (unwind_backtrace) from [<c0212bb0>]
>> (show_stack+0x18/0x1c)
>> [  162.492366] [<c0212bb0>] (show_stack) from [<c0938d20>]
>> (dump_stack+0x84/0xb0)
>> [  162.499590] [<c0938d20>] (dump_stack) from [<c0252444>]
>> (warn_slowpath_common+0x70/0x94)
>> [  162.507678] [<c0252444>] (warn_slowpath_common) from [<c025249c>]
>> (warn_slowpath_fmt+0x34/0x44)
>> [  162.516374] [<c025249c>] (warn_slowpath_fmt) from [<c058a65c>]
>> (check_unmap+0x6ec/0x824)
>> [  162.524463] [<c058a65c>] (check_unmap) from [<c058a7f8>]
>> (debug_dma_unmap_page+0x64/0x70)
>> [  162.532667] [<c058a7f8>] (debug_dma_unmap_page) from [<bf08dde0>]
>> (stmmac_tx_clean+0x260/0x494 [stmmac])
>> [  162.542242] [<bf08dde0>] (stmmac_tx_clean [stmmac]) from [<c025f988>]
>> (call_timer_fn+0xd0/0x310)
>> [  162.551025] [<c025f988>] (call_timer_fn) from [<c0260578>]
>> (run_timer_softirq+0x268/0x360)
>> [  162.559287] [<c0260578>] (run_timer_softirq) from [<c0258628>]
>> (__do_softirq+0x184/0x4d0)
>> [  162.567461] [<c0258628>] (__do_softirq) from [<c0258c58>]
>> (irq_exit+0x8c/0xfc)
>> [  162.574683] [<c0258c58>] (irq_exit) from [<c020f52c>]
>> (handle_IRQ+0x74/0x98)
>> [  162.581730] [<c020f52c>] (handle_IRQ) from [<c0208920>]
>> (gic_handle_irq+0x4c/0x70)
>> [  162.589299] [<c0208920>] (gic_handle_irq) from [<c0942b04>]
>> (__irq_svc+0x44/0x58)
>> [  162.596774] Exception stack(0xc0d95f58 to 0xc0d95fa0)
>> [  162.601823] 5f40:
>> 00000001 00000004
>> [  162.609995] 5f60: 00000000 c0da2128 c0d94000 00000000 00000000 c0d915d0
>> 00000000 ffffffed
>> [  162.618168] 5f80: c0d94000 c0d9de8c 00000000 c0d95fa0 c02a6d4c c020f8bc
>> 200f0013 ffffffff
>> [  162.626344] [<c0942b04>] (__irq_svc) from [<c020f8bc>]
>> (arch_cpu_idle+0x38/0x44)
>> [  162.633742] [<c020f8bc>] (arch_cpu_idle) from [<c029e780>]
>> (cpu_startup_entry+0x21c/0x6ac)
>> [  162.642008] [<c029e780>] (cpu_startup_entry) from [<c0cabb98>]
>> (start_kernel+0x374/0x3dc)
>> [  162.650176] ---[ end trace 70ec89df0de626f3 ]---
>> [  162.654787] Mapped at:
>> [  162.657145]  [<c07ed840>] dev_hard_start_xmit+0x350/0x8a0
>> [  162.662550]  [<c080fcf8>] sch_direct_xmit+0x74/0x264
>> [  162.667526]  [<c07ee1ec>] __dev_queue_xmit+0x45c/0x8e0
>> [  162.672675]  [<c08a8c84>] ip6_finish_output2+0x7cc/0xa80
>> [  162.677999]  [<c08d3a20>] mld_sendpack+0x3fc/0x808
>>
>> This is caused by various calls to dma_map_single not being error checked.
>>
>> A call to dma_map_single should look something like this:
>>
>> 	dma_handle = dma_map_single(dev, addr, size, direction);
>> 	if (dma_mapping_error(dma_handle))
>> 		/* do error */
>>
>> I believe that the calls to skb_frag_dma_map should be error
>> checked similarly, but I'm not 100% sure on that.
> Yes. You should unwind your frags.
> It's been done already in many places.
>
>>
>> I looked into fixing this myself, but esp. for the jumbo frame paths
>> fixing this looks like it is non trivial.

Hello Denis.

I have a patch that must be ported on top of the net.dev kernel
and I will provide it asap.

For reference this is the patch I will rework, give me you opinion too.

http://git.stlinux.com/?p=stm/linux-stm.git;a=commit;h=755f606c7efc5d9c111fa2be00b6e9916e101920

br
peppe

>>
>> Regards,
>>
>> Hans
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>

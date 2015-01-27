From: Chris Ruehl <chris.ruehl@gtsys.com.hk>
Subject: Re: ipv6: oops in datagram.c line 260
Date: Tue, 27 Jan 2015 12:20:31 +0800
Message-ID: <54C7120F.5000105@gtsys.com.hk>
References: <5487DD65.60800@gtsys.com.hk> <549AC2B4.8070203@gtsys.com.hk> <1420560073.32369.60.camel@redhat.com> <20150126083512.GI13046@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Steffen Klassert <steffen.klassert@secunet.com>,
	Hannes Frederic Sowa <hannes@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.fpasia.hk ([202.130.89.98]:56135 "EHLO fpa01n0.fpasia.hk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752345AbbA0EUj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jan 2015 23:20:39 -0500
In-Reply-To: <20150126083512.GI13046@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, January 26, 2015 04:35 PM, Steffen Klassert wrote:
> On Tue, Jan 06, 2015 at 05:01:13PM +0100, Hannes Frederic Sowa wrote:
>> On Mi, 2014-12-24 at 21:42 +0800, Chris Ruehl wrote:
>>> [447604.244357] ipv6_pinfo is NULL
>>> [447604.273733] ------------[ cut here ]------------
>>> [447604.303628] WARNING: CPU: 7 PID: 0 at net/ipv6/datagram.c:262
>>> ipv6_local_error+0x16b/0x1a0()
>>> [[...]]
>>> [last unloaded: ipmi_si]
>>> [447605.087999] CPU: 7 PID: 0 Comm: swapper/7 Not tainted 3.14.27 #11
>>> [447605.139687] Hardware name: Dell Inc. PowerEdge R420/0CN7CM, BIOS 2.3.3
>>> 07/10/2014
>>> [447605.242931]  0000000000000009 ffff8806172e3b48 ffffffff815ffd58 0000000000000000
>>> [447605.349130]  ffff8806172e3b80 ffffffff81043c23 ffff8800a16322e8 ffff880037daa1c0
>>> [447605.459659]  ffff88000b026800 0000000000000000 ffff880037daa4b8 ffff8806172e3b90
>>> [447605.576385] Call Trace:
>>> [447605.634243]  <IRQ>  [<ffffffff815ffd58>] dump_stack+0x45/0x56
>>> [447605.692870]  [<ffffffff81043c23>] warn_slowpath_common+0x73/0x90
>>> [447605.751097]  [<ffffffff81043cf5>] warn_slowpath_null+0x15/0x20
>>> [447605.808000]  [<ffffffff815da6db>] ipv6_local_error+0x16b/0x1a0
>>> [447605.863821]  [<ffffffff815e29d0>] xfrm6_local_error+0x60/0x90
>>> [447605.918493]  [<ffffffff8150b485>] ? skb_dequeue+0x15/0x70
>>> [447605.971871]  [<ffffffff815a6cc1>] xfrm_local_error+0x51/0x70
>>> [447606.024218]  [<ffffffff8159ca15>] xfrm4_extract_output+0x75/0xb0
>>> [447606.075630]  [<ffffffff815a6c5a>] xfrm_inner_extract_output+0x6a/0x80
>>> [447606.126055]  [<ffffffff815e27a2>] xfrm6_prepare_output+0x12/0x60
>>> [447606.175310]  [<ffffffff815a6ed0>] xfrm_output_resume+0x1f0/0x370
>>> [447606.223406]  [<ffffffff8151a486>] ? skb_checksum_help+0x76/0x190
>>> [447606.270572]  [<ffffffff815a709b>] xfrm_output+0x3b/0xf0
>>> [447606.316454]  [<ffffffff815e2ae0>] ? xfrm6_extract_output+0xe0/0xe0
>>> [447606.361803]  [<ffffffff815e2af7>] xfrm6_output_finish+0x17/0x20
>>> [447606.406053]  [<ffffffff8159cad6>] xfrm4_output+0x46/0x80
>>> [447606.448694]  [<ffffffff81550a80>] ip_local_out+0x20/0x30
>>> [447606.489952]  [<ffffffff81550dd5>] ip_queue_xmit+0x135/0x3c0
>>> [447606.530017]  [<ffffffff815672e1>] tcp_transmit_skb+0x461/0x8c0
>>> [447606.569362]  [<ffffffff8156786e>] tcp_write_xmit+0x12e/0xb20
>>> [447606.607876]  [<ffffffff815669ff>] ? tcp_current_mss+0x4f/0x70
>>> [447606.645723]  [<ffffffff8156b320>] ? tcp_write_timer_handler+0x1b0/0x1b0
>>> [447606.682837]  [<ffffffff81569487>] tcp_send_loss_probe+0x37/0x1f0
>>> [447606.719000]  [<ffffffff8156b320>] ? tcp_write_timer_handler+0x1b0/0x1b0
>>> [447606.754537]  [<ffffffff8156b1bb>] tcp_write_timer_handler+0x4b/0x1b0
>>> [447606.789266]  [<ffffffff8156b320>] ? tcp_write_timer_handler+0x1b0/0x1b0
>>> [447606.823242]  [<ffffffff8156b378>] tcp_write_timer+0x58/0x60
>>> [447606.856047]  [<ffffffff8104e848>] call_timer_fn.isra.32+0x18/0x80
>>> [447606.888029]  [<ffffffff8104ea1a>] run_timer_softirq+0x16a/0x200
>>> [447606.920224]  [<ffffffff81047efc>] __do_softirq+0xec/0x250
>>> [447606.951850]  [<ffffffff810482f5>] irq_exit+0xf5/0x100
>>> [447606.982665]  [<ffffffff8102bc6f>] smp_apic_timer_interrupt+0x3f/0x50
>>> [447607.014382]  [<ffffffff8160d98a>] apic_timer_interrupt+0x6a/0x70
>>> [447607.046175]  <EOI>  [<ffffffff8104f336>] ? get_next_timer_interrupt+0x1d6/0x250
>>> [447607.111311]  [<ffffffff814d45a7>] ? cpuidle_enter_state+0x47/0xc0
>>> [447607.145850]  [<ffffffff814d45a3>] ? cpuidle_enter_state+0x43/0xc0
>>> [447607.179625]  [<ffffffff814d46b6>] cpuidle_idle_call+0x96/0x130
>>> [447607.213531]  [<ffffffff8100b909>] arch_cpu_idle+0x9/0x20
>>> [447607.247052]  [<ffffffff810925ba>] cpu_startup_entry+0xda/0x1d0
>>> [447607.280775]  [<ffffffff81029d22>] start_secondary+0x212/0x2c0
>>> [447607.314555] ---[ end trace 6ff3826b6e4fdf67 ]---
>>>
>> Thanks for the report!
>>
>> xfrm6_output_finish unconditionally resets skb->protocol so we try to
>> dispatch to the IPv6 handler, even though tcp just sends an IPv4 packet.
>>
> Looks like we can postpone the setting of skb->protocol to the
> xfrm{4,6}_prepare_output() functions where we finally switch to
> outer mode.
>
> This has two implications:
>
> - We reset skb->protocol only for tunnel modes, should be ok.
>
> - This affects the xfrm_output_gso() codepath on interfamily
>    tunnels. skb_mac_gso_segment() dispatches to the gso_segment()
>    callback functions via skb->protocol. So we dispatch to
>    the gso_segment() function of the outer mode what looks
>    wrong to me. If we postpone the setting of skb->protocol
>    to the xfrm{4,6}_prepare_output() we dispatch to inner mode
>    here.
>
> Unfortunately I was not able to reproduce the problem on our test
> setup. Chris could you try if the the patch below fixes your
> problem?
>
> Subject: [PATCH RFC] xfrm: Fix local error reporting crash with interfamily
>   tunnels
>
> We set the outer mode protocol too early. As a result, the
> local error handler might dispatch to the wrong	address family
> and report the error to a wrong socket type. We fix this by
> seting the outer protocol to the skb after we accessed the
> inner mode for the last time, right before we do the atcual
> encapsulation where we switch finally to the outer mode.
>
> Reported-by: Chris Ruehl <chris.ruehl@gtsys.com.hk>
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> ---
>   net/ipv4/xfrm4_output.c | 2 +-
>   net/ipv6/xfrm6_output.c | 2 +-
>   2 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
> index d5f6bd9..dab7381 100644
> --- a/net/ipv4/xfrm4_output.c
> +++ b/net/ipv4/xfrm4_output.c
> @@ -63,6 +63,7 @@ int xfrm4_prepare_output(struct xfrm_state *x, struct sk_buff *skb)
>   		return err;
>   
>   	IPCB(skb)->flags |= IPSKB_XFRM_TUNNEL_SIZE;
> +	skb->protocol = htons(ETH_P_IP);
>   
>   	return x->outer_mode->output2(x, skb);
>   }
> @@ -71,7 +72,6 @@ EXPORT_SYMBOL(xfrm4_prepare_output);
>   int xfrm4_output_finish(struct sk_buff *skb)
>   {
>   	memset(IPCB(skb), 0, sizeof(*IPCB(skb)));
> -	skb->protocol = htons(ETH_P_IP);
>   
>   #ifdef CONFIG_NETFILTER
>   	IPCB(skb)->flags |= IPSKB_XFRM_TRANSFORMED;
> diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
> index ca3f29b..010f8bd 100644
> --- a/net/ipv6/xfrm6_output.c
> +++ b/net/ipv6/xfrm6_output.c
> @@ -114,6 +114,7 @@ int xfrm6_prepare_output(struct xfrm_state *x, struct sk_buff *skb)
>   		return err;
>   
>   	skb->ignore_df = 1;
> +	skb->protocol = htons(ETH_P_IPV6);
>   
>   	return x->outer_mode->output2(x, skb);
>   }
> @@ -122,7 +123,6 @@ EXPORT_SYMBOL(xfrm6_prepare_output);
>   int xfrm6_output_finish(struct sk_buff *skb)
>   {
>   	memset(IP6CB(skb), 0, sizeof(*IP6CB(skb)));
> -	skb->protocol = htons(ETH_P_IPV6);
>   
>   #ifdef CONFIG_NETFILTER
>   	IP6CB(skb)->flags |= IP6SKB_XFRM_TRANSFORMED;
Steffen,

I will apply the patch and let you know. I keep my warning so we will 
see if its hits it (hopefully not)
After apply the patch it can take a couple of day until we know it - see 
below
root@sh1:/home/chris/kernel.d/linux-3.14.x# dmesg | grep WARNING
[447604.303628] WARNING: CPU: 7 PID: 0 at net/ipv6/datagram.c:262 
ipv6_local_error+0x16b/0x1a0()
[1738973.489326] WARNING: CPU: 7 PID: 0 at net/ipv6/datagram.c:262 
ipv6_local_error+0x16b/0x1a0()
[1738973.678786] WARNING: CPU: 6 PID: 0 at net/ipv6/datagram.c:262 
ipv6_local_error+0x16b/0x1a0()
[2795700.233928] WARNING: CPU: 7 PID: 0 at net/ipv6/datagram.c:262 
ipv6_local_error+0x16b/0x1a0()
[2805335.085370] WARNING: CPU: 0 PID: 0 at net/ipv6/datagram.c:262 
ipv6_local_error+0x16b/0x1a0()
[2881267.252047] WARNING: CPU: 6 PID: 0 at net/ipv6/datagram.c:262 
ipv6_local_error+0x16b/0x1a0()
[3042311.131764] WARNING: CPU: 7 PID: 0 at net/ipv6/datagram.c:262 
ipv6_local_error+0x16b/0x1a0()
[3061315.974711] WARNING: CPU: 6 PID: 0 at net/ipv6/datagram.c:262 
ipv6_local_error+0x16b/0x1a0()
[3070653.051669] WARNING: CPU: 6 PID: 0 at net/ipv6/datagram.c:262 
ipv6_local_error+0x16b/0x1a0()
[3089456.783231] WARNING: CPU: 6 PID: 0 at net/ipv6/datagram.c:262 
ipv6_local_error+0x16b/0x1a0()
[3098986.926483] WARNING: CPU: 6 PID: 0 at net/ipv6/datagram.c:262 
ipv6_local_error+0x16b/0x1a0()
[3118180.833934] WARNING: CPU: 6 PID: 0 at net/ipv6/datagram.c:262 
ipv6_local_error+0x16b/0x1a0()

Thanks
Chris

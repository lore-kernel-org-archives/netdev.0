From: James Chapman <jchapman@katalix.com>
Subject: Re: Bug#656802: linux-image-2.6.32-5-amd64: dmesg BUG: scheduling
 while atomic: ksoftirqd/0/4/0x10000100
Date: Mon, 23 Jan 2012 12:12:49 +0000
Message-ID: <4F1D4EC1.2030205@katalix.com>
References: <20120121201935.25512.69763.reportbug@m3x.org> <1327195921.8004.70.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, 656802@bugs.debian.org,
	alex <alex@m3x.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:60543 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751154Ab2AWMTp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jan 2012 07:19:45 -0500
In-Reply-To: <1327195921.8004.70.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22/01/12 01:32, Ben Hutchings wrote:
> On Sat, 2012-01-21 at 22:19 +0200, alex wrote:
> [...]
>>   [148654.740747] xt_TCPMSS: bad length (41 bytes)
>> [148656.341170] BUG: scheduling while atomic: ksoftirqd/0/4/0x10000100
>> [148656.341402] Modules linked in: act_police sch_ingress cls_u32 sch_sfq sch_cbq dummy 8021q garp stp xt_TCPMSS ipt_REJECT xt_tcpudp xt_state xt_multiport iptable_filt
>> er iptable_nat nf_nat nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 ip_tables x_tables xfs exportfs pppoe pppol2tp pptp pppox ppp_generic slhc loop firewire_sbp2 snd_hd
>> a_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep snd_pcm snd_timer nouveau ttm drm_kms_helper snd drm i2c_piix4 i2c_algo_bit i2c_core k10temp soundcore edac_core s
>> nd_page_alloc edac_mce_amd pcspkr button wmi evdev processor ext3 jbd mbcache ata_generic sd_mod crc_t10dif ohci_hcd pata_via pata_atiixp tg3 libphy ahci ehci_hcd libat
>> a ixgbe xhci firewire_ohci dca floppy usbcore thermal scsi_mod firewire_core nls_base crc_itu_t thermal_sys [last unloaded: scsi_wait_scan]
>> [148656.341440] Pid: 4, comm: ksoftirqd/0 Not tainted 2.6.32-5-amd64 #1
>> [148656.341442] Call Trace:
>> [148656.341443]<IRQ>   [<ffffffff812facb8>] ? schedule+0xc5/0x7b4
>> [148656.341453]  [<ffffffff810963c9>] ? handle_edge_irq+0xdd/0x101
>> [148656.341457]  [<ffffffff8104aa4c>] ? __cond_resched+0x1d/0x26
>> [148656.341459]  [<ffffffff812fb5ab>] ? _cond_resched+0x24/0x2f
>> [148656.341463]  [<ffffffff81243945>] ? lock_sock_nested+0x16/0xab
>> [148656.341465]  [<ffffffff810114d3>] ? ret_from_intr+0x0/0x11
>> [148656.341469]  [<ffffffffa01a6b2a>] ? pppol2tp_tunnel_destruct+0xe7/0x1f7 [pppol2tp]
>> [148656.341472]  [<ffffffff8124433f>] ? __sk_free+0x15/0xe8
>> [148656.341474]  [<ffffffff81247c06>] ? skb_release_head_state+0x6d/0xc8
>> [148656.341476]  [<ffffffff8124797a>] ? __kfree_skb+0x9/0x7d
>> [148656.341485]  [<ffffffffa00cf989>] ? ixgbe_poll+0x119/0x1840 [ixgbe]
>> [148656.341489]  [<ffffffff81272e08>] ? ip_rcv_finish+0x0/0x38d
>> [148656.341493]  [<ffffffff8124fd8e>] ? net_rx_action+0xae/0x1c9
>> [148656.341496]  [<ffffffff81053d2b>] ? __do_softirq+0xdd/0x1a6
>> [148656.341498]  [<ffffffff81011cac>] ? call_softirq+0x1c/0x30
> [...]
>
> It appears that a transmit completion results in dropping the last
> reference to a PPPoL2TP tunnel, causing it to be destroyed.
> pppo2ltp_tunnel_destruct() calls pppo2ltp_tunnel_closeall() (inlined
> here) which calls lock_sock(), and that may sleep.
>
> Although this was observed in 2.6.32, the bug appears to be present
> today: l2tp_tunnel_destruct() calls l2tp_tunnel_closeall() calls
> pppol2tp_session_close() calls lock_sock().
>
> But maybe this is actually a ref-counting bug and the tunnel should
> never actually be destroyed in atomic context.

I'll look over the code. Meanwhile, do you have info about the config / 
use case so that I can try to reproduce it?

>
> Ben.
>


-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

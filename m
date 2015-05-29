From: Grant Zhang <gzhang@fastly.com>
Subject: Recurring trace from tcp_fragment()
Date: Fri, 29 May 2015 12:21:59 -0700
Message-ID: <CFCC0DCC-4080-4195-9BA9-0860D9701805@fastly.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34891 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422669AbbE2TWB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 15:22:01 -0400
Received: by pacrp13 with SMTP id rp13so20388212pac.2
        for <netdev@vger.kernel.org>; Fri, 29 May 2015 12:22:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have multiple machines running into the following trace repeatedly. The trace shows up every couple of seconds on our production machines.

May 29 18:14:04 cache-fra1230 kernel:[3080455.796143] WARNING: CPU: 7 PID: 0 at net/ipv4/tcp_output.c:1082 tcp_fragment+0x2e4/0x2f0()
May 29 18:14:04 cache-fra1230 kernel:[3080455.796144] Modules linked in: xt_TEE xt_dscp xt_DSCP macvlan gpio_ich x86_pkg_temp_thermal coretemp crct10dif_pclmul crc32_pclmul ghash_clmulni_intel microcode ipmi_watchdog ipmi_devintf sb_edac edac_core lpc_ich mfd_core tpm_tis tpm ipmi_si ipmi_msghandler igb i2c_algo_bit ixgbe ptp isci libsas pps_core mdio
May 29 18:14:04 cache-fra1230 kernel:[3080455.796165] CPU: 7 PID: 0 Comm: swapper/7 Tainted: G        W    3.14.39-fastly #6
May 29 18:14:04 cache-fra1230 kernel:[3080455.796166] Hardware name: Supermicro X9DRi-LN4+/X9DR3-LN4+/X9DRi-LN4+/X9DR3-LN4+, BIOS 3.0 07/05/2013
May 29 18:14:04 cache-fra1230 kernel:[3080455.796168]  000000000000043a ffff885effce38f8 ffffffff81718716 0000000000000007
May 29 18:14:04 cache-fra1230 kernel:[3080455.796170]  0000000000000000 ffff885effce3938 ffffffff8106b54c ffff885e00000001
May 29 18:14:04 cache-fra1230 kernel:[3080455.796172]  ffff8864910c5c00 0000000000000144 ffff882400e2f000 0000000000000400
May 29 18:14:04 cache-fra1230 kernel:[3080455.796174] Call Trace:
May 29 18:14:04 cache-fra1230 kernel:[3080455.796175]  <IRQ>  [<ffffffff81718716>] dump_stack+0x46/0x58
May 29 18:14:04 cache-fra1230 kernel:[3080455.796184]  [<ffffffff8106b54c>] warn_slowpath_common+0x8c/0xc0
May 29 18:14:04 cache-fra1230 kernel:[3080455.796186]  [<ffffffff8106b59a>] warn_slowpath_null+0x1a/0x20
May 29 18:14:04 cache-fra1230 kernel:[3080455.796188]  [<ffffffff81678174>] tcp_fragment+0x2e4/0x2f0
May 29 18:14:04 cache-fra1230 kernel:[3080455.796191]  [<ffffffff8166edeb>] tcp_mark_head_lost+0xeb/0x290
May 29 18:14:04 cache-fra1230 kernel:[3080455.796193]  [<ffffffff8166fe28>] tcp_update_scoreboard+0x58/0x90
May 29 18:14:04 cache-fra1230 kernel:[3080455.796195]  [<ffffffff8167422d>] tcp_fastretrans_alert+0x75d/0xb30
May 29 18:14:04 cache-fra1230 kernel:[3080455.796197]  [<ffffffff816750d5>] tcp_ack+0xa15/0xf50
May 29 18:14:04 cache-fra1230 kernel:[3080455.796199]  [<ffffffff816765db>] tcp_rcv_state_process+0x25b/0xd60
May 29 18:14:04 cache-fra1230 kernel:[3080455.796202]  [<ffffffff8167f7e0>] tcp_v4_do_rcv+0x230/0x490
May 29 18:14:04 cache-fra1230 kernel:[3080455.796206]  [<ffffffff8165cbb0>] ? ip_rcv_finish+0x380/0x380
May 29 18:14:04 cache-fra1230 kernel:[3080455.796208]  [<ffffffff81681a93>] tcp_v4_rcv+0x803/0x850
May 29 18:14:04 cache-fra1230 kernel:[3080455.796210]  [<ffffffff8165cbb0>] ? ip_rcv_finish+0x380/0x380
May 29 18:14:04 cache-fra1230 kernel:[3080455.796214]  [<ffffffff8163c61d>] ? nf_hook_slow+0x7d/0x150
May 29 18:14:04 cache-fra1230 kernel:[3080455.796216]  [<ffffffff8165cbb0>] ? ip_rcv_finish+0x380/0x380
May 29 18:14:04 cache-fra1230 kernel:[3080455.796219]  [<ffffffff8165cc58>] ip_local_deliver_finish+0xa8/0x220
May 29 18:14:04 cache-fra1230 kernel:[3080455.796221]  [<ffffffff8165cf5b>] ip_local_deliver+0x4b/0x90
May 29 18:14:04 cache-fra1230 kernel:[3080455.796223]  [<ffffffff8165c951>] ip_rcv_finish+0x121/0x380
May 29 18:14:04 cache-fra1230 kernel:[3080455.796225]  [<ffffffff8165d226>] ip_rcv+0x286/0x380
May 29 18:14:04 cache-fra1230 kernel:[3080455.796228]  [<ffffffff8160c1d2>] __netif_receive_skb_core+0x512/0x640
May 29 18:14:04 cache-fra1230 kernel:[3080455.796230]  [<ffffffff8160c321>] __netif_receive_skb+0x21/0x70
May 29 18:14:04 cache-fra1230 kernel:[3080455.796232]  [<ffffffff8160c40b>] process_backlog+0x9b/0x170
May 29 18:14:04 cache-fra1230 kernel:[3080455.796234]  [<ffffffff8160c851>] net_rx_action+0x111/0x210
May 29 18:14:04 cache-fra1230 kernel:[3080455.796237]  [<ffffffff8106ff6f>] __do_softirq+0xef/0x2e0
May 29 18:14:04 cache-fra1230 kernel:[3080455.796239]  [<ffffffff81070335>] irq_exit+0x55/0x60
May 29 18:14:04 cache-fra1230 kernel:[3080455.796243]  [<ffffffff81729127>] do_IRQ+0x67/0x110
May 29 18:14:04 cache-fra1230 kernel:[3080455.796246]  [<ffffffff8171edaa>] common_interrupt+0x6a/0x6a
May 29 18:14:04 cache-fra1230 kernel:[3080455.796246]  <EOI>  [<ffffffff8100b8c0>] ? default_idle+0x20/0xe0
May 29 18:14:04 cache-fra1230 kernel:[3080455.796253]  [<ffffffff8100c07f>] arch_cpu_idle+0xf/0x20
May 29 18:14:04 cache-fra1230 kernel:[3080455.796256]  [<ffffffff810b5f60>] cpu_startup_entry+0x80/0x240
May 29 18:14:04 cache-fra1230 kernel:[3080455.796260]  [<ffffffff810c9846>] ? clockevents_config_and_register+0x26/0x30
May 29 18:14:04 cache-fra1230 kernel:[3080455.796264]  [<ffffffff8102d480>] start_secondary+0x190/0x1f0
May 29 18:14:04 cache-fra1230 kernel:[3080455.796265] ---[ end trace 707a3e5aca13730c ]---


We have seen the trace on both 3.10 and 3.14 kernels. My google search also indicates the very issue on 3.16 kernel:
https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=771224

Sorry I haven't tried with the lastest upstream kernel--we only see the traces in production env and we stay a bit behind the latest kernel in production.

Using probe_events, I can see that tcp_fragment() is asked to fragment a skb which is already smaller than "len"(passed in by the caller tcp_mark_head_lost()), and as a result tcp_fragment() returns with -EINVAL at line 1071.

          <idle>-0     [005] d.s. 1267970.050938: myprobe: (tcp_fragment+0x0/0x2f0) skb_len=0x150 len=0x200 mss_now=0x200
          <idle>-0     [005] dNs. 1267970.051069: myretprobe: (tcp_mark_head_lost+0xeb/0x290 <- tcp_fragment) arg1=0xffffffea
          <idle>-0     [005] dNs. 1267970.051097: myprobe: (tcp_fragment+0x0/0x2f0) skb_len=0x150 len=0x400 mss_now=0x200
          <idle>-0     [005] dNs. 1267970.051183: myretprobe: (tcp_mark_head_lost+0xeb/0x290 <- tcp_fragment) arg1=0xffffffea

1061 int tcp_fragment(struct sock *sk, struct sk_buff *skb, u32 len,
1062                  unsigned int mss_now)
1063 {
1064         struct tcp_sock *tp = tcp_sk(sk);
1065         struct sk_buff *buff;
1066         int nsize, old_factor;
1067         int nlen;
1068         u8 flags;
1069 
1070         if (WARN_ON(len > skb->len))
1071                 return -EINVAL;
1072 

The system otherwise runs fine though. Digging a bit into git log, it seems the original BUG_ON was added way back:
commit 3c05d92ed49f644d1f5a960fa48637d63b946016
Date:   Wed Sep 14 20:50:35 2005 -0700
    [TCP]: Compute in_sacked properly when we split up a TSO frame.
    
    The problem is that the SACK fragmenting code may incorrectly call
    tcp_fragment() with a length larger than the skb->len.  This happens
    when the skb on the transmit queue completely falls to the LHS of the
    SACK.
    
    And add a BUG() check to tcp_fragment() so we can spot this kind of
    error more quickly in the future.
    

---------------------------- net/ipv4/tcp_output.c ----------------------------
index c10e443..b018e31 100644
@@ -435,6 +435,8 @@ int tcp_fragment(struct sock *sk, struct sk_buff *skb, u32 len, unsigned int mss
 	int nsize, old_factor;
 	u16 flags;
 
+	BUG_ON(len >= skb->len);
+
 	nsize = skb_headlen(skb) - len;
 	if (nsize < 0)
 		nsize = 0;

My questions are: 
1. is this trace still related to the SACK fragmenting code? 
2. If this trace is benign, is it OK to remove or rate-limit the kernel message?

Thanks for any inputs,

Grant
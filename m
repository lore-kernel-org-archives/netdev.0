From: subashab@codeaurora.org
Subject: Re: [PATCH net] net: Check for fullsock in sock_i_uid()
Date: Wed, 02 Nov 2016 11:05:33 -0600
Message-ID: <f77e1a0d37ef82933503018a974cc07a@codeaurora.org>
References: <1478064420-11601-1-git-send-email-subashab@codeaurora.org>
 <1478075943.7065.361.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:40632 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755593AbcKBRFf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 13:05:35 -0400
In-Reply-To: <1478075943.7065.361.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> This would be a bug in the caller.
> 
> Can you give us the complete stack trace leading to the problem you
> had ?
> 
> Thanks !

Thanks Eric for the clarification. In that case, the bug is in the 
IDLETIMER target in Android kernel.
https://android.googlesource.com/kernel/common/+/android-4.4/net/netfilter/xt_IDLETIMER.c#356

Here is the call stack.

-003|rwlock_bug(?, ?)
-004|arch_read_lock(inline)
-004|do_raw_read_lock(lock = 0xFFFFFFC0354E79C8)
-005|raw_read_lock_bh(lock = 0xFFFFFFC0354E79C8)
-006|sock_i_uid(sk = 0xFFFFFFC0354E77B0)
-007|from_kuid_munged(inline)
-007|reset_timer(info = 0xFFFFFFC04D17D218, skb = 0xFFFFFFC018AB98C0)
-008|idletimer_tg_target(skb = 0xFFFFFFC018AB98C0, ?)
-009|ipt_do_table(skb = 0xFFFFFFC018AB98C0, state = 0xFFFFFFC0017E6F30, 
?)
-010|iptable_mangle_hook(?, skb = 0xFFFFFFC018AB98C0, state = 
0xFFFFFFC0017E6F30)
-011|nf_iterate(head = 0xFFFFFFC0019D55B8, skb = 0xFFFFFFC018AB98C0, 
state = 0xFFFFFFC0017E6F30, elemp =
-012|nf_hook_slow(skb = 0xFFFFFFC018AB98C0, state = 0xFFFFFFC0017E6F30)
-013|NF_HOOK_COND(inline)
-013|ip_output(net = 0xFFFFFFC0019D4B00, sk = 0xFFFFFFC0354E77B0, skb = 
0xFFFFFFC018AB98C0)
-014|ip_local_out(net = 0xFFFFFFC0019D4B00, sk = 0xFFFFFFC0354E77B0, skb 
= 0xFFFFFFC018AB98C0)
-015|ip_build_and_send_pkt(skb = 0xFFFFFFC018AB98C0, sk = 
0xFFFFFFC023F2E880, saddr = 1688053952, daddr =
-016|tcp_v4_send_synack(sk = 0xFFFFFFC023F2E880, ?, ?, req = 
0xFFFFFFC0354E77B0, foc = 0xFFFFFFC0017E7110
-017|atomic_sub_return(inline)
-017|reqsk_put(inline)
-017|tcp_conn_request(?, af_ops = 0xFFFFFFC001080FC8, sk = 
0xFFFFFFC023F2E880, ?)
-018|tcp_v4_conn_request(?, ?)
-019|tcp_rcv_state_process(sk = 0xFFFFFFC023F2E880, skb = 
0xFFFFFFC018ABAD00)
-020|tcp_v4_do_rcv(sk = 0xFFFFFFC023F2E880, skb = 0xFFFFFFC018ABAD00)
-021|tcp_v4_rcv(skb = 0xFFFFFFC018ABAD00)
-022|ip_local_deliver_finish(net = 0xFFFFFFC0019D4B00, ?, skb = 
0xFFFFFFC018ABAD00)
-023|NF_HOOK_THRESH(inline)
-023|NF_HOOK(inline)
-023|ip_local_deliver(skb = 0xFFFFFFC018ABAD00)
-024|ip_rcv_finish(net = 0xFFFFFFC0019D4B00, ?, skb = 
0xFFFFFFC018ABAD00)
-025|NF_HOOK_THRESH(inline)
-025|NF_HOOK(inline)
-025|ip_rcv(skb = 0xFFFFFFC018ABAD00, dev = 0xFFFFFFC023474000, ?, ?)
-026|deliver_skb(inline)
-026|deliver_ptype_list_skb(inline)
-026|__netif_receive_skb_core(skb = 0x0A73, pfmemalloc = FALSE)
-027|__netif_receive_skb(skb = 0xFFFFFFC0BA455D40)
-028|netif_receive_skb_internal(skb = 0xFFFFFFC0BA455D40)
-029|netif_receive_skb(skb = 0xFFFFFFC0BA455D40)

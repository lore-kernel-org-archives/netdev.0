From: Dave Young <dyoung@redhat.com>
Subject: nf_reject_ipv4: module license 'unspecified' taints kernel
Date: Fri, 10 Oct 2014 17:19:04 +0800
Message-ID: <20141010091904.GD1981@darkstar.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: pablo@netfilter.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

With today's linus tree, I got below kmsg:
[   23.545204] nf_reject_ipv4: module license 'unspecified' taints kernel.
[   23.551886] Disabling lock debugging due to kernel taint
[   23.557302] nf_reject_ipv4: Unknown symbol lock_is_held (err 0)
[   23.563256] nf_reject_ipv4: Unknown symbol rcu_read_lock_bh_held (err 0)
[   23.569992] nf_reject_ipv4: Unknown symbol ip_local_out_sk (err 0)
[   23.576206] nf_reject_ipv4: Unknown symbol debug_lockdep_rcu_enabled (err 0)
[   23.583290] nf_reject_ipv4: Unknown symbol rcu_is_watching (err 0)
[   23.589523] nf_reject_ipv4: Unknown symbol rcu_lock_map (err

It could be caused by below commit:

commit c8d7b98bec43faaa6583c3135030be5eb4693acb
Author: Pablo Neira Ayuso <pablo@netfilter.org>
Date:   Fri Sep 26 14:35:15 2014 +0200

    netfilter: move nf_send_resetX() code to nf_reject_ipvX modules
    
    Move nf_send_reset() and nf_send_reset6() to nf_reject_ipv4 and
    nf_reject_ipv6 respectively. This code is shared by x_tables and
    nf_tables.
    
    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

I believe there's similar issue for ipv6 reject part though I have disabled ipv6
in my .config.

Let me know if you need any furthur information.

Thanks
Dave

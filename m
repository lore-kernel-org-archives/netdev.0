From: Olaf Hering <olh@suse.de>
Subject: kmalloc_node returns unaligned memory
Date: Mon, 13 Mar 2006 15:45:13 +0100
Message-ID: <20060313144513.GA9542@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751237AbWCMOpR@vger.kernel.org>
To: linux-kernel@vger.kernel.org, Jaroslav Kysela <perex@suse.de>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


kmalloc_node returns unaligned pointers on powerpc, when CONFIG_DEBUG_SLAB
is enabled. This makes iptables very unhappy. It checks the alignment in
net/ipv6/netfilter/ip6_tables.c:check_entry_size_and_hooks(). 
__alignof__(struct ip6t_entry) returns 8. But returned pointers from
xt_alloc_table_info() are unaligned:

Linux version 2.6.16-rc6-git1-default-iptables-slab (olaf@pomegranate) (gcc version 4.1.0 (SUSE Linux)) #2 Mon Mar 13 15:19:45 CET 2006
...
 xt_alloc_table_info(250) modprobe(1687):c0,j4294904016 newinfo/size cfc82498/0x278
 xt_alloc_table_info(265) modprobe(1687):c0,j4294904038 entries[0] c449611c
 ip_nat_init: can't setup rules.
 sys_init_module(1960) modprobe(1687):c0,j4294904071 iptable_nat returned -22
...

Any ideas how to fix that?

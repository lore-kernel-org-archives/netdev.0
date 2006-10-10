From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bugme-new] [Bug 7297] New: modprobe -v -r causes crash in
 xt_unregister_match
Date: Tue, 10 Oct 2006 10:53:44 -0700
Message-ID: <20061010105344.944b890a.akpm@osdl.org>
References: <200610101210.k9ACAlNG016078@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, olh@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:22714 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1030198AbWJJRyJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2006 13:54:09 -0400
To: netdev@vger.kernel.org
In-Reply-To: <200610101210.k9ACAlNG016078@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 10 Oct 2006 05:10:47 -0700
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=7297
> 
>            Summary: modprobe -v -r causes crash in xt_unregister_match
>     Kernel Version: 2.6.16 / 2.6.19-rc1-git6
>             Status: NEW
>           Severity: normal
>              Owner: laforge@gnumonks.org
>          Submitter: olh@suse.de
> 
> 
> Most recent kernel where this bug did not occur: untested
> Distribution: SuSE Linux
> Hardware Environment: IBM JS20 ppc64
> Software Environment:
> Problem Description:
> 
> NET: Unregistered protocol family 5
> ieee80211_crypt: unregistered algorithm 'CCMP'
> ieee80211_crypt: unregistered algorithm 'WEP'
> ieee80211_crypt: unregistered algorithm 'NULL'
> Unable to handle kernel paging request for data at address 0xd000000000d57c08
> Faulting instruction address: 0xd0000000000e667c
> Oops: Kernel access of bad area, sig: 11 [#1]
> SMP NR_CPUS=128 NUMA
> Modules linked in: ip_gre sco rfcomm hidp bnep l2cap bluetooth rpcsec_gss_spkm3
> rpcsec_gss_krb5 auth_rpcgss sunrpc ebt_802_3 ebt_redirect ebt_snat ebt_mark
> ebtable_na
> t ebt_pkttype ebt_dnat ebt_among ebt_limit ebtable_filter ebt_ip ebt_arpreply
> ebt_stp ebt_log ebt_mark_m ebt_arp ebt_vlan ebtable_broute ebtables xt_NFQUEUE
> xt_CONNSE
> CMARK xt_statistic xt_policy xt_multiport xt_length bridge sctp ts_kmp dccp_ipv6
> dccp_ipv4 dccp xt_pkttype ipt_LOG xt_limit autofs4 ip6t_REJECT xt_tcpudp
> ipt_REJECT x
> t_state iptable_filter ip_conntrack nfnetlink ip_tables ip6table_filter
> ip6_tables x_tables ipv6 loop dm_mod tg3 generic qla2xxx scsi_transport_fc
> firmware_class sd_m
> od scsi_mod
> NIP: D0000000000E667C LR: D0000000000E665C CTR: C000000000391EDC
> REGS: c0000000510db900 TRAP: 0300   Not tainted  (2.6.19-rc1-git6-ppc64-netfilter)
> MSR: 8000000000009032 <EE,ME,IR,DR>  CR: 24228282  XER: 200FFFFF
> DAR: D000000000D57C08, DSISR: 0000000042000000
> TASK = c000000051b300c0[6162] 'modprobe' THREAD: c0000000510d8000 CPU: 0
> GPR00: 0000000000100100 C0000000510DBB80 D0000000000F9518 C00000000F2FB0C0
> GPR04: 0000000000000002 0000000000001EDB 0000000024228282 000000000170AB80
> GPR08: 0000000000000000 0000000000200200 D000000000D72E70 D000000000D57C00
> GPR12: D0000000000E7FF0 C00000000048D400 0000000000000000 0000000010020000
> GPR16: 0000000000000001 0000000000000000 0000000000000000 0000000010028248
> GPR20: 0000000000000000 00000000100283C8 0000000000000003 0000000010001B80
> GPR24: 0000000000000001 0000000000000000 0000000010028B24 D0000000000F1528
> GPR28: 00000000000000C0 D000000000D6C8B0 D0000000000F9080 0000000000000000
> NIP [D0000000000E667C] .xt_unregister_match+0x5c/0xa0 [x_tables]
> LR [D0000000000E665C] .xt_unregister_match+0x3c/0xa0 [x_tables]
> Call Trace:
> [C0000000510DBB80] [D0000000000E665C] .xt_unregister_match+0x3c/0xa0 [x_tables]
> (unreliable)
> [C0000000510DBC20] [D0000000000E66EC] .xt_unregister_matches+0x2c/0x60 [x_tables]
> [C0000000510DBCB0] [D000000000D6C0A0] .xt_length_fini+0x20/0x38 [xt_length]
> [C0000000510DBD30] [C00000000008A6AC] .sys_delete_module+0x1f0/0x248
> [C0000000510DBE30] [C00000000000871C] syscall_exit+0x0/0x40
> Instruction dump:
> e87b0000 1f9c0060 7c7c1a14 48001999 e8410028 e95d0008 e97d0000 3c000010
> 3d200020 60000100 61290200 f96a0000 <f94b0008> f81d0000 f93d0008 60000000
> 
> Steps to reproduce:
> 
> find /lib/modules/`uname -r`/kernel/net/ -name "*.ko" | xargs -n1 basename | sed
> 's@\.ko$@@' | xargs -n1 modprobe -v
> 
> find /lib/modules/`uname -r`/kernel/net/ -name "*.ko" | xargs -n1 basename | sed
> 's@\.ko$@@' | xargs -n1 modprobe -v -r
> 
> ------- You are receiving this mail because: -------
> You are on the CC list for the bug, or are watching someone who is.

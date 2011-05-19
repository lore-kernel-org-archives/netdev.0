From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: ip_vs_ftp causing ip_vs oops on module load.
Date: Thu, 19 May 2011 09:52:47 +0200
Message-ID: <201105190952.49006.hans.schillstrom@ericsson.com>
References: <20110518201915.GB20475@redhat.com> <20110519011045.GF16688@verge.net.au> <20110519032611.GG16688@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wensong Zhang <wensong@linuxvirtualserver.org>
To: Simon Horman <horms@verge.net.au>, Dave Jones <davej@redhat.com>,
	Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw9.se.ericsson.net ([193.180.251.57]:46385 "EHLO
	mailgw9.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756336Ab1ESHww (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 03:52:52 -0400
In-Reply-To: <20110519032611.GG16688@verge.net.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello
On Thursday 19 May 2011 05:26:14 Simon Horman wrote:
> On Thu, May 19, 2011 at 10:10:46AM +0900, Simon Horman wrote:
> > On Wed, May 18, 2011 at 04:19:15PM -0400, Dave Jones wrote:
> > > I get this oops from ip_vs_ftp..
> > > 
> > >  general protection fault: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> > >  last sysfs file: /sys/module/nf_nat/refcnt
> > >  CPU 3 
> > >  Modules linked in: ip_vs(+) libcrc32c nf_nat nfsd lockd nfs_acl auth_rpcgss sunrpc cpufreq_ondemand powernow_k8 freq_table mperf ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables snd_hda_codec_realtek ppdev snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device snd_pcm microcode edac_core snd_timer k10temp snd pcspkr usb_debug edac_mce_amd soundcore snd_page_alloc sp5100_tco i2c_piix4 parport_pc parport wmi r8169 mii lm63 ipv6 pata_acpi firewire_ohci ata_generic firewire_core crc_itu_t pata_atiixp floppy radeon ttm drm_kms_helper drm i2c_algo_bit i2c_core [last unloaded: nf_nat]
> > >  
> > >  Pid: 1366, comm: modprobe Not tainted 2.6.39-rc7+ #15 Gigabyte Technology Co., Ltd. GA-MA78GM-S2H/GA-MA78GM-S2H
> > >  RIP: 0010:[<ffffffff8107bddb>]  [<ffffffff8107bddb>] notifier_chain_register+0xb/0x2a
> > >  RSP: 0018:ffff880114139e68  EFLAGS: 00010206
> > >  RAX: 2f736e74656e2f74 RBX: ffffffffa04265d0 RCX: 0000000000000003
> > >  RDX: 00000000656e6567 RSI: ffffffffa04265d0 RDI: ffffffffa04235d8
> > >  RBP: ffff880114139e68 R08: ffff880114139df8 R09: 0000000000000001
> > >  R10: 0000000000000001 R11: 00000000000001cc R12: ffffffffa0432106
> > >  R13: 0000000000000000 R14: 0000000000007f0d R15: 0000000000410e40
> > >  FS:  00007f2aaf242720(0000) GS:ffff88012a800000(0000) knlGS:0000000000000000
> > >  CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > >  CR2: 00007f2aaea0100f CR3: 000000011424f000 CR4: 00000000000006e0
> > >  DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > >  DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> > >  Process modprobe (pid: 1366, threadinfo ffff880114138000, task ffff8801146cc7a0)
> > >  Stack:
> > >   ffff880114139e78 ffffffff8107be36 ffff880114139ec8 ffffffff81403058
> > >   0000000000000000 0000000000000000 ffff880114139ea8 0000000000000000
> > >   ffffffffa0432106 0000000000000000 0000000000007f0d 0000000000410e40
> > >  Call Trace:
> > >   [<ffffffff8107be36>] raw_notifier_chain_register+0xe/0x10
> > >   [<ffffffff81403058>] register_netdevice_notifier+0x2d/0x1b6
> > >   [<ffffffffa0432106>] ? ip_vs_conn_init+0x106/0x106 [ip_vs]
> > >   [<ffffffffa04322c7>] ip_vs_control_init+0xa5/0xce [ip_vs]
> > >   [<ffffffffa0432106>] ? ip_vs_conn_init+0x106/0x106 [ip_vs]
> > >   [<ffffffffa0432116>] ip_vs_init+0x10/0x11c [ip_vs]
> > >   [<ffffffff81002099>] do_one_initcall+0x7f/0x13a
> > >   [<ffffffff81096524>] sys_init_module+0x132/0x281
> > >   [<ffffffff814cc702>] system_call_fastpath+0x16/0x1b
> > >  Code: 07 ff c8 89 43 48 eb 08 48 89 df e8 dc 95 44 00 4c 89 e6 48 89 df e8 a7 a5 44 00 5b 41 5c 5d c3 55 48 89 e5 66 66 66 66 90 eb 0c <8b> 50 10 39 56 10 7f 0c 48 8d 78 08 48 8b 07 48 85 c0 75 ec 48 
> > >  RIP  [<ffffffff8107bddb>] notifier_chain_register+0xb/0x2a
> > >   RSP <ffff880114139e68>
> > >  ---[ end trace e90d7053ad1a7a5b ]---
> > > 
> > > 
> > > This script replicates the bug.
> > > (it usually oopses after just a few loops)
> > > 
> > > #!/bin/sh
> > > while [ 1 ];
> > > do
> > > 	modprobe ip_vs_ftp
> > > 	modprobe -r ip_vs_ftp
> > > done
> > > 
> > > Looks like something isn't getting cleaned up on module exit
> > > that we fall over when we encounter it next time it gets loaded ?

It's a bug in ip_vs_ftp related to netns.

> > 
> > Thanks Dave, I will look into this.
> 
> Hi Dave,
> 
> I'm not having much luck reproducing this in KVM.
> I will try this evening on real hardware.
> 
> Just to make sure we are testing the same thing, are you using Linus's tree?
> --
I can reproduce the source of the problem,
use multiple netns and then unload the ftp module...
i.e. same list head used in multiple netns

This brings up a question:
- How should ftp be handled in a netns ? 
You might want to have it in one netns but not in another,
this requires changes to ipvsadm

A way of doing it could be a disable switch like --noftp [port,port]
i.e. do not break old apps.

Any other ideas ?

This patch solves the root problem, I'm not sure if this is the way to go
or if we should split the ip_vs_app struct ?

If it's the way to go I can send it as a proper formated patch ...
(after some testing)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 4fff432..481f856 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -797,7 +797,8 @@ struct netns_ipvs {
 	struct list_head	rs_table[IP_VS_RTAB_SIZE];
 	/* ip_vs_app */
 	struct list_head	app_list;
-
+	/* ip_vs_ftp */
+	struct ip_vs_app	*ftp_app;
 	/* ip_vs_proto */
 	#define IP_VS_PROTO_TAB_SIZE	32	/* must be power of 2 */
 	struct ip_vs_proto_data *proto_data_table[IP_VS_PROTO_TAB_SIZE];
diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index 6b5dd6d..17afb09 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -411,25 +411,36 @@ static struct ip_vs_app ip_vs_ftp = {
 static int __net_init __ip_vs_ftp_init(struct net *net)
 {
 	int i, ret;
-	struct ip_vs_app *app = &ip_vs_ftp;
+	struct ip_vs_app *app;
+	struct netns_ipvs *ipvs = net_ipvs(net);
+
+	app = kmemdup(&ip_vs_ftp, sizeof(struct ip_vs_app), GFP_KERNEL);
+	if (!app)
+		return -ENOMEM;
+	INIT_LIST_HEAD(&app->a_list);
+	INIT_LIST_HEAD(&app->incs_list);
+	INIT_LIST_HEAD(&app->p_list);
+	ipvs->ftp_app = app;
 
 	ret = register_ip_vs_app(net, app);
 	if (ret)
-		return ret;
+		goto err_exit;
 
 	for (i=0; i<IP_VS_APP_MAX_PORTS; i++) {
 		if (!ports[i])
 			continue;
 		ret = register_ip_vs_app_inc(net, app, app->protocol, ports[i]);
 		if (ret)
-			break;
+			goto err_unreg;
 		pr_info("%s: loaded support on port[%d] = %d\n",
 			app->name, i, ports[i]);
 	}
+	return 0;
 
-	if (ret)
-		unregister_ip_vs_app(net, app);
-
+err_unreg:
+	unregister_ip_vs_app(net, app);
+err_exit:
+	kfree(ipvs->ftp_app);
 	return ret;
 }
 /*
@@ -437,9 +448,7 @@ static int __net_init __ip_vs_ftp_init(struct net *net)
  */
 static void __ip_vs_ftp_exit(struct net *net)
 {
-	struct ip_vs_app *app = &ip_vs_ftp;
-
-	unregister_ip_vs_app(net, app);
+	unregister_ip_vs_app(net, net_ipvs(net)->ftp_app);
 }
 
 static struct pernet_operations ip_vs_ftp_ops = {


-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>

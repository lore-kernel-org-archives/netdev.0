From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] xfrm: avoid spinlock in get_acqseq()
Date: Fri, 29 Jan 2010 17:00:19 +0100
Message-ID: <1264780819.3184.33.camel@edumazet-laptop>
References: <1264773952.3184.22.camel@edumazet-laptop>
	 <20100129151149.GD20701@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Benjamin LaHaise <bcrl@lhnet.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:65319 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751178Ab0A2QA0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2010 11:00:26 -0500
Received: by bwz27 with SMTP id 27so1550132bwz.21
        for <netdev@vger.kernel.org>; Fri, 29 Jan 2010 08:00:23 -0800 (PST)
In-Reply-To: <20100129151149.GD20701@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 29 janvier 2010 =C3=A0 10:11 -0500, Benjamin LaHaise a =C3=A9=
crit :
> Hi Eric,
>=20
> On Fri, Jan 29, 2010 at 03:05:52PM +0100, Eric Dumazet wrote:
> > Use atomic_inc_return() in get_acqseq() to avoid taking a spinlock
> > +	static atomic_t acqseq;
>=20
> I think that needs to be:
> 	static atomic_t acqseq =3D ATOMIC_INIT(0);
>=20
> Cheers,
>=20
> 	-ben

Not sure its needed now that atomic_t is an integral 32bits type for al=
l
arches, or a cleanup patch is wanted :)

Thanks !


=2E/security/tomoyo/realpath.c:412:static atomic_t tomoyo_dynamic_memor=
y_size;
=2E/arch/sh/kernel/perf_event.c:41:static atomic_t num_events;
=2E/arch/um/kernel/smp.c:199:static atomic_t scf_started;
=2E/arch/um/kernel/smp.c:200:static atomic_t scf_finished;
=2E/arch/ia64/kernel/mca.c:1287:	static atomic_t mca_count;
=2E/arch/ia64/kernel/mca.c:1661:	static atomic_t slaves;
=2E/arch/ia64/kernel/mca.c:1662:	static atomic_t monarchs;
=2E/arch/ia64/kernel/crash.c:24:static atomic_t kdump_cpu_frozen;
=2E/arch/x86/mm/mmio-mod.c:62:static atomic_t mmiotrace_enabled;
=2E/arch/x86/mm/mmio-mod.c:237:	static atomic_t next_id;
=2E/arch/x86/kernel/cpu/perf_event.c:714:static atomic_t active_events;
=2E/arch/x86/kernel/cpu/mcheck/mce.c:238:static atomic_t mce_paniced;
=2E/arch/x86/kernel/cpu/mcheck/mce.c:241:static atomic_t mce_fake_panic=
ed;
=2E/arch/x86/kernel/cpu/mcheck/mce.c:614:static atomic_t mce_executing;
=2E/arch/x86/kernel/cpu/mcheck/mce.c:619:static atomic_t mce_callin;
=2E/arch/x86/kernel/cpu/mcheck/mce.c:727:static atomic_t global_nwo;
=2E/arch/x86/kernel/tboot.c:297:static atomic_t ap_wfs_count;
=2E/arch/x86/kernel/reboot.c:724:static atomic_t waiting_for_crash_ipi;
=2E/arch/blackfin/kernel/irqchip.c:17:static atomic_t irq_err_count;
=2E/arch/microblaze/kernel/of_device.c:14:	static atomic_t bus_no_reg_m=
agic;
=2E/arch/powerpc/platforms/iseries/viopath.c:74:static atomic_t event_b=
uffer_available[VIO_MAX_SUBTYPES];
=2E/arch/powerpc/kernel/of_device.c:15:	static atomic_t bus_no_reg_magi=
c;
=2E/arch/powerpc/kernel/perf_event.c:959:static atomic_t num_events;
=2E/mm/memcontrol.c:1283:static atomic_t memcg_drain_count;
=2E/virt/kvm/kvm_main.c:75:static atomic_t hardware_enable_failed;
=2E/net/netfilter/nfnetlink_log.c:71:static atomic_t global_seq;
=2E/net/decnet/af_decnet.c:158:static atomic_t decnet_memory_allocated;
=2E/net/llc/llc_conn.c:775:static atomic_t llc_sock_nr;
=2E/net/core/netpoll.c:41:static atomic_t trapped;
=2E/net/sctp/socket.c:116:static atomic_t sctp_memory_allocated;
=2E/net/sunrpc/sched.c:238:	static atomic_t rpc_pid;
=2E/fs/ocfs2/stack_user.c:160:static atomic_t ocfs2_control_opened;
=2E/fs/notify/inotify/inotify.c:37:static atomic_t inotify_cookie;
=2E/fs/notify/inotify/inotify_user.c:62:static atomic_t inotify_grp_num=
;
=2E/fs/afs/rxrpc.c:20:static atomic_t afs_outstanding_calls;
=2E/fs/afs/rxrpc.c:21:static atomic_t afs_outstanding_skbs;
=2E/fs/afs/super.c:59:static atomic_t afs_count_active_inodes;
=2E/fs/quota/quota.c:558:	static atomic_t seq;
=2E/fs/dlm/user.c:29:static atomic_t dlm_monitor_opened;
=2E/fs/ecryptfs/miscdev.c:31:static atomic_t ecryptfs_num_miscdev_opens=
;
=2E/kernel/rcutree.c:1575:static atomic_t rcu_barrier_cpu_count;
=2E/kernel/trace/trace.c:807:static atomic_t trace_record_cmdline_disab=
led __read_mostly;
=2E/kernel/trace/trace_mmiotrace.c:26:static atomic_t dropped_count;
=2E/kernel/slow-work.c:85:static atomic_t slow_work_thread_count;
=2E/kernel/slow-work.c:86:static atomic_t vslow_work_executing_count;
=2E/kernel/rtmutex-tester.c:24:static atomic_t rttest_event;
=2E/kernel/async.c:83:static atomic_t entry_count;
=2E/kernel/async.c:84:static atomic_t thread_count;
=2E/kernel/perf_event.c:45:static atomic_t nr_events __read_mostly;
=2E/kernel/perf_event.c:46:static atomic_t nr_mmap_events __read_mostly=
;
=2E/kernel/perf_event.c:47:static atomic_t nr_comm_events __read_mostly=
;
=2E/kernel/perf_event.c:48:static atomic_t nr_task_events __read_mostly=
;
=2E/kernel/profile.c:42:static atomic_t *prof_buffer;
=2E/kernel/rcutorture.c:121:static atomic_t rcu_torture_wcount[RCU_TORT=
URE_PIPE_LEN + 1];
=2E/kernel/rcutorture.c:122:static atomic_t n_rcu_torture_alloc;
=2E/kernel/rcutorture.c:123:static atomic_t n_rcu_torture_alloc_fail;
=2E/kernel/rcutorture.c:124:static atomic_t n_rcu_torture_free;
=2E/kernel/rcutorture.c:125:static atomic_t n_rcu_torture_mberror;
=2E/kernel/rcutorture.c:126:static atomic_t n_rcu_torture_error;
=2E/kernel/stop_machine.c:39:static atomic_t thread_ack;
=2E/kernel/kgdb.c:124:static atomic_t			passive_cpu_wait[NR_CPUS];
=2E/kernel/kgdb.c:125:static atomic_t			cpu_in_kgdb[NR_CPUS];
=2E/kernel/time/timer_stats.c:119:static atomic_t overflow_count;
=2E/drivers/dma/ppc4xx/adma.c:106:static atomic_t ppc440spe_adma_err_ir=
q_ref;
=2E/drivers/s390/cio/css.c:470:static atomic_t css_eval_scheduled;
=2E/drivers/s390/cio/cio.c:960:static atomic_t chpid_reset_count;
=2E/drivers/pci/hotplug/cpci_hotplug_core.c:59:static atomic_t extracti=
ng;
=2E/drivers/char/rocket.c:114:static atomic_t rp_num_ports_open;	      =
         /*  Number of serial ports open                           */
=2E/drivers/char/ipmi/ipmi_msghandler.c:4044:static atomic_t stop_opera=
tion;
=2E/drivers/md/md.c:160:static atomic_t md_event_count;
=2E/drivers/ieee1394/raw1394.c:79:static atomic_t iso_buffer_size;
=2E/drivers/usb/serial/io_edgeport.c:196:static atomic_t CmdUrbs;	/* Nu=
mber of outstanding Command Write Urbs */
=2E/drivers/net/pppol2tp.c:229:static atomic_t pppol2tp_tunnel_count;
=2E/drivers/net/pppol2tp.c:230:static atomic_t pppol2tp_session_count;
=2E/drivers/net/vmxnet3/vmxnet3_drv.c:45:static atomic_t devices_found;
=2E/drivers/watchdog/bcm47xx_wdt.c:52:static atomic_t ticks;
=2E/drivers/staging/batman-adv/routing.c:46:static atomic_t data_ready_=
cond;
=2E/drivers/scsi/lpfc/lpfc_debugfs.c:1214:static atomic_t lpfc_debugfs_=
hba_count;
=2E/drivers/scsi/scsi_transport_fc.c:484:static atomic_t fc_event_seq;
=2E/drivers/scsi/hosts.c:43:static atomic_t scsi_host_next_hn;	/* host_=
no for next new host */
=2E/drivers/scsi/scsi_transport_iscsi.c:84:static atomic_t iscsi_sessio=
n_nr; /* sysfs session id for next new session */
=2E/drivers/scsi/qla2xxx/qla_dfs.c:13:static atomic_t qla2x00_dfs_root_=
count;
=2E/drivers/crypto/hifn_795x.c:54:static atomic_t hifn_dev_number;



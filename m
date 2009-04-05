From: bmb <bmb@athenacr.com>
Subject: Re: Multicast packet loss
Date: Sun, 5 Apr 2009 10:42:28 -0400
Message-ID: <0a4067a2f206cf1493724ccd63ddc53c@athenacr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, kchang@athenacr.com,
	netdev@vger.kernel.org, cl@linux-foundation.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sprinkles.athenacr.com ([64.95.46.210]:1027 "EHLO
	sprinkles.inp.in.athenacr.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752680AbZDEOmf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Apr 2009 10:42:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Could you please send me the diff of your backport against this kerne=
l ?

Sure, the patch is at the bottom. It's against the tag: Ubuntu-2.6.24-1=
9.41
from git://kernel.ubuntu.com/ubuntu/ubuntu-hardy.git

> I take you use Ubuntu Hardys 8.04 LTS server edition ?

Yes. We can only reproduce this in production right now, so trying out
a newer kernel would take some effort.

Thanks,
Brian Bloniarz

On Sun, 05 Apr 2009 15:49:14 +0200, Eric Dumazet <dada1@cosmosbay.com>
wrote:
> Brian Bloniarz a =C3=A9crit :
>> Hi Eric,
>>
>> We've been experimenting with this softirq-delay patch in production=
,
> and
>> have seen some hard-to-reproduce crashes. We finally managed to capt=
ure
> a
>> kexec crashdump this morning.
>>
>> This is the dmesg:
>>
>> [53417.592868] Unable to handle kernel NULL pointer dereference at
>> 0000000000000000 RIP:
>> [53417.598377]  [<ffffffff80243643>] __do_softirq+0xc3/0x150
>> [53417.606300] PGD 32abb8067 PUD 32faf5067 PMD 0
>> [53417.610829] Oops: 0000 [1] SMP
>> [53417.614032] CPU 2
>> [53417.616083] Modules linked in: nfs lockd nfs_acl sunrpc openafs(P=
)
>> autofs4 ipv6 ac sbs sbshc video output dock battery container
>> iptable_filter ip_tables x_tables parport_pc lp parport loop joydev
>> iTCO_wdt iTCO_vendor_support evdev button i5000_edac psmouse serio_r=
aw
>> pcspkr shpchp pci_hotplug edac_core ext3 jbd mbcache sr_mod cdrom
>> ata_generic usbhid hid ata_piix sg sd_mod ehci_hcd pata_acpi uhci_hc=
d
>> libata bnx2 aacraid usbcore scsi_mod thermal processor fan fbcon
>> tileblit font bitblit softcursor fuse
>> [53417.662067] Pid: 13039, comm: gball Tainted: P
>> 2.6.24-19acr2-generic #1
>> [53417.669219] RIP: 0010:[<ffffffff80243643>]  [<ffffffff80243643>]
>> __do_softirq+0xc3/0x150
>> [53417.677368] RSP: 0018:ffff8103314f3f20  EFLAGS: 00010297
>> [53417.682697] RAX: ffff810084a1b000 RBX: ffffffff805ba530 RCX:
>> 0000000000000000
>> [53417.689843] RDX: ffff8103305811e0 RSI: 0000000000000282 RDI:
>> ffff810332ada580
>> [53417.696993] RBP: 0000000000000000 R08: ffff81032fad9f08 R09:
>> ffff810332382000
>> [53417.704144] R10: 0000000000000000 R11: ffffffff80316ec0 R12:
>> ffffffff8062b3d8
>> [53417.711294] R13: ffffffff8062b480 R14: 0000000000000002 R15:
>> 000000000000000a
>> [53417.718447] FS:  00007fab0d7b8750(0000) GS:ffff810334401b80(0000)
>> knlGS:0000000000000000
>> [53417.726568] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>> [53417.732332] CR2: 0000000000000000 CR3: 0000000329e2d000 CR4:
>> 00000000000006e0
>> [53417.739476] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
>> 0000000000000000
>> [53417.746637] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
>> 0000000000000400
>> [53417.753787] Process gball (pid: 13039, threadinfo ffff81032adde00=
0,
>> task ffff810329ff77d0)
>> [53417.761991] Stack:  ffffffff8062b3d8 0000000000000046
>> ffff8103314f3f68 0000000000000000
>> [53417.770146]  00000000000000a0 ffff81032addfee8 0000000000000000
>> ffffffff8020d50c
>> [53417.777660]  ffff8103314f3f68 00000000000000c1 ffffffff8020ed25
>> ffffffff8062c870
>> [53417.784961] Call Trace:
>> [53417.787635]  <IRQ>  [<ffffffff8020d50c>] call_softirq+0x1c/0x30
>> [53417.793597]  [<ffffffff8020ed25>] do_softirq+0x35/0x90
>> [53417.798747]  [<ffffffff80243578>] irq_exit+0x88/0x90
>> [53417.803727]  [<ffffffff8020ef70>] do_IRQ+0x80/0x100
>> [53417.808624]  [<ffffffff8020c891>] ret_from_intr+0x0/0xa
>> [53417.813862]  <EOI>  [<ffffffff803e53c8>] skb_release_all+0x18/0x1=
50
>> [53417.820164]  [<ffffffff803e4ad9>] __kfree_skb+0x9/0x90
>> [53417.825327]  [<ffffffff80437612>] udp_recvmsg+0x222/0x260
>> [53417.830744]  [<ffffffff80231264>] source_load+0x34/0x70
>> [53417.835984]  [<ffffffff80232a9a>] find_busiest_group+0x1fa/0x850
>> [53417.842019]  [<ffffffff803e0100>] sock_common_recvmsg+0x30/0x50
>> [53417.847958]  [<ffffffff803de1ca>] sock_recvmsg+0x14a/0x160
>> [53417.853462]  [<ffffffff80231c21>] update_curr+0x71/0x100
>> [53419.858789]  [<ffffffff802320fd>] __dequeue_entity+0x3d/0x50
>> [53417.864469]  [<ffffffff80253ab0>] autoremove_wake_function+0x0/0x=
30
>> [53417.870758]  [<ffffffff8046662f>] thread_return+0x3a/0x57b
>> [53417.876262]  [<ffffffff803df73e>] sys_recvfrom+0xfe/0x190
>> [53417.881680]  [<ffffffff802e2a95>] sys_epoll_wait+0x245/0x4e0
>> [53417.887358]  [<ffffffff80233e20>] default_wake_function+0x0/0x10
>> [53417.893384]  [<ffffffff8020c37e>] system_call+0x7e/0x83
>> [53417.898628]
>> [53417.900134]
>> [53417.900134] Code: 48 8b 11 48 89 cf 65 48 8b 04 25 08 00 00 00 4a=
 89
>> 14 20 ff
>> [53417.909430] RIP  [<ffffffff80243643>] __do_softirq+0xc3/0x150
>> [53417.915210]  RSP <ffff8103314f3f20>
>>
>> The disassembly where it crashed:
>> /local/home/bmb/doc/kernels/linux-hardy-eric/kernel/softirq.c:273
>> ffffffff8024361b:       d1 ed                   shr    %ebp
>> rcu_bh_qsctr_inc():
>>
> /local/home/bmb/doc/kernels/linux-hardy-eric/include/linux/rcupdate.h=
:130
>> ffffffff8024361d:       48 8b 40 08             mov    0x8(%rax),%ra=
x
>> ffffffff80243621:       41 c7 44 05 08 01 00    movl
>> $0x1,0x8(%r13,%rax,1)
>> ffffffff80243628:       00 00
>> __do_softirq():
>> /local/home/bmb/doc/kernels/linux-hardy-eric/kernel/softirq.c:273
>> ffffffff8024362a:       75 d8                   jne    ffffffff80243=
604
>> <__do_softirq+0x84>
>> softirq_delay_exec():
>> /local/home/bmb/doc/kernels/linux-hardy-eric/kernel/softirq.c:225
>> ffffffff8024362c:       48 8b 14 24             mov    (%rsp),%rdx
>> ffffffff80243630:       65 48 8b 04 25 08 00    mov    %gs:0x8,%rax
>> ffffffff80243637:       00 00
>> ffffffff80243639:       48 8b 0c 10             mov
> (%rax,%rdx,1),%rcx
>> ffffffff8024363d:       48 83 f9 01             cmp    $0x1,%rcx
>> ffffffff80243641:       74 29                   je     ffffffff80243=
66c
>> <__do_softirq+0xec>
>> /local/home/bmb/doc/kernels/linux-hardy-eric/kernel/softirq.c:226
>> ffffffff80243643:       48 8b 11                mov    (%rcx),%rdx
>> /local/home/bmb/doc/kernels/linux-hardy-eric/kernel/softirq.c:227
>> ffffffff80243646:       48 89 cf                mov    %rcx,%rdi
>> /local/home/bmb/doc/kernels/linux-hardy-eric/kernel/softirq.c:226
>> ffffffff80243649:       65 48 8b 04 25 08 00    mov    %gs:0x8,%rax
>> ffffffff80243650:       00 00
>> ffffffff80243652:       4a 89 14 20             mov
> %rdx,(%rax,%r12,1)
>> /local/home/bmb/doc/kernels/linux-hardy-eric/kernel/softirq.c:227
>> ffffffff80243656:       ff 51 08                callq  *0x8(%rcx)
>> /local/home/bmb/doc/kernels/linux-hardy-eric/kernel/softirq.c:225
>> ffffffff80243659:       65 48 8b 04 25 08 00    mov    %gs:0x8,%rax
>> ffffffff80243660:       00 00
>> ffffffff80243662:       4a 8b 0c 20             mov
> (%rax,%r12,1),%rcx
>> ffffffff80243666:       48 83 f9 01             cmp    $0x1,%rcx
>> ffffffff8024366a:       75 d7                   jne    ffffffff80243=
643
>> <__do_softirq+0xc3>
>> raw_local_irq_disable():
>>
>
/local/home/bmb/doc/kernels/linux-hardy-eric/debian/build/build-generic=
/include2/asm/irqflags_64.h:76
>>
>> ffffffff8024366c:       fa                      cli
>>
>> And softirq.c line numbers:
>>    218   * Because locking is provided by subsystem, please note
>>    219   * that sdel->func(sdel) is responsible for setting sdel->ne=
xt
>> to NULL
>>    220   */
>>    221  static void softirq_delay_exec(void)
>>    222  {
>>    223          struct softirq_delay *sdel;
>>    224
>>    225          while ((sdel =3D __get_cpu_var(softirq_delay_head)) =
!=3D
>> SOFTIRQ_DELAY_END) {
>>    226                  __get_cpu_var(softirq_delay_head) =3D sdel->=
next;
>>    227                  sdel->func(sdel);       /*      sdel->next =3D
>> NULL;*/
>>    228                  }
>>    229  }
>>
>> So it's crashing because __get_cpu_var(softirq_delay_head)) is NULL
>> somehow.
>>
>> We aren't running a recent kernel -- we're running Ubuntu Hardy's
>> 2.6.24-19,
>> with a backported version of this patch. One more atypical thing is =
that
>> we run openafs, 1.4.6.dfsg1-2.
>>
>> Like I said, I have a full vmcore (3, actually) and would be happy t=
o
>> post any
>> more information you'd like to know.
>>
>> Thanks,
>> Brian Bloniarz
>
> Hi Brian
>
> 2.6.24-19 kernel... hmm...
>
> Could you please send me the diff of your backport against this kerne=
l ?
>
> I take you use Ubuntu Hardys 8.04 LTS server edition ?
>
> Pointer being null might tell us that we managed to call
> inet_def_readable()
> without socket lock hold...

diff --git a/include/linux/interrupt.h b/include/linux/interrupt.h
index 2306920..b79a207 100644
--- a/include/linux/interrupt.h
+++ b/include/linux/interrupt.h
@@ -276,6 +276,24 @@ extern void FASTCALL(raise_softirq_irqoff(unsigned=
 int
nr));
 extern void FASTCALL(raise_softirq(unsigned int nr));


+/*
+ * softirq delayed works : should be delayed at do_softirq() end
+ */
+struct softirq_delay {
+	struct softirq_delay	*next;
+	void 			(*func)(struct softirq_delay *);
+};
+
+int softirq_delay_queue(struct softirq_delay *sdel);
+
+static inline void softirq_delay_init(struct softirq_delay *sdel,
+				      void (*func)(struct softirq_delay *))
+{
+	sdel->next =3D NULL;
+	sdel->func =3D func;
+}
+
+
 /* Tasklets --- multithreaded analogue of BHs.

    Main feature differing them of generic softirqs: tasklet
diff --git a/include/linux/irqflags.h b/include/linux/irqflags.h
index 412e025..f7b48a1 100644
--- a/include/linux/irqflags.h
+++ b/include/linux/irqflags.h
@@ -11,19 +11,21 @@
 #ifndef _LINUX_TRACE_IRQFLAGS_H
 #define _LINUX_TRACE_IRQFLAGS_H

+#define softirq_enter()	do { current->softirq_context++; } while (0)
+#define softirq_exit()	do { current->softirq_context--; } while (0)
+#define softirq_context(p)	((p)->softirq_context)
+#define running_from_softirq()  (softirq_context(current) > 0)
+
 #ifdef CONFIG_TRACE_IRQFLAGS
   extern void trace_hardirqs_on(void);
   extern void trace_hardirqs_off(void);
   extern void trace_softirqs_on(unsigned long ip);
   extern void trace_softirqs_off(unsigned long ip);
 # define trace_hardirq_context(p)	((p)->hardirq_context)
-# define trace_softirq_context(p)	((p)->softirq_context)
 # define trace_hardirqs_enabled(p)	((p)->hardirqs_enabled)
 # define trace_softirqs_enabled(p)	((p)->softirqs_enabled)
 # define trace_hardirq_enter()	do { current->hardirq_context++; } whil=
e
(0)
 # define trace_hardirq_exit()	do { current->hardirq_context--; } while=
 (0)
-# define trace_softirq_enter()	do { current->softirq_context++; } whil=
e
(0)
-# define trace_softirq_exit()	do { current->softirq_context--; } while=
 (0)
 # define INIT_TRACE_IRQFLAGS	.softirqs_enabled =3D 1,
 #else
 # define trace_hardirqs_on()		do { } while (0)
@@ -31,13 +33,10 @@
 # define trace_softirqs_on(ip)		do { } while (0)
 # define trace_softirqs_off(ip)		do { } while (0)
 # define trace_hardirq_context(p)	0
-# define trace_softirq_context(p)	0
 # define trace_hardirqs_enabled(p)	0
 # define trace_softirqs_enabled(p)	0
 # define trace_hardirq_enter()		do { } while (0)
 # define trace_hardirq_exit()		do { } while (0)
-# define trace_softirq_enter()		do { } while (0)
-# define trace_softirq_exit()		do { } while (0)
 # define INIT_TRACE_IRQFLAGS
 #endif

diff --git a/include/linux/net.h b/include/linux/net.h
index 596131e..9e762e9 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -115,12 +115,16 @@ enum sock_shutdown_cmd {
 struct socket {
 	socket_state		state;
 	unsigned long		flags;
-	const struct proto_ops	*ops;
+	/*
+	 * Please keep fasync_list & wait fields in the same cache line
+	 */
 	struct fasync_struct	*fasync_list;
+	wait_queue_head_t	wait;
+
 	struct file		*file;
 	struct sock		*sk;
-	wait_queue_head_t	wait;
 	short			type;
+	const struct proto_ops	*ops;
 };

 struct vm_area_struct;
diff --git a/include/linux/sched.h b/include/linux/sched.h
index dc2f4fa..bf0ff49 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1111,8 +1111,8 @@ struct task_struct {
 	unsigned long softirq_enable_ip;
 	unsigned int softirq_enable_event;
 	int hardirq_context;
-	int softirq_context;
 #endif
+	int softirq_context;
 #ifdef CONFIG_LOCKDEP
 # define MAX_LOCK_DEPTH 30UL
 	u64 curr_chain_key;
diff --git a/include/net/sock.h b/include/net/sock.h
index 6e1542d..fb0f719 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -236,6 +236,7 @@ struct sock {
 	unsigned long	        sk_lingertime;
 	struct sk_buff_head	sk_error_queue;
 	struct proto		*sk_prot_creator;
+	struct softirq_delay	sk_delay;
 	rwlock_t		sk_callback_lock;
 	int			sk_err,
 				sk_err_soft;
@@ -859,6 +860,7 @@ extern void *sock_kmalloc(struct sock *sk, int size=
,
 			  gfp_t priority);
 extern void sock_kfree_s(struct sock *sk, void *mem, int size);
 extern void sk_send_sigurg(struct sock *sk);
+extern void inet_def_readable(struct sock *sk, int len);

 /*
  * Functions to fill in entries in struct proto_ops when a protocol
diff --git a/include/net/udplite.h b/include/net/udplite.h
index 635b0ea..1589817 100644
--- a/include/net/udplite.h
+++ b/include/net/udplite.h
@@ -28,6 +28,7 @@ static __inline__ int udplite_getfrag(void *from, cha=
r
*to, int  offset,
 /* Designate sk as UDP-Lite socket */
 static inline int udplite_sk_init(struct sock *sk)
 {
+	sk->sk_data_ready =3D inet_def_readable;
 	udp_sk(sk)->pcflag =3D UDPLITE_BIT;
 	return 0;
 }
diff --git a/kernel/lockdep.c b/kernel/lockdep.c
index e2c07ec..decb1f7 100644
--- a/kernel/lockdep.c
+++ b/kernel/lockdep.c
@@ -1643,7 +1643,7 @@ print_usage_bug(struct task_struct *curr, struct
held_lock *this,
 	printk("%s/%d [HC%u[%lu]:SC%u[%lu]:HE%u:SE%u] takes:\n",
 		curr->comm, task_pid_nr(curr),
 		trace_hardirq_context(curr), hardirq_count() >> HARDIRQ_SHIFT,
-		trace_softirq_context(curr), softirq_count() >> SOFTIRQ_SHIFT,
+		softirq_context(curr), softirq_count() >> SOFTIRQ_SHIFT,
 		trace_hardirqs_enabled(curr),
 		trace_softirqs_enabled(curr));
 	print_lock(this);
diff --git a/kernel/softirq.c b/kernel/softirq.c
index bd89bc4..fb116ac 100644
--- a/kernel/softirq.c
+++ b/kernel/softirq.c
@@ -194,6 +194,42 @@ void local_bh_enable_ip(unsigned long ip)
 }
 EXPORT_SYMBOL(local_bh_enable_ip);

+
+#define SOFTIRQ_DELAY_END (struct softirq_delay *)1L
+static DEFINE_PER_CPU(struct softirq_delay *, softirq_delay_head) =3D =
{
+	SOFTIRQ_DELAY_END
+};
+
+/*
+ * Caller must disable preemption, and take care of appropriate
+ * locking and refcounting
+ */
+int softirq_delay_queue(struct softirq_delay *sdel)
+{
+	if (!sdel->next) {
+		sdel->next =3D __get_cpu_var(softirq_delay_head);
+		__get_cpu_var(softirq_delay_head) =3D sdel;
+		return 1;
+	}
+	return 0;
+}
+
+/*
+ * Because locking is provided by subsystem, please note
+ * that sdel->func(sdel) is responsible for setting sdel->next to NULL
+ */
+static void softirq_delay_exec(void)
+{
+	struct softirq_delay *sdel;
+
+	while ((sdel =3D __get_cpu_var(softirq_delay_head)) !=3D SOFTIRQ_DELA=
Y_END) {
+		__get_cpu_var(softirq_delay_head) =3D sdel->next;
+		sdel->func(sdel);	/*	sdel->next =3D NULL;*/
+		}
+}
+
+
+
 /*
  * We restart softirq processing MAX_SOFTIRQ_RESTART times,
  * and we fall back to softirqd after that.
@@ -216,7 +252,7 @@ asmlinkage void __do_softirq(void)
 	account_system_vtime(current);

 	__local_bh_disable((unsigned long)__builtin_return_address(0));
-	trace_softirq_enter();
+	softirq_enter();

 	cpu =3D smp_processor_id();
 restart:
@@ -236,6 +272,8 @@ restart:
 		pending >>=3D 1;
 	} while (pending);

+	softirq_delay_exec();
+
 	local_irq_disable();

 	pending =3D local_softirq_pending();
@@ -245,7 +283,7 @@ restart:
 	if (pending)
 		wakeup_softirqd();

-	trace_softirq_exit();
+	softirq_exit();

 	account_system_vtime(current);
 	_local_bh_enable();
diff --git a/lib/locking-selftest.c b/lib/locking-selftest.c
index 280332c..1aa7351 100644
--- a/lib/locking-selftest.c
+++ b/lib/locking-selftest.c
@@ -157,11 +157,11 @@ static void init_shared_classes(void)
 #define SOFTIRQ_ENTER()				\
 		local_bh_disable();		\
 		local_irq_disable();		\
-		trace_softirq_enter();		\
+		softirq_enter();		\
 		WARN_ON(!in_softirq());

 #define SOFTIRQ_EXIT()				\
-		trace_softirq_exit();		\
+		softirq_exit();		\
 		local_irq_enable();		\
 		local_bh_enable();

diff --git a/net/core/sock.c b/net/core/sock.c
index c519b43..cb70343 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -213,6 +213,8 @@ __u32 sysctl_rmem_default __read_mostly =3D SK_RMEM=
_MAX;
 /* Maximal space eaten by iovec or ancilliary data plus some space */
 int sysctl_optmem_max __read_mostly =3D sizeof(unsigned
long)*(2*UIO_MAXIOV+512);

+static void sock_readable_defer(struct softirq_delay *sdel);
+
 static int sock_set_timeout(long *timeo_p, char __user *optval, int
optlen)
 {
 	struct timeval tv;
@@ -996,6 +998,7 @@ struct sock *sk_clone(const struct sock *sk, const
gfp_t priority)
 #endif

 		rwlock_init(&newsk->sk_dst_lock);
+		softirq_delay_init(&newsk->sk_delay, sock_readable_defer);
 		rwlock_init(&newsk->sk_callback_lock);
 		lockdep_set_class_and_name(&newsk->sk_callback_lock,
 				af_callback_keys + newsk->sk_family,
@@ -1509,6 +1512,45 @@ static void sock_def_readable(struct sock *sk, i=
nt
len)
 	read_unlock(&sk->sk_callback_lock);
 }

+/*
+ * helper function called by softirq_delay_exec(),
+ * if inet_def_readable() queued us.
+ */
+static void sock_readable_defer(struct softirq_delay *sdel)
+{
+	struct sock *sk =3D container_of(sdel, struct sock, sk_delay);
+
+	sdel->next =3D NULL;
+	/*
+	 * At this point, we dont own a lock on socket, only a reference.
+	 * We must commit above write, or another cpu could miss a wakeup
+	 */
+	smp_wmb();
+	sock_def_readable(sk, 0);
+	sock_put(sk);
+}
+
+/*
+ * Custom version of sock_def_readable()
+ * We want to defer scheduler processing at the end of do_softirq()
+ * Called with socket locked.
+ */
+void inet_def_readable(struct sock *sk, int len)
+{
+	if (running_from_softirq()) {
+		if (softirq_delay_queue(&sk->sk_delay))
+			/*
+			 * If we queued this socket, take a reference on it
+			 * Caller owns socket lock, so write to sk_delay.next
+			 * will be committed before unlock.
+			 */
+			sock_hold(sk);
+	} else
+		sock_def_readable(sk, len);
+}
+
+EXPORT_SYMBOL(inet_def_readable);
+
 static void sock_def_write_space(struct sock *sk)
 {
 	read_lock(&sk->sk_callback_lock);
@@ -1586,6 +1628,7 @@ void sock_init_data(struct socket *sock, struct s=
ock
*sk)
 		sk->sk_sleep	=3D	NULL;

 	rwlock_init(&sk->sk_dst_lock);
+	softirq_delay_init(&sk->sk_delay, sock_readable_defer);
 	rwlock_init(&sk->sk_callback_lock);
 	lockdep_set_class_and_name(&sk->sk_callback_lock,
 			af_callback_keys + sk->sk_family,
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 03c400c..cfeb051 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1226,6 +1226,12 @@ int udp_destroy_sock(struct sock *sk)
 	return 0;
 }

+static int udp_init_sock(struct sock *sk)
+{
+	sk->sk_data_ready =3D inet_def_readable;
+	return 0;
+}
+
 /*
  *	Socket option code for UDP
  */
@@ -1439,6 +1445,7 @@ struct proto udp_prot =3D {
 	.connect	   =3D ip4_datagram_connect,
 	.disconnect	   =3D udp_disconnect,
 	.ioctl		   =3D udp_ioctl,
+	.init		   =3D udp_init_sock,
 	.destroy	   =3D udp_destroy_sock,
 	.setsockopt	   =3D udp_setsockopt,
 	.getsockopt	   =3D udp_getsockopt,
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index ee1cc3f..fa9ce73 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -856,6 +856,12 @@ int udpv6_destroy_sock(struct sock *sk)
 	return 0;
 }

+static int udpv6_init_sock(struct sock *sk)
+{
+	sk->sk_data_ready =3D inet_def_readable;
+	return 0;
+}
+
 /*
  *	Socket option code for UDP
  */
@@ -979,6 +985,7 @@ struct proto udpv6_prot =3D {
 	.connect	   =3D ip6_datagram_connect,
 	.disconnect	   =3D udp_disconnect,
 	.ioctl		   =3D udp_ioctl,
+	.init 		   =3D udpv6_init_sock,
 	.destroy	   =3D udpv6_destroy_sock,
 	.setsockopt	   =3D udpv6_setsockopt,
 	.getsockopt	   =3D udpv6_getsockopt,


From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH: 2.6.13-15-SMP 3/3] network: concurrently
	runsoftirqnetwork code on SMP
Date: Sun, 23 Sep 2007 14:07:44 -0400
Message-ID: <1190570864.4256.70.camel@localhost>
References: <004901c7fd9c$94370df0$d6ddfea9@JOHNYE1>
	 <1190551422.4256.36.camel@localhost>
	 <000501c7fdf8$c7f7c8d0$d6ddfea9@JOHNYE1>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-dFY2zmSMceC+tfQR7cAS"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	kaber@coreworks.de, iceburgue@gmail.com
To: john ye <johny@asimco.com.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.241]:64887 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754939AbXIWSHs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Sep 2007 14:07:48 -0400
Received: by an-out-0708.google.com with SMTP id d31so196344and
        for <netdev@vger.kernel.org>; Sun, 23 Sep 2007 11:07:48 -0700 (PDT)
In-Reply-To: <000501c7fdf8$c7f7c8d0$d6ddfea9@JOHNYE1>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-dFY2zmSMceC+tfQR7cAS
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

John,
It will NEVER be an acceptable solution as long as you have re-ordering.
I will look at it - but i have to run out for now. In the meantime,
I have indented it for you to be in proper kernel format so others can
also look it. Attached.

cheers,
jamal


--=-dFY2zmSMceC+tfQR7cAS
Content-Disposition: attachment; filename=bs.c
Content-Type: text/x-csrc; name=bs.c; charset=us-ascii
Content-Transfer-Encoding: 7bit

/*
* BOTTOM_SOFTIRQ_NET
* An implementation of bottom softirq concurrent execution on SMP
* This is implemented by splitting current net softirq into top half
* and bottom half, dispatch the bottom half to each cpu's workqueue.
* Hopefully, it can raise the throughput of NIC when running iptalbes
* with heavy softirq load on SMP machine.
*               
*  Version:    $Id: bs_smp.c, v 2.6.13-15 for kernel 2.6.13-15-smp
*   
*  Authors:    John Ye & QianYu Ye, 2007.08.27
*/

#include <linux/module.h>
#include <linux/fs.h>
#include <linux/pagemap.h>
#include <linux/highmem.h>
#include <linux/init.h>
#include <linux/string.h>
#include <linux/smp_lock.h>
#include <linux/backing-dev.h>

#include <asm/uaccess.h>

#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/types.h>
#include <linux/errno.h>
#include <linux/slab.h>
#include <linux/romfs_fs.h>
#include <linux/fs.h>
#include <linux/init.h>
#include <linux/pagemap.h>
#include <linux/smp_lock.h>
#include <linux/buffer_head.h>
#include <linux/vfs.h>
#include <linux/delay.h>
#include <linux/bio.h>
#include <linux/aio.h>
#include <asm/uaccess.h>

//for debug_syscalls
#include <linux/kernel.h>
#include <linux/sched.h>
#include <linux/mm.h>
#include <linux/smp.h>
#include <linux/ptrace.h>
#include <linux/user.h>
#include <linux/security.h>
#include <linux/list.h>

#include <asm/pgtable.h>
#include <asm/system.h>
#include <asm/processor.h>
#include <asm/i387.h>
#include <asm/debugreg.h>
#include <asm/ldt.h>
#include <asm/desc.h>

#include <linux/swap.h>
//#include <linux/interrupt.h>
#include <asm/i387.h>
#include <asm/debugreg.h>
#include <asm/ldt.h>
#include <asm/desc.h>

#include <linux/swap.h>

#include <linux/init.h>
#include <linux/sched.h>
#include <linux/smp_lock.h>
#include <linux/input.h>
#include <linux/module.h>
#include <linux/random.h>
#include <linux/major.h>
#include <linux/pm.h>
#include <linux/proc_fs.h>
#include <linux/kmod.h>
#include <linux/interrupt.h>
#include <linux/poll.h>
#include <linux/device.h>
#include <linux/devfs_fs_kernel.h>
#include <linux/interrupt.h>
#include <linux/workqueue.h>
#include <linux/skbuff.h>

#include <linux/config.h>
#include <linux/mm.h>
#include <linux/module.h>
#include <linux/sysctl.h>
#include <net/tcp.h>
#include <net/inet_common.h>
#include <linux/ipsec.h>
#include <asm/unaligned.h>

#include <asm/system.h>
#include <linux/module.h>
#include <linux/types.h>
#include <linux/kernel.h>
#include <linux/string.h>
#include <linux/errno.h>
#include <linux/config.h>

#include <linux/net.h>
#include <linux/socket.h>
#include <linux/sockios.h>
#include <linux/in.h>
#include <linux/inet.h>
#include <linux/netdevice.h>
#include <linux/etherdevice.h>

#include <net/snmp.h>
#include <net/ip.h>
#include <net/protocol.h>
#include <net/route.h>
#include <linux/skbuff.h>
#include <net/sock.h>
#include <net/arp.h>
#include <net/icmp.h>
#include <net/raw.h>
#include <net/checksum.h>
#include <linux/netfilter_ipv4.h>
#include <net/xfrm.h>
#include <linux/mroute.h>
#include <linux/netlink.h>
#include <net/route.h>"
#include <linux/inetdevice.h>

static spinlock_t *p_ptype_lock;
static struct list_head *p_ptype_base;	/* 16 way hashed list */

int (*Pip_options_rcv_srr) (struct sk_buff * skb);
int (*Pnf_rcv_postxfrm_nonlocal) (struct sk_buff * skb);
struct ip_rt_acct *ip_rt_acct;
struct ipv4_devconf *Pipv4_devconf;

#define ipv4_devconf (*Pipv4_devconf)
//#define ip_rt_acct Pip_rt_acct
#define ip_options_rcv_srr Pip_options_rcv_srr
#define nf_rcv_postxfrm_nonlocal Pnf_rcv_postxfrm_nonlocal
//extern int nf_rcv_postxfrm_local(struct sk_buff *skb);
//extern int ip_options_rcv_srr(struct sk_buff *skb);
static struct workqueue_struct **Pkeventd_wq;
#define keventd_wq (*Pkeventd_wq)

#define INSERT_CODE_HERE

static inline int ip_rcv_finish(struct sk_buff *skb)
{
	struct net_device *dev = skb->dev;
	struct iphdr *iph = skb->nh.iph;
	int err;

/*
* Initialise the virtual path cache for the packet. It describes
* how the packet travels inside Linux networking.
*/
	if (skb->dst == NULL) {
		if ((err =
		     ip_route_input(skb, iph->daddr, iph->saddr, iph->tos,
				    dev))) {
			if (err == -EHOSTUNREACH)
				IP_INC_STATS_BH(IPSTATS_MIB_INADDRERRORS);
			goto drop;
		}
	}

	if (nf_xfrm_nonlocal_done(skb))
		return nf_rcv_postxfrm_nonlocal(skb);

#ifdef CONFIG_NET_CLS_ROUTE
	if (skb->dst->tclassid) {
		struct ip_rt_acct *st = ip_rt_acct + 256 * smp_processor_id();
		u32 idx = skb->dst->tclassid;
		st[idx & 0xFF].o_packets++;
		st[idx & 0xFF].o_bytes += skb->len;
		st[(idx >> 16) & 0xFF].i_packets++;
		st[(idx >> 16) & 0xFF].i_bytes += skb->len;
	}
#endif

	if (iph->ihl > 5) {
		struct ip_options *opt;

/* It looks as overkill, because not all
   IP options require packet mangling.
   But it is the easiest for now, especially taking
   into account that combination of IP options
   and running sniffer is extremely rare condition.
                                      --ANK (980813)
*/

		if (skb_cow(skb, skb_headroom(skb))) {
			IP_INC_STATS_BH(IPSTATS_MIB_INDISCARDS);
			goto drop;
		}
		iph = skb->nh.iph;

		if (ip_options_compile(NULL, skb))
			goto inhdr_error;

		opt = &(IPCB(skb)->opt);
		if (opt->srr) {
			struct in_device *in_dev = in_dev_get(dev);
			if (in_dev) {
				if (!IN_DEV_SOURCE_ROUTE(in_dev)) {
					if (IN_DEV_LOG_MARTIANS(in_dev)
					    && net_ratelimit())
						printk(KERN_INFO
						       "source route option %u.%u.%u.%u -> %u.%u.%u.%u\n",
						       NIPQUAD(iph->saddr),
						       NIPQUAD(iph->daddr));
					in_dev_put(in_dev);
					goto drop;
				}
				in_dev_put(in_dev);
			}
			if (ip_options_rcv_srr(skb))
				goto drop;
		}
	}

	return dst_input(skb);

      inhdr_error:
	IP_INC_STATS_BH(IPSTATS_MIB_INHDRERRORS);
      drop:
	kfree_skb(skb);
	return NET_RX_DROP;
}

#define CONFIG_BOTTOM_SOFTIRQ_SMP
#define CONFIG_BOTTOM_SOFTIRQ_SMP_SYSCTL

#ifdef CONFIG_BOTTOM_SOFTIRQ_SMP

#ifdef COMMENT____________
/*
[PATCH: 2.6.13-15-SMP 1/2] network: concurrently run softirq network 
code on SMP Bottom Softirq Implementation. John Ye, 2007.08.27

Why this patch:
Make kernel be able to concurrently execute softirq's net code on SMP system.
Take full advantages of SMP to handle more packets and greatly raises 
NIC throughput.
The current kernel's net packet processing logic is:
1) The CPU which handles a hardirq must be executing its related softirq.
2) One softirq instance(irqs handled by 1 CPU) can't be executed on more 
than 2 CPUs at the same time.
The limitation make kernel network be hard to take the advantages of SMP.

How this patch:
It splits the current softirq code into 2 parts: the cpu-sensitive top half,
and the cpu-insensitive bottom half, then make bottom half(calld BS) be
executed on SMP concurrently.
The two parts are not equal in terms of size and load. Top part has 
constant code size(mainly, in net/core/dev.c and NIC drivers), while 
bottom part involves netfilter(iptables) whose load varies very much. 
An iptalbes with 1000 rules to match will make the bottom part's load 
be very high. So, if the bottom part softirq can be randomly distributed 
to processors and run concurrently on them, the network will gain much 
more packet handling capacity, network throughput will be be increased
remarkably.

Where useful:
It's useful on SMP machines that meet the following 2 conditions:
1) have high kernel network load, for example, running iptables with 
thousands of rules, etc).
2) have more CPUs than active NICs, e.g. a 4 CPUs machine with 2 NICs).
On these system, with the increase of softirq load, some CPUs will be idle
while others(number is equal to # of NIC) keeps busy.
IRQBALANCE will help, but it only shifts IRQ among CPUS, makes no 
softirq concurrency.
Balancing the load of each cpus will not remarkably increase network 
speed.

Where NOT useful:
If the bottom half of softirq is too small(without running iptables), or 
the network is too idle, BS patch will not be seen to have visible effect. 
But It has no negative affect either.
User can turn on/off BS functionality by /proc/sys/net/bs_enable switch.

How to test:
On a linux box, run iptables, add 2000 rules to table filter & table nat to 
simulate huge softirq load. Then, open 20 ftp sessions to download big file. 
On another machine(who use this test machine as gateway), open 20 more ftp 
download sessions. Compare the speed, without BS enabled, and with BS 
enabled.
cat /proc/sys/net/bs_enable. this is a switch to turn on/off BS
cat /proc/sys/net/bs_status. this shows the usage of each CPUs
Test shown that when bottom softirq load is high, the network throughput 
can be nearly doubled on 2 CPUs machine. hopefully it may be quadrupled on 
a 4 cpus linux box.

Bugs:
It will NOT allow hotplug CPU.
It only allows incremental CPUs ids, starting from 0 to num_online_cpus().
for example, 0,1,2,3 is OK. 0,1,8,9 is KO.

Some considerations in the future:
1) With BS patch, the irq balance code on arch/i386/kernel/io_apic.c 
seems no need any more, at least not for network irq.
2) Softirq load will become very small. It only run the top half of 
old softirq, which is much less expensive than bottom half
---the netfilter program.
To let top softirq process more packets, can these 3 network parameters 
be given a larger value?
   extern int netdev_max_backlog = 1000;
   extern int netdev_budget = 300;
   extern int weight_p = 64;
3) Now, BS are running on built-in keventd thread, we can create new 
workqueues to let it run on?

Signed-off-by: John Ye (Seeker) <[email]johny@webizmail.com[/email]>
*/
#endif

#define BS_USE_PERCPU_DATA
struct cpu_stat {
	unsigned long irqs;	//total irqs
	unsigned long dids;	//I did,
	unsigned long others;
	unsigned long works;
};
#define BS_CPU_STAT_DEFINED

static int nr_cpus = 0;

#ifdef BS_USE_PERCPU_DATA
static DEFINE_PER_CPU(struct sk_buff_head, bs_cpu_queues);	// cacheline_aligned_in_smp;
static DEFINE_PER_CPU(struct work_struct, bs_works);
//static DEFINE_PER_CPU(struct cpu_stat, bs_cpu_status);
struct cpu_stat bs_cpu_status[NR_CPUS] = { {0,}, {0,}, };
#else
#define NR_CPUS  8
static struct sk_buff_head bs_cpu_queues[NR_CPUS];
static struct work_struct bs_works[NR_CPUS];
static struct cpu_stat bs_cpu_status[NR_CPUS];
#endif

int bs_enable = 1;
static int ip_rcv1(struct sk_buff *skb, struct net_device *dev)
{
	return NF_HOOK_COND(PF_INET, NF_IP_PRE_ROUTING, skb, dev, NULL,
			    ip_rcv_finish, nf_hook_input_cond(skb));
}

static void bs_func(void *data)
{
	int flags, num, cpu;
	struct sk_buff *skb;
	struct work_struct *bs_works;
	struct sk_buff_head *q;
	cpu = smp_processor_id();

#ifdef BS_USE_PERCPU_DATA
	bs_works = &per_cpu(bs_works, cpu);
	q = &per_cpu(bs_cpu_queues, cpu);
#else
	bs_works = &bs_works[cpu];
	q = &bs_cpu_queues[cpu];
#endif

	local_bh_disable();
      restart:
	num = 0;
	while (1) {
		spin_lock_irqsave(&q->lock, flags);
		skb = __skb_dequeue(q);
		spin_unlock_irqrestore(&q->lock, flags);
		if (!skb)
			break;
		num++;
//local_bh_disable();
		ip_rcv1(skb, skb->dev);
//__local_bh_enable(); //sub_preempt_count(SOFTIRQ_OFFSET - 1);
	}

	bs_cpu_status[cpu].others += num;
//if(num > 2) printk("%d %d\n", num, cpu);
	if (num > 0) {
		goto restart;
	}

	__local_bh_enable();	//sub_preempt_count(SOFTIRQ_OFFSET - 1);
	bs_works->func = 0;

	return;
}

/* COPY_IN_START_FROM kernel/workqueue.c */
struct cpu_workqueue_struct {

	spinlock_t lock;

	long remove_sequence;	/* Least-recently added (next to run) */
	long insert_sequence;	/* Next to add */

	struct list_head worklist;
	wait_queue_head_t more_work;
	wait_queue_head_t work_done;

	struct workqueue_struct *wq;
	task_t *thread;

	int run_depth;		/* Detect run_workqueue() recursion depth */
} ____cacheline_aligned;

struct workqueue_struct {
	struct cpu_workqueue_struct cpu_wq[NR_CPUS];
	const char *name;
	struct list_head list;	/* Empty if single thread */
};
/* COPY_IN_END_FROM kernel/worqueue.c */

extern struct workqueue_struct *keventd_wq;

/* Preempt must be disabled. */
static void __queue_work(struct cpu_workqueue_struct *cwq,
			 struct work_struct *work)
{
	unsigned long flags;

	spin_lock_irqsave(&cwq->lock, flags);
	work->wq_data = cwq;
	list_add_tail(&work->entry, &cwq->worklist);
	cwq->insert_sequence++;
	wake_up(&cwq->more_work);
	spin_unlock_irqrestore(&cwq->lock, flags);
}

#endif //CONFIG_BOTTOM_SOFTIRQ_SMP

/*
* Main IP Receive routine.
*/
/* hard irq are in CPU1, why this get called from CPU0?, __do_IRQ() did so?
*
*/
int REP_ip_rcv(struct sk_buff *skb, struct net_device *dev,
	       struct packet_type *pt)
{
	struct iphdr *iph;

/* When the interface is in promisc. mode, drop all the crap
* that it receives, do not try to analyse it.
*/
	if (skb->pkt_type == PACKET_OTHERHOST)
		goto drop;

	IP_INC_STATS_BH(IPSTATS_MIB_INRECEIVES);

	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL) {
		IP_INC_STATS_BH(IPSTATS_MIB_INDISCARDS);
		goto out;
	}

	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
		goto inhdr_error;

	iph = skb->nh.iph;

/*
* RFC1122: 3.1.2.2 MUST silently discard any IP frame that fails the checksum.
*
* Is the datagram acceptable?
*
* 1. Length at least the size of an ip header
* 2. Version of 4
* 3. Checksums correctly. [Speed optimisation for later, skip loopback checksums]
* 4. Doesn't have a bogus length
*/

	if (iph->ihl < 5 || iph->version != 4)
		goto inhdr_error;

	if (!pskb_may_pull(skb, iph->ihl * 4))
		goto inhdr_error;

	iph = skb->nh.iph;

	if (ip_fast_csum((u8 *) iph, iph->ihl) != 0)
		goto inhdr_error;

	{
		__u32 len = ntohs(iph->tot_len);
		if (skb->len < len || len < (iph->ihl << 2))
			goto inhdr_error;

/* Our transport medium may have padded the buffer out. Now we know it
* is IP we can trim to the true length of the frame.
* Note this now means skb->len holds ntohs(iph->tot_len).
*/
		if (pskb_trim_rcsum(skb, len)) {
			IP_INC_STATS_BH(IPSTATS_MIB_INDISCARDS);
			goto drop;
		}
	}

#ifdef CONFIG_BOTTOM_SOFTIRQ_SMP

	if (!nr_cpus)
		nr_cpus = num_online_cpus();

	if (bs_enable && nr_cpus > 1 && iph->protocol != IPPROTO_ICMP) {
		//if(bs_enable && iph->protocol == IPPROTO_ICMP) { //test on icmp first
		unsigned int flags, cur, cpu;
		struct work_struct *bs_works;
		struct sk_buff_head *q;

		cur = smp_processor_id();

		bs_cpu_status[cur].irqs++;

		if (!nr_cpus) {
			nr_cpus = num_online_cpus();
		}
//random distribute
		cpu = (bs_cpu_status[cur].irqs % nr_cpus);
		if (cpu == cur) {
			bs_cpu_status[cpu].dids++;
			return ip_rcv1(skb, dev);
		}
#ifdef BS_USE_PERCPU_DATA
		q = &per_cpu(bs_cpu_queues, cpu);
#else
		q = &bs_cpu_queues[cpu];
#endif

		if (!q->next) {	// || skb_queue_len(q) == 0 ) {
			skb_queue_head_init(q);
		}

#ifdef BS_USE_PERCPU_DATA
		bs_works = &per_cpu(bs_works, cpu);
#else
		bs_works = &bs_works[cpu];
#endif
		spin_lock_irqsave(&q->lock, flags);
		__skb_queue_tail(q, skb);
		spin_unlock_irqrestore(&q->lock, flags);

		if (!bs_works->func) {
			INIT_WORK(bs_works, bs_func, q);
			bs_cpu_status[cpu].works++;
			preempt_disable();
			__queue_work(keventd_wq->cpu_wq + cpu, bs_works);
			preempt_enable();
		}
	} else {
		int cpu = smp_processor_id();
		bs_cpu_status[cpu].irqs++;
		bs_cpu_status[cpu].dids++;
		return ip_rcv1(skb, dev);
	}
	return 0;
#else
	return NF_HOOK_COND(PF_INET, NF_IP_PRE_ROUTING, skb, dev, NULL,
			    ip_rcv_finish, nf_hook_input_cond(skb));
#endif //CONFIG_BOTTOM_SOFTIRQ_SMP

      inhdr_error:
	IP_INC_STATS_BH(IPSTATS_MIB_INHDRERRORS);
      drop:
	kfree_skb(skb);
      out:
	return NET_RX_DROP;
}

//for standard patch, those lines should be moved into ../../net/sysctl_net.c

/* COPY_OUT_START_TO net/sysctl_net.c */
#ifdef CONFIG_BOTTOM_SOFTIRQ_SMP_SYSCTL
#if !defined(BS_CPU_STAT_DEFINED)
struct cpu_stat {
	unsigned long irqs;	//total irqs
	unsigned long dids;	//I did,
	unsigned long others;
	unsigned long works;
};
#endif
extern struct cpu_stat bs_cpu_status[NR_CPUS];

extern int bs_enable;
/* COPY_OUT_END_TO net/sysctl_net.c */

static ctl_table bs_ctl_table[] = {

/* COPY_OUT_START_TO net/sysctl_net.c */
	{
	 .ctl_name = 99,
	 .procname = "bs_status",
	 .data = &bs_cpu_status,
	 .maxlen = sizeof(bs_cpu_status),
	 .mode = 0644,
	 .proc_handler = &proc_dointvec,
	 }
	,

	{
	 .ctl_name = 99,
	 .procname = "bs_enable",
	 .data = &bs_enable,
	 .maxlen = sizeof(int),
	 .mode = 0644,
	 .proc_handler = &proc_dointvec,
	 },
/* COPY_OUT_END_TO net/net_sysctl.c */

	{0,},
};

static ctl_table bs_sysctl_root[] = {
	{
	 .ctl_name = CTL_NET,
	 .procname = "net",
	 .mode = 0555,
	 .child = bs_ctl_table,
	 },
	{0,},
};

struct ctl_table_header *bs_sysctl_hdr;
register_bs_sysctl(void)
{
	bs_sysctl_hdr = register_sysctl_table(bs_sysctl_root, 0);
	return 0;
}

unregister_bs_sysctl(void)
{
	unregister_sysctl_table(bs_sysctl_hdr);
}

#endif //CONFIG_BOTTOM_SOFTIRQ_SMP_SYSCTL

#if 1
seeker_init()
{
	int i;
	if (nr_cpus == 0)
		nr_cpus = num_online_cpus();
	register_bs_sysctl();
}

seeker_exit()
{
	unregister_bs_sysctl();
	bs_enable = 0;
	msleep(1000);
	flush_scheduled_work();
	msleep(1000);
	printk("......exit...........\n");
}
#endif

/*--------------------------------------------------------------------------
*/
struct packet_type *dev_find_pack(int type)
{
	struct list_head *head;
	struct packet_type *pt1;

	spin_lock_bh(p_ptype_lock);

	head = &p_ptype_base[type & 15];

	list_for_each_entry(pt1, head, list) {
		printk("pt1: %x\n", pt1->type);
		if (pt1->type == htons(type)) {
			printk("FOUND\n");
			goto out;
		}
	}

	pt1 = 0;
	printk("dev_remove_pack: %p not found. type %x %x %x\n", pt1, type,
	       ETH_P_IP, htons(ETH_P_IP));
      out:
	spin_unlock_bh(p_ptype_lock);
	return pt1;
}

static char system_map[128] = "/boot/System.map-";
static unsigned long sysmap_size;
static char *sysmap_buf;

unsigned long sysmap_name2addr(char *name)
{
	char *cp, *dp;
	unsigned long addr;
	int len, n;

	if (!sysmap_buf)
		return 0;
	if (!name || !name[0])
		return 0;
	n = strlen(name);
	for (cp = sysmap_buf;;) {
		cp = strstr(cp, name);
		if (!cp)
			return 0;

		for (dp = cp; *dp && *dp != '\n' && *dp != ' ' && *dp != '\t';
		     dp++) ;

		len = dp - cp;
		if (len < n)
			goto cont;
		if (cp > sysmap_buf && cp[-1] != ' ' && cp[-1] != '\t') {
			goto cont;
		}
		if (len > n) {
			goto cont;
		}
		break;
	      cont:
		if (*dp == 0)
			break;
		cp += (len + 1);
	}

	cp -= 11;
	if (cp > sysmap_buf && cp[-1] != '\n') {
		printk("_ERROR_ in name2addr cp = %p base %p\n", cp,
		       sysmap_buf);
		return 0;
	}
	sscanf(cp, "%x", &addr);
	printk("%s -> %p\n", name, addr);

	return addr;
}

char *kas_init()
{
	struct file *fp;
	int i;
	long addr;
	struct kstat st;
	mm_segment_t old_fs;

	//printk("system #%s#%s#%s#%s\n", system_utsname.sysname, system_utsname.nodename, system_utsname.release, system_utsname.version);
	strcat(system_map, system_utsname.release);
	printk("System.map is %s\n", system_map);

	old_fs = get_fs();
	set_fs(get_ds());	//systemp_map is __user variable
	i = vfs_stat(system_map, &st);
	set_fs(old_fs);

	//sysmap_size = 1024*1024; //error
	sysmap_size = st.size + 32;
	fp = filp_open(system_map, O_RDONLY, FMODE_READ);

	if (!fp)
		return 1;
	sysmap_buf = vmalloc(sysmap_size);
	if (!sysmap_buf)
		return 2;
	i = kernel_read(fp, 0, sysmap_buf, sysmap_size);
	if (i <= 0) {
		filp_close(fp, 0);
		vfree(sysmap_buf);
		sysmap_buf = 0;
		return 3;
	}
	sysmap_size = i;
	*(int *)&sysmap_buf[i] = 0;
	filp_close(fp, 0);
	//sysmap_symbol2addr = sysmap_name2addr;

	p_ptype_lock = sysmap_name2addr("ptype_lock");
	p_ptype_base = sysmap_name2addr("ptype_base");
	/*
	   int (*Pip_options_rcv_srr)(struct sk_buff *skb);
	   int (*Pnf_rcv_postxfrm_nonlocal)(struct sk_buff *skb);
	   struct ip_rt_acct *ip_rt_acct;
	   struct ipv4_devconf *Pipv4_devconf;
	 */
	Pkeventd_wq = sysmap_name2addr("keventd_wq");
	//keventd_wq = *(long *)&keventd_wq;

	Pip_options_rcv_srr = sysmap_name2addr("ip_options_rcv_srr");
	Pnf_rcv_postxfrm_nonlocal =
	    sysmap_name2addr("nf_rcv_postxfrm_nonlocal");
	ip_rt_acct = sysmap_name2addr("ip_rt_acct");
	Pipv4_devconf = sysmap_name2addr("ipv4_devconf");
	printk("lock = %p base = %p\n", p_ptype_lock, p_ptype_base);
	vfree(sysmap_buf);

}

struct packet_type *ip_handler;
static int __init init()
{
	struct packet_type *pt;
	kas_init();
	pt = dev_find_pack(ETH_P_IP);
	if (!pt)
		return -1;
//printk("pt %p func ip_rcv %p should be %p\n", pt, pt->func, ip_rcv);

	lock_kernel();
	if (pt->func == ip_rcv) {
		pt->func = REP_ip_rcv;
	} else
		printk("no...\n");

	ip_handler = pt;
	unlock_kernel();
	seeker_init();
	return 0;
}

static void __exit exit(void)
{
	seeker_exit();
	lock_kernel();
	if (ip_handler->func == REP_ip_rcv)
		ip_handler->func = ip_rcv;
	else
		printk("error...\n");
	unlock_kernel();
}

module_init(init)
    module_exit(exit)
    MODULE_LICENSE("GPL");

--=-dFY2zmSMceC+tfQR7cAS--


From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: conntrack timers usage
Date: Mon, 13 Oct 2008 01:49:25 +0300
Message-ID: <200810130149.25635.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, netfilter@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:41787 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752317AbYJLWvZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Oct 2008 18:51:25 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The story with excessive timers usage continue.

Here is my results from /proc/timer_stats for 30 seconds (150Mbps traffic)

This is "non-netfilter" related events

Router-Dora ~ # cat /proc/timer_stats |grep -v '__nf'
Timer Stats Version: v0.2
Sample period: 30.002 s
Overflow: 45261 entries
  300,  3308 insmod           ipmi_init_msghandler (ipmi_timeout)
 1032,     1 swapper          neigh_table_init_no_netlink 
(neigh_periodic_timer)
    3,     0 swapper          sk_reset_timer (tcp_delack_timer)
  298,  1342 vconfig          garp_join_timer_arm (garp_join_timer)
 1621,     0 swapper          qdisc_watchdog_schedule (qdisc_watchdog)
  169,     6 ksoftirqd/1      qdisc_watchdog_schedule (qdisc_watchdog)
    3,     6 ksoftirqd/1      neigh_add_timer (neigh_timer_handler)
 1417,     0 swapper          qdisc_watchdog_schedule (qdisc_watchdog)
    2,     6 ksoftirqd/1      neigh_add_timer (neigh_timer_handler)
  294,  1352 vconfig          garp_join_timer_arm (garp_join_timer)
   15,     0 swapper          e1000_intr (e1000_watchdog)
    3,     1 swapper          enqueue_task_rt (sched_rt_period_timer)
   60,     0 swapper          clocksource_register (clocksource_watchdog)
    2,  5003 sshd             sk_reset_timer (tcp_write_timer)
  30D,     1 swapper          schedule_delayed_work_on (delayed_work_timer_fn)
   30,  1128 insmod           queue_delayed_work (delayed_work_timer_fn)
  30D,     1 swapper          schedule_delayed_work_on (delayed_work_timer_fn)
    1,     0 swapper          neigh_add_timer (neigh_timer_handler)
    1,     0 swapper          neigh_add_timer (neigh_timer_handler)
6318 total events, 210.429 events/sec

And here is netfilter usage, looks like ....
I did also sysctl -w net.netfilter.nf_conntrack_acct=0

   1,     0 swapper          __nf_ct_refresh_acct (death_by_timeout)
    1,     0 swapper          __nf_ct_refresh_acct (death_by_timeout)
    1,     0 swapper          __nf_ct_refresh_acct (death_by_timeout)
    1,     0 swapper          __nf_ct_refresh_acct (death_by_timeout)
    1,     0 swapper          __nf_ct_refresh_acct (death_by_timeout)
    1,     0 swapper          __nf_conntrack_confirm (death_by_timeout)
    1,     0 swapper          __nf_conntrack_confirm (death_by_timeout)
    1,     0 swapper          __nf_conntrack_confirm (death_by_timeout)
    1,     0 swapper          __nf_conntrack_confirm (death_by_timeout)
    1,     0 swapper          __nf_conntrack_confirm (death_by_timeout)
    1,     0 swapper          __nf_conntrack_confirm (death_by_timeout)
    1,     0 swapper          __nf_conntrack_confirm (death_by_timeout)
    1,     0 swapper          __nf_conntrack_confirm (death_by_timeout)
....

Router-Dora ~ # cat /proc/timer_stats |grep '__nf'|wc -l
1005

Is it important to do so much calls to timers in conntrack?
Precision on it is not more than 1 second.


From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] sctp: Add process name and pid to deprecation warnings
Date: Thu, 2 Jan 2014 19:52:30 +0000
Message-ID: <1388692350.9947.37.camel@bwh-desktop.uk.level5networks.com>
References: <1388685267-18319-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-sctp@vger.kernel.org>, Vlad Yasevich <vyasevich@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:30257 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751172AbaABTwe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 14:52:34 -0500
In-Reply-To: <1388685267-18319-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-01-02 at 12:54 -0500, Neil Horman wrote:
> Recently I updated the sctp socket option deprecation warnings to be both a bit
> more clear and ratelimited to prevent user processes from spamming the log file.
> Ben Hutchings suggested that I add the process name and pid to these warnings so
> that users can tell who is responsible for using the deprecated apis.  This
> patch accomplishes that.
[...]

I grepped for existing deprecation warnings that log the command and/or
PID.  The warnings are not consistent, but where the include both comand
and PID it's generally in the format "%s (%d)", comm, pid.  So please
could you follow that format?

block/scsi_ioctl.c:                     printk(KERN_WARNING "program %s is using a deprecated SCSI ioctl, please convert it to SG_IO\n", current->comm);

drivers/net/wireless/hostap/hostap_ioctl.c:     printk(KERN_DEBUG "%s: process %d (%s) used deprecated iwpriv monitor "
drivers/net/wireless/hostap/hostap_ioctl.c-            "- update software to use iwconfig mode monitor\n",
drivers/net/wireless/hostap/hostap_ioctl.c-            dev->name, task_pid_nr(current), current->comm);

drivers/scsi/scsi_ioctl.c:              printk(KERN_WARNING "program %s is using a deprecated SCSI "
drivers/scsi/scsi_ioctl.c-                     "ioctl, please convert it to SG_IO\n", current->comm);

drivers/tty/mxser.c:            printk_ratelimited(KERN_WARNING "mxser: '%s' uses deprecated ioctl "
drivers/tty/mxser.c-                                    "%x (GET_MAJOR), fix your userspace\n",
drivers/tty/mxser.c-                                    current->comm, cmd);

drivers/tty/serial/serial_core.c-                               printk(KERN_NOTICE
drivers/tty/serial/serial_core.c-                                      "%s sets custom speed on %s. This "
drivers/tty/serial/serial_core.c:                                      "is deprecated.\n", current->comm,
drivers/tty/serial/serial_core.c-                                      tty_name(port->tty, buf));

fs/hugetlbfs/inode.c-                   printk_once(KERN_WARNING
fs/hugetlbfs/inode.c:                           "%s (%d): Using mlock ulimits for SHM_HUGETLB is deprecated\n",
fs/hugetlbfs/inode.c-                           current->comm, current->pid);

fs/proc/base.c: pr_warn_once("%s (%d): /proc/%d/oom_adj is deprecated, please use /proc/%d/oom_score_adj instead.\n",
fs/proc/base.c-           current->comm, task_pid_nr(current), task_pid_nr(task),
fs/proc/base.c-           task_pid_nr(task));

kernel/capability.c:            printk(KERN_INFO "warning: `%s' uses deprecated v2"
kernel/capability.c-                   " capabilities in a way that may be insecure.\n",
kernel/capability.c-                   get_task_comm(name, current));

kernel/cgroup.c:                pr_warning("cgroup: option changes via remount are deprecated (pid=%d comm=%s)\n",
kernel/cgroup.c-                           task_tgid_nr(current), current->comm);

kernel/printk/printk.c-                 pr_warn_once("%s (%d): Attempt to access syslog with "
kernel/printk/printk.c-                              "CAP_SYS_ADMIN but no CAP_SYSLOG "
kernel/printk/printk.c:                              "(deprecated).\n",
kernel/printk/printk.c-                          current->comm, task_pid_nr(current));

kernel/sysctl_binary.c-         printk(KERN_INFO
kernel/sysctl_binary.c:                 "warning: process `%s' used the deprecated sysctl "
kernel/sysctl_binary.c-                 "system call with ", current->comm);

net/ipv6/ndisc.c:               pr_warn("process `%s' is using deprecated sysctl (%s) net.ipv6.neigh.%s.%s - use net.ipv6.neigh.%s.%s_ms instead\n",
net/ipv6/ndisc.c-                       warncomm, func,
net/ipv6/ndisc.c-                       dev_name, ctl->procname,

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

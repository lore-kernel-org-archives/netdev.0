From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] [RFC] proc connector: add namespace events
Date: Tue, 13 Sep 2016 00:39:44 +0300
Message-ID: <772621473716384@web6g.yandex.ru>
References: <1473349086-31260-1-git-send-email-alban@kinvolk.io>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Tejun Heo <tj@kernel.org>, Aditya Kali <adityakali@google.com>,
        Serge Hallyn <serge.hallyn@canonical.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Iago Lopez Galeiras <iago@kinvolk.io>
To: Alban Crequy <alban.crequy@gmail.com>,
        Alban Crequy <alban@kinvolk.io>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473349086-31260-1-git-send-email-alban@kinvolk.io>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi everyone

08.09.2016, 18:39, "Alban Crequy" <alban.crequy@gmail.com>:
> The act of a process creating or joining a namespace via clone(),
> unshare() or setns() is a useful signal for monitoring applications.

> + if (old_ns->mnt_ns != new_ns->mnt_ns)
> + proc_ns_connector(tsk, CLONE_NEWNS, PROC_NM_REASON_CLONE, old_mntns_inum, new_mntns_inum);
> +
> + if (old_ns->uts_ns != new_ns->uts_ns)
> + proc_ns_connector(tsk, CLONE_NEWUTS, PROC_NM_REASON_CLONE, old_ns->uts_ns->ns.inum, new_ns->uts_ns->ns.inum);
> +
> + if (old_ns->ipc_ns != new_ns->ipc_ns)
> + proc_ns_connector(tsk, CLONE_NEWIPC, PROC_NM_REASON_CLONE, old_ns->ipc_ns->ns.inum, new_ns->ipc_ns->ns.inum);
> +
> + if (old_ns->net_ns != new_ns->net_ns)
> + proc_ns_connector(tsk, CLONE_NEWNET, PROC_NM_REASON_CLONE, old_ns->net_ns->ns.inum, new_ns->net_ns->ns.inum);
> +
> + if (old_ns->cgroup_ns != new_ns->cgroup_ns)
> + proc_ns_connector(tsk, CLONE_NEWCGROUP, PROC_NM_REASON_CLONE, old_ns->cgroup_ns->ns.inum, new_ns->cgroup_ns->ns.inum);
> +
> + if (old_ns->pid_ns_for_children != new_ns->pid_ns_for_children)
> + proc_ns_connector(tsk, CLONE_NEWPID, PROC_NM_REASON_CLONE, old_ns->pid_ns_for_children->ns.inum, new_ns->pid_ns_for_children->ns.inum);
> + }
> +

Patch looks good to me from technical/connector point of view, but these even multiplication is a bit weird imho.

I'm not against it, but did you consider sending just 2 serialized ns structures via single message, and client
would check all ns bits himself?

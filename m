From: Alban Crequy <alban.crequy@gmail.com>
Subject: Re: [PATCH] [RFC] proc connector: add namespace events
Date: Tue, 13 Sep 2016 16:42:43 +0200
Message-ID: <CAMXgnP4tNg1U5v1R3XEDp9jFKhX4n70iqiDmt1Vp5vySpO9LhQ@mail.gmail.com>
References: <1473349086-31260-1-git-send-email-alban@kinvolk.io> <772621473716384@web6g.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alban Crequy <alban@kinvolk.io>, Tejun Heo <tj@kernel.org>,
        Aditya Kali <adityakali@google.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Iago Lopez Galeiras <iago@kinvolk.io>,
        "Serge E. Hallyn" <serge@hallyn.com>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <772621473716384@web6g.yandex.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12 September 2016 at 23:39, Evgeniy Polyakov <zbr@ioremap.net> wrote:
> Hi everyone
>
> 08.09.2016, 18:39, "Alban Crequy" <alban.crequy@gmail.com>:
>> The act of a process creating or joining a namespace via clone(),
>> unshare() or setns() is a useful signal for monitoring applications.
>
>> + if (old_ns->mnt_ns != new_ns->mnt_ns)
>> + proc_ns_connector(tsk, CLONE_NEWNS, PROC_NM_REASON_CLONE, old_mntns_inum, new_mntns_inum);
>> +
>> + if (old_ns->uts_ns != new_ns->uts_ns)
>> + proc_ns_connector(tsk, CLONE_NEWUTS, PROC_NM_REASON_CLONE, old_ns->uts_ns->ns.inum, new_ns->uts_ns->ns.inum);
>> +
>> + if (old_ns->ipc_ns != new_ns->ipc_ns)
>> + proc_ns_connector(tsk, CLONE_NEWIPC, PROC_NM_REASON_CLONE, old_ns->ipc_ns->ns.inum, new_ns->ipc_ns->ns.inum);
>> +
>> + if (old_ns->net_ns != new_ns->net_ns)
>> + proc_ns_connector(tsk, CLONE_NEWNET, PROC_NM_REASON_CLONE, old_ns->net_ns->ns.inum, new_ns->net_ns->ns.inum);
>> +
>> + if (old_ns->cgroup_ns != new_ns->cgroup_ns)
>> + proc_ns_connector(tsk, CLONE_NEWCGROUP, PROC_NM_REASON_CLONE, old_ns->cgroup_ns->ns.inum, new_ns->cgroup_ns->ns.inum);
>> +
>> + if (old_ns->pid_ns_for_children != new_ns->pid_ns_for_children)
>> + proc_ns_connector(tsk, CLONE_NEWPID, PROC_NM_REASON_CLONE, old_ns->pid_ns_for_children->ns.inum, new_ns->pid_ns_for_children->ns.inum);
>> + }
>> +
>
> Patch looks good to me from technical/connector point of view, but these even multiplication is a bit weird imho.
>
> I'm not against it, but did you consider sending just 2 serialized ns structures via single message, and client
> would check all ns bits himself?

I have not considered it, thanks for the suggestion. Should we offer
the guarantee to userspace that it will always be send in one single
message? If we want to give the information about the userns change
too, it will be a bit more complicated to write the patch because it
is not done in the same function.

Note that I will probably not have the chance to spend more time on
this patch soon because Iago will explore other methods with
eBPF+kprobes instead. eBPF+kprobes would not have the same API
stability though. I was curious to see if anyone would find the
namespace addition to proc connector interesting for other projects.

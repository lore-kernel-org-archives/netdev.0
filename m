From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Fw: [Bug 193911] New: net_prio.ifpriomap is not aware of the
 network namespace, and discloses all network interface
Date: Sun, 5 Feb 2017 23:05:36 -0800
Message-ID: <CAM_iQpVB_OvJy4Yz97MeOh9hNwm-mTG9aM1FWBpaaOmjroWvVw@mail.gmail.com>
References: <20170203155330.06edece4@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tejun Heo <tj@kernel.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        xgao01@email.wm.edu, "Eric W. Biederman" <ebiederm@xmission.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33262 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751164AbdBFHGD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 02:06:03 -0500
Received: by mail-wm0-f65.google.com with SMTP id v77so19882460wmv.0
        for <netdev@vger.kernel.org>; Sun, 05 Feb 2017 23:05:57 -0800 (PST)
In-Reply-To: <20170203155330.06edece4@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 3, 2017 at 3:53 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
>
>
> Begin forwarded message:
>
> Date: Fri, 03 Feb 2017 21:14:28 +0000
> From: bugzilla-daemon@bugzilla.kernel.org
> To: stephen@networkplumber.org
> Subject: [Bug 193911] New: net_prio.ifpriomap is not aware of the network namespace, and discloses all network interface
>
>
> https://bugzilla.kernel.org/show_bug.cgi?id=193911
>
>             Bug ID: 193911
>            Summary: net_prio.ifpriomap is not aware of the network
>                     namespace, and discloses all network interface
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 4.9
>           Hardware: All
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>           Assignee: stephen@networkplumber.org
>           Reporter: xgao01@email.wm.edu
>         Regression: No
>
> The pseudo file net_prio.ifpriomap (under /sys/fs/cgroup/net_prio) contains a
> map of the priorities assigned to traffic starting from processes in a cgroup
> and leaving the system on various interfaces. The data format is in the form of
> [ifname priority].
>
> We find that the kernel handler function hooked at net_prio.ifpriomap is not
> aware of the network namespace, and thus it discloses all network interfaces on
> the physical machine to the containerized applications.
>
> To be more specific, the read operation of net_prio.ifpriomap is handled by the
> function read_priomap. Tracing from this function, we can find it invokes
> for_each_netdev_rcu and set the first parameter as the address of init_net. It
> iterates all network devices of the host regardless of the network namespace.
> Thus, from the view of a container, it can read the names of all network
> devices of the host.

I think that is probably because cgroup files don't provide a net pointer
for the context, if so we probably need some API similar to
class_create_file_ns().

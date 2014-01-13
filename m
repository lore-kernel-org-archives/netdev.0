From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [PATCH v4 0/3] Send audit/procinfo/cgroup data in socket-level
 control message
Date: Mon, 13 Jan 2014 11:44:06 -0800
Message-ID: <52D44206.2000906@schaufler-ca.com>
References: <1377614400-27122-1-git-send-email-jkaluza@redhat.com> <1389600109-30739-1-git-send-email-jkaluza@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	eparis@redhat.com, rgb@redhat.com, tj@kernel.org,
	lizefan@huawei.com, containers@lists.linux-foundation.org,
	cgroups@vger.kernel.org, viro@zeniv.linux.org.uk
To: Jan Kaluza <jkaluza@redhat.com>, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1389600109-30739-1-git-send-email-jkaluza@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/13/2014 12:01 AM, Jan Kaluza wrote:
> Hi,
>
> this patchset against net-next (applies also to linux-next) adds 3 new types
> of "Socket"-level control message (SCM_AUDIT, SCM_PROCINFO and SCM_CGROUP).

How about the group list, while you're at it?

>
> Server-like processes in many cases need credentials and other
> metadata of the peer, to decide if the calling process is allowed to
> request a specific action, or the server just wants to log away this
> type of information for auditing tasks.
>
> The current practice to retrieve such process metadata is to look that
> information up in procfs with the $PID received over SCM_CREDENTIALS.
> This is sufficient for long-running tasks, but introduces a race which
> cannot be worked around for short-living processes; the calling
> process and all the information in /proc/$PID/ is gone before the
> receiver of the socket message can look it up.
>
> Changes introduced in this patchset can also increase performance
> of such server-like processes, because current way of opening and
> parsing /proc/$PID/* files is much more expensive than receiving these
> metadata using SCM.
>
> Changes in v4:
> - Rebased to work with the latest net-next tree
>
> Changes in v3:
> - Better description of patches (Thanks to Kay Sievers)
>
> Changes in v2:
> - use PATH_MAX instead of PAGE_SIZE in SCM_CGROUP patch
> - describe each patch individually
>
> Jan Kaluza (3):
>   Send loginuid and sessionid in SCM_AUDIT
>   Send comm and cmdline in SCM_PROCINFO
>   Send cgroup_path in SCM_CGROUP
>
>  include/linux/socket.h |  9 ++++++
>  include/net/af_unix.h  | 10 ++++++
>  include/net/scm.h      | 67 ++++++++++++++++++++++++++++++++++++++--
>  net/core/scm.c         | 83 ++++++++++++++++++++++++++++++++++++++++++++++++++
>  net/unix/af_unix.c     | 70 ++++++++++++++++++++++++++++++++++++++++++
>  5 files changed, 237 insertions(+), 2 deletions(-)
>

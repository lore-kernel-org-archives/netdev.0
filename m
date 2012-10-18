From: "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v7 00/10] IPC: checkpoint/restore in userspace enhancements
Date: Thu, 18 Oct 2012 12:41:11 +0200
Message-ID: <CAKgNAkhrLSTOm=zHRQPUV4WJYe8D3rhE0S3F2ATc5QRKzh4UpQ@mail.gmail.com>
References: <20121018101543.16036.12221.stgit@localhost.localdomain>
Reply-To: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org,
	will.deacon-5wv7dgnIgG8@public.gmane.org, dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, manfred-nhLOkwUX5cPe2c5cEj3t2g@public.gmane.org,
	hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org,
	kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org, paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
	sds-+05T5uksL2qpZYMLLGbcSA@public.gmane.org, devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org,
	cmetcalf-kv+TWInifGbQT0dZR+AlfA@public.gmane.org, linux-driver-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org,
	ron.mercer-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org,
	eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org,
	jitendra.kalsaria-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org,
	casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org, Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20121018101543.16036.12221.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Stanislaw,

This patch series is an API change. Could you please make sure that
all future revisions CC linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, as per
Documentation/SubmitChecklist.

Cheers,

Michael


On Thu, Oct 18, 2012 at 12:22 PM, Stanislav Kinsbursky
<skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> wrote:
> v7:
> 1) Added comments in places, when behiviour is not obvious.
> 2) Compilation fixed for compat layer
> 3) test updated to use existent header files (instead of hard-coding new
> defines in case of absence).
> 4) comment fixed in qlge driver
>
> v6:
> 1) rebased on 3.7-rc1
>
> v5:
> 1) Several define-dependent compile bugs fixed
> 2) IPC message copy test updated
> 3) A couple of minor fixes.
> 4) Qlogic driver update: rename of its internal SEM_SET define into SEM_INIT
> (compile error).
>
> v4:
> 1) If MSG_COPY flag is specified, then "mtype" is not a type, but message
> number to copy.
> 2) MSG_SET_COPY logic for sys_msgctl() was removed.
>
> v3:
> 1) Copy messages to user-space under spinlock was replaced by allocation of
> dummy message before queue lock and then copy of desired message to the dummy
> one instead of unlinking it from queue list.
> I.e. the message queue copy logic was changed: messages can be retrived one by
> one (instead of receiving of the whole list at once).
>
> This patch set is aimed to provide additional functionality for all IPC
> objects,
> which is required for migration of these objects by user-space
> checkpoint/restore utils (CRIU).
>
> The main problem here was impossibility to set up object id. This patch set
> solves the problem in two steps:
> 1) Makes it possible to create new object (shared memory, semaphores set or
> messages queue) with ID, equal to passed key.
> 2) Makes it possible to change existent object key.
>
> Another problem was to peek messages from queues without deleting them.
> This was achived by introducing of new MSG_COPY flag for sys_msgrcv(). If
> MSG_COPY flag is set, then msgtyp is interpreted as message number.
>
> The following series implements...
>
> ---
>
> Stanislav Kinsbursky (10):
>       ipc: remove forced assignment of selected message
>       ipc: "use key as id" functionality for resource get system call introduced
>       ipc: segment key change helper introduced
>       ipc: add new SHM_SET command for sys_shmctl() call
>       ipc: add new MSG_SET command for sys_msgctl() call
>       qlge driver: rename internal SEM_SET macro to SEM_INIT
>       ipc: add new SEM_SET command for sys_semctl() call
>       IPC: message queue receive cleanup
>       IPC: message queue copy feature introduced
>       test: IPC message queue copy feture test
>
>
>  drivers/net/ethernet/qlogic/qlge/qlge.h      |    4
>  drivers/net/ethernet/qlogic/qlge/qlge_main.c |   16 +-
>  include/linux/msg.h                          |    5 -
>  include/uapi/linux/ipc.h                     |    1
>  include/uapi/linux/msg.h                     |    2
>  include/uapi/linux/sem.h                     |    1
>  include/uapi/linux/shm.h                     |    1
>  ipc/compat.c                                 |   54 +++---
>  ipc/msg.c                                    |  117 ++++++++++---
>  ipc/msgutil.c                                |   38 ++++
>  ipc/sem.c                                    |   15 +-
>  ipc/shm.c                                    |   18 ++
>  ipc/util.c                                   |   67 +++++++-
>  ipc/util.h                                   |    6 +
>  security/selinux/hooks.c                     |    3
>  security/smack/smack_lsm.c                   |    3
>  tools/testing/selftests/ipc/Makefile         |   25 +++
>  tools/testing/selftests/ipc/msgque.c         |  231 ++++++++++++++++++++++++++
>  18 files changed, 526 insertions(+), 81 deletions(-)
>  create mode 100644 tools/testing/selftests/ipc/Makefile
>  create mode 100644 tools/testing/selftests/ipc/msgque.c
>



-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Author of "The Linux Programming Interface"; http://man7.org/tlpi/

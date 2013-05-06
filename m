From: Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 1/2] freezer: add unsafe versions of freezable helpers
Date: Mon, 6 May 2013 14:54:53 -0700
Message-ID: <CAMbhsRQP+NFwn8C9-mXUVCZNi_oE+TCK1L1NgdGUA_CTw0eiMA@mail.gmail.com>
References: <1367615050-3894-1-git-send-email-ccross@android.com>
	<20130506065605.6e5ed5e2@tlielax.poochiereds.net>
	<CAMbhsRQsFT2j_CuPL45J03itymcp3PNP8ckt3fAAo+hzavNrbw@mail.gmail.com>
	<20130506174336.447d0d75@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	Len Brown <len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Paul Walmsley <paul-DWxLp4Yu+b8AvxtiuMwx3w@public.gmane.org>,
	Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	linux-nfs <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM list <linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Ben Chan <benchan-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	smfrench-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130506174336.447d0d75-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, May 6, 2013 at 2:43 PM, Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On Mon, 6 May 2013 12:57:54 -0700
> Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org> wrote:
>
>> On Mon, May 6, 2013 at 3:56 AM, Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
>> > On Fri,  3 May 2013 14:04:09 -0700
>> > Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org> wrote:
>> >
>> >> NFS calls the freezable helpers with locks held, which is unsafe
>> >> and caused lockdep warnings when 6aa9707 "lockdep: check that no
>> >> locks held at freeze time" was applied (reverted in dbf520a).
>> >> Add new *_unsafe versions of the helpers that will not run the
>> >> lockdep test when 6aa9707 is reapplied, and call them from NFS.
>> >>
>> >> Signed-off-by: Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
>> >> ---
>> >>  fs/nfs/inode.c          |  2 +-
>> >>  fs/nfs/nfs3proc.c       |  2 +-
>> >>  fs/nfs/nfs4proc.c       |  4 ++--
>> >>  include/linux/freezer.h | 42 +++++++++++++++++++++++++++++++++++++++++-
>> >>  net/sunrpc/sched.c      |  2 +-
>> >>  5 files changed, 46 insertions(+), 6 deletions(-)
>> >>
>> >> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
>> >> index 1f94167..53cbee5 100644
>> >> --- a/fs/nfs/inode.c
>> >> +++ b/fs/nfs/inode.c
>> >> @@ -79,7 +79,7 @@ int nfs_wait_bit_killable(void *word)
>> >>  {
>> >>       if (fatal_signal_pending(current))
>> >>               return -ERESTARTSYS;
>> >> -     freezable_schedule();
>> >> +     freezable_schedule_unsafe();
>> >>       return 0;
>> >>  }
>> >>  EXPORT_SYMBOL_GPL(nfs_wait_bit_killable);
>> >> diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
>> >> index 43ea96c..ce90eb4 100644
>> >> --- a/fs/nfs/nfs3proc.c
>> >> +++ b/fs/nfs/nfs3proc.c
>> >> @@ -33,7 +33,7 @@ nfs3_rpc_wrapper(struct rpc_clnt *clnt, struct rpc_message *msg, int flags)
>> >>               res = rpc_call_sync(clnt, msg, flags);
>> >>               if (res != -EJUKEBOX)
>> >>                       break;
>> >> -             freezable_schedule_timeout_killable(NFS_JUKEBOX_RETRY_TIME);
>> >> +             freezable_schedule_timeout_killable_unsafe(NFS_JUKEBOX_RETRY_TIME);
>> >>               res = -ERESTARTSYS;
>> >>       } while (!fatal_signal_pending(current));
>> >>       return res;
>> >> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> >> index 0ad025e..a236077 100644
>> >> --- a/fs/nfs/nfs4proc.c
>> >> +++ b/fs/nfs/nfs4proc.c
>> >> @@ -266,7 +266,7 @@ static int nfs4_delay(struct rpc_clnt *clnt, long *timeout)
>> >>               *timeout = NFS4_POLL_RETRY_MIN;
>> >>       if (*timeout > NFS4_POLL_RETRY_MAX)
>> >>               *timeout = NFS4_POLL_RETRY_MAX;
>> >> -     freezable_schedule_timeout_killable(*timeout);
>> >> +     freezable_schedule_timeout_killable_unsafe(*timeout);
>> >>       if (fatal_signal_pending(current))
>> >>               res = -ERESTARTSYS;
>> >>       *timeout <<= 1;
>> >> @@ -4309,7 +4309,7 @@ int nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, const nfs4
>> >>  static unsigned long
>> >>  nfs4_set_lock_task_retry(unsigned long timeout)
>> >>  {
>> >> -     freezable_schedule_timeout_killable(timeout);
>> >> +     freezable_schedule_timeout_killable_unsafe(timeout);
>> >>       timeout <<= 1;
>> >>       if (timeout > NFS4_LOCK_MAXTIMEOUT)
>> >>               return NFS4_LOCK_MAXTIMEOUT;
>> >> diff --git a/include/linux/freezer.h b/include/linux/freezer.h
>> >> index e70df40..5b31e21c 100644
>> >> --- a/include/linux/freezer.h
>> >> +++ b/include/linux/freezer.h
>> >> @@ -46,7 +46,11 @@ extern int freeze_kernel_threads(void);
>> >>  extern void thaw_processes(void);
>> >>  extern void thaw_kernel_threads(void);
>> >>
>> >> -static inline bool try_to_freeze(void)
>> >> +/*
>> >> + * DO NOT ADD ANY NEW CALLERS OF THIS FUNCTION
>> >> + * If try_to_freeze causes a lockdep warning it means the caller may deadlock
>> >> + */
>> >> +static inline bool try_to_freeze_unsafe(void)
>> >>  {
>> >>       might_sleep();
>> >>       if (likely(!freezing(current)))
>> >> @@ -54,6 +58,11 @@ static inline bool try_to_freeze(void)
>> >>       return __refrigerator(false);
>> >>  }
>> >>
>> >> +static inline bool try_to_freeze(void)
>> >> +{
>> >> +     return try_to_freeze_unsafe();
>> >> +}
>> >> +
>> >>  extern bool freeze_task(struct task_struct *p);
>> >>  extern bool set_freezable(void);
>> >>
>> >> @@ -115,6 +124,14 @@ static inline void freezer_count(void)
>> >>       try_to_freeze();
>> >>  }
>> >>
>> >> +/* DO NOT ADD ANY NEW CALLERS OF THIS FUNCTION */
>> >> +static inline void freezer_count_unsafe(void)
>> >> +{
>> >> +     current->flags &= ~PF_FREEZER_SKIP;
>> >> +     smp_mb();
>> >> +     try_to_freeze_unsafe();
>> >> +}
>> >> +
>> >>  /**
>> >>   * freezer_should_skip - whether to skip a task when determining frozen
>> >>   *                    state is reached
>> >> @@ -152,6 +169,14 @@ static inline bool freezer_should_skip(struct task_struct *p)
>> >>       freezer_count();                                                \
>> >>  })
>> >>
>> >> +/* DO NOT ADD ANY NEW CALLERS OF THIS FUNCTION */
>> >> +#define freezable_schedule_unsafe()                                  \
>> >> +({                                                                   \
>> >> +     freezer_do_not_count();                                         \
>> >> +     schedule();                                                     \
>> >> +     freezer_count_unsafe();                                         \
>> >> +})
>> >> +
>> >>  /* Like schedule_timeout_killable(), but should not block the freezer. */
>> >>  #define freezable_schedule_timeout_killable(timeout)                 \
>> >>  ({                                                                   \
>> >> @@ -162,6 +187,16 @@ static inline bool freezer_should_skip(struct task_struct *p)
>> >>       __retval;                                                       \
>> >>  })
>> >>
>> >> +/* DO NOT ADD ANY NEW CALLERS OF THIS FUNCTION */
>> >> +#define freezable_schedule_timeout_killable_unsafe(timeout)          \
>> >> +({                                                                   \
>> >> +     long __retval;                                                  \
>> >> +     freezer_do_not_count();                                         \
>> >> +     __retval = schedule_timeout_killable(timeout);                  \
>> >> +     freezer_count_unsafe();                                         \
>> >> +     __retval;                                                       \
>> >> +})
>> >> +
>> >>  /*
>> >>   * Freezer-friendly wrappers around wait_event_interruptible(),
>> >>   * wait_event_killable() and wait_event_interruptible_timeout(), originally
>> >> @@ -225,9 +260,14 @@ static inline void set_freezable(void) {}
>> >>
>> >>  #define freezable_schedule()  schedule()
>> >>
>> >> +#define freezable_schedule_unsafe()  schedule()
>> >> +
>> >>  #define freezable_schedule_timeout_killable(timeout)                 \
>> >>       schedule_timeout_killable(timeout)
>> >>
>> >> +#define freezable_schedule_timeout_killable_unsafe(timeout)          \
>> >> +     schedule_timeout_killable(timeout)
>> >> +
>> >>  #define wait_event_freezable(wq, condition)                          \
>> >>               wait_event_interruptible(wq, condition)
>> >>
>> >> diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
>> >> index f8529fc..8dcfadc 100644
>> >> --- a/net/sunrpc/sched.c
>> >> +++ b/net/sunrpc/sched.c
>> >> @@ -254,7 +254,7 @@ static int rpc_wait_bit_killable(void *word)
>> >>  {
>> >>       if (fatal_signal_pending(current))
>> >>               return -ERESTARTSYS;
>> >> -     freezable_schedule();
>> >> +     freezable_schedule_unsafe();
>> >>       return 0;
>> >>  }
>> >>
>> >
>> > Looks reasonable, but note that CIFS uses wait_event_freezekillable
>> > with locks held too, which will likely have the same problem and will
>> > need the same workaround for now.
>>
>> I didn't see any lockdep warnings reported on the mailing list when
>> the lockdep patch was previously applied, can you point me to the lock
>> that is held when wait_event_freezkillable is called?  I don't want to
>> add an _unsafe call where its not needed and cause more confusion.
>
> It's pretty much all of the same VFS-level locks...
>
> Basically, when a process wants to send a synchronous SMB to a CIFS
> server, it'll send off the request and then call wait_for_response() to
> wait on the reply. If you need a particular call stack, then you can
> look in the rmdir() codepath as an example:
>
> vfs_rmdir takes the i_mutex
>    cifs_rmdir (via the inode ops)
>       CIFSSMBRmDir (via the smb version ops)
>           SendReceive
>                wait_for_response
>
> ...at that point a freeze can occur while you're still holding the
> i_mutex.
>
> There are many other possibilities for other codepaths that end up in
> wait_for_response(). Once we get a solution in place for NFS, we'll
> need to do something very similar for CIFS.

Makes sense, I will add CIFS to the patch.  Would you prefer it in the
same or separate patches.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

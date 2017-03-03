From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [PATCH v5 06/10] seccomp,landlock: Handle
 Landlock events per process hierarchy
Date: Fri, 3 Mar 2017 01:54:11 +0100
Message-ID: <db12f408-4e5d-d3f3-1b52-ebab5ee7452f@digikod.net>
References: <20170222012632.4196-1-mic@digikod.net>
 <20170222012632.4196-7-mic@digikod.net>
 <CAEiveUdZM=QquC0Kog66TwNwoEjJ_6ZobSOwhHrfuLC0e-Ua7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="F3xB55hx7IcuVD8jPuj6rcwg628e0Ig7p"
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Arnaldo Carvalho de Melo <acme@kernel.org>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Drysdale
 <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>, Jann Horn <jann@thejh.net>,
        Jonathan Corbet <corbet@lwn.net>,
        Matthew Garrett <mjg59@srcf.ucam.org>,
        Michael Kerrisk <mtk.manpages@gmail.com>,
        Kees Cook <keescook@chromium.org>, Paul Moore <paul@paul-moore.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Shuah Khan <shuah@kernel.org>,
        Tejun Heo <tj@kernel.org>, Thomas G
To: Djalal Harouni <tixxdz@gmail.com>
Return-path: <kernel-hardening-return-6896-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CAEiveUdZM=QquC0Kog66TwNwoEjJ_6ZobSOwhHrfuLC0e-Ua7g@mail.gmail.com>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--F3xB55hx7IcuVD8jPuj6rcwg628e0Ig7p
Content-Type: multipart/mixed; boundary="HIA4qlTVBktPbJimXjlUGrp6wV1AquGto";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Djalal Harouni <tixxdz@gmail.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
 Alexei Starovoitov <ast@kernel.org>, Andy Lutomirski <luto@amacapital.net>,
 Arnaldo Carvalho de Melo <acme@kernel.org>,
 Casey Schaufler <casey@schaufler-ca.com>,
 Daniel Borkmann <daniel@iogearbox.net>, David Drysdale
 <drysdale@google.com>, "David S . Miller" <davem@davemloft.net>,
 "Eric W . Biederman" <ebiederm@xmission.com>,
 James Morris <james.l.morris@oracle.com>, Jann Horn <jann@thejh.net>,
 Jonathan Corbet <corbet@lwn.net>, Matthew Garrett <mjg59@srcf.ucam.org>,
 Michael Kerrisk <mtk.manpages@gmail.com>, Kees Cook <keescook@chromium.org>,
 Paul Moore <paul@paul-moore.com>, Sargun Dhillon <sargun@sargun.me>,
 "Serge E . Hallyn" <serge@hallyn.com>, Shuah Khan <shuah@kernel.org>,
 Tejun Heo <tj@kernel.org>, Thomas Graf <tgraf@suug.ch>,
 Will Drewry <wad@chromium.org>, kernel-hardening@lists.openwall.com,
 Linux API <linux-api@vger.kernel.org>,
 LSM List <linux-security-module@vger.kernel.org>, netdev@vger.kernel.org,
 Andrew Morton <akpm@linux-foundation.org>
Message-ID: <db12f408-4e5d-d3f3-1b52-ebab5ee7452f@digikod.net>
Subject: Re: [kernel-hardening] [PATCH v5 06/10] seccomp,landlock: Handle
 Landlock events per process hierarchy
References: <20170222012632.4196-1-mic@digikod.net>
 <20170222012632.4196-7-mic@digikod.net>
 <CAEiveUdZM=QquC0Kog66TwNwoEjJ_6ZobSOwhHrfuLC0e-Ua7g@mail.gmail.com>
In-Reply-To: <CAEiveUdZM=QquC0Kog66TwNwoEjJ_6ZobSOwhHrfuLC0e-Ua7g@mail.gmail.com>

--HIA4qlTVBktPbJimXjlUGrp6wV1AquGto
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable



On 02/03/2017 11:22, Djalal Harouni wrote:
> On Wed, Feb 22, 2017 at 2:26 AM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.=
net> wrote:
>> The seccomp(2) syscall can be use to apply a Landlock rule to the
>> current process. As with a seccomp filter, the Landlock rule is enforc=
ed
>> for all its future children. An inherited rule tree can be updated
>> (append-only) by the owner of inherited Landlock nodes (e.g. a parent
>> process that create a new rule). However, an intermediate task, which
>> did not create a rule, will not be able to update its children's rules=
=2E
>>
>> Landlock rules can be tied to a Landlock event. When such an event is
>> triggered, a tree of rules can be evaluated. Thisk kind of tree is
>> created with a first node.  This node reference a list of rules and an=

>> optional parent node. Each rule return a 32-bit value which can
>> interrupt the evaluation with a non-zero value. If every rules returne=
d
>> zero, the evaluation continues with the rule list of the parent node,
>> until the end of the tree.
>>
>> Changes since v4:
>> * merge manager and seccomp patches
>> * return -EFAULT in seccomp(2) when user_bpf_fd is null to easely chec=
k
>>   if Landlock is supported
>> * only allow a process with the global CAP_SYS_ADMIN to use Landlock
>>   (will be lifted in the future)
>> * add an early check to exit as soon as possible if the current proces=
s
>>   does not have Landlock rules
>>
>> Changes since v3:
>> * remove the hard link with seccomp (suggested by Andy Lutomirski and
>>   Kees Cook):
>>   * remove the cookie which could imply multiple evaluation of Landloc=
k
>>     rules
>>   * remove the origin field in struct landlock_data
>> * remove documentation fix (merged upstream)
>> * rename the new seccomp command to SECCOMP_ADD_LANDLOCK_RULE
>> * internal renaming
>> * split commit
>> * new design to be able to inherit on the fly the parent rules
>>
>> Changes since v2:
>> * Landlock programs can now be run without seccomp filter but for any
>>   syscall (from the process) or interruption
>> * move Landlock related functions and structs into security/landlock/*=

>>   (to manage cgroups as well)
>> * fix seccomp filter handling: run Landlock programs for each of their=

>>   legitimate seccomp filter
>> * properly clean up all seccomp results
>> * cosmetic changes to ease the understanding
>> * fix some ifdef
>>
>> Signed-off-by: Micka=C3=ABl Sala=C3=BCn <mic@digikod.net>
>> Cc: Alexei Starovoitov <ast@kernel.org>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Andy Lutomirski <luto@amacapital.net>
>> Cc: James Morris <james.l.morris@oracle.com>
>> Cc: Kees Cook <keescook@chromium.org>
>> Cc: Serge E. Hallyn <serge@hallyn.com>
>> Cc: Will Drewry <wad@chromium.org>
>> ---
>>  include/linux/seccomp.h      |   8 ++
>>  include/uapi/linux/seccomp.h |   1 +
>>  kernel/fork.c                |  14 +-
>>  kernel/seccomp.c             |   8 ++
>>  security/landlock/Makefile   |   2 +-
>>  security/landlock/hooks.c    |  42 +++++-
>>  security/landlock/manager.c  | 321 ++++++++++++++++++++++++++++++++++=
+++++++++
>>  7 files changed, 392 insertions(+), 4 deletions(-)
>>  create mode 100644 security/landlock/manager.c
>>
>> diff --git a/include/linux/seccomp.h b/include/linux/seccomp.h
>> index e25aee2cdfc0..9a38de3c0e72 100644
>> --- a/include/linux/seccomp.h
>> +++ b/include/linux/seccomp.h
>> @@ -10,6 +10,10 @@
>>  #include <linux/thread_info.h>
>>  #include <asm/seccomp.h>
>>
>> +#if defined(CONFIG_SECCOMP_FILTER) && defined(CONFIG_SECURITY_LANDLOC=
K)
>> +struct landlock_events;
>> +#endif /* CONFIG_SECCOMP_FILTER && CONFIG_SECURITY_LANDLOCK */
>> +
>>  struct seccomp_filter;
>>  /**
>>   * struct seccomp - the state of a seccomp'ed process
>> @@ -18,6 +22,7 @@ struct seccomp_filter;
>>   *         system calls available to a process.
>>   * @filter: must always point to a valid seccomp-filter or NULL as it=
 is
>>   *          accessed without locking during system call entry.
>> + * @landlock_events: contains an array of Landlock rules.
>>   *
>>   *          @filter must only be accessed from the context of current=
 as there
>>   *          is no read locking.
>> @@ -25,6 +30,9 @@ struct seccomp_filter;
>>  struct seccomp {
>>         int mode;
>>         struct seccomp_filter *filter;
>> +#if defined(CONFIG_SECCOMP_FILTER) && defined(CONFIG_SECURITY_LANDLOC=
K)
>> +       struct landlock_events *landlock_events;
>> +#endif /* CONFIG_SECCOMP_FILTER && CONFIG_SECURITY_LANDLOCK */
>>  };
>>
>>  #ifdef CONFIG_HAVE_ARCH_SECCOMP_FILTER
>> diff --git a/include/uapi/linux/seccomp.h b/include/uapi/linux/seccomp=
=2Eh
>> index 0f238a43ff1e..56dd692cddac 100644
>> --- a/include/uapi/linux/seccomp.h
>> +++ b/include/uapi/linux/seccomp.h
>> @@ -13,6 +13,7 @@
>>  /* Valid operations for seccomp syscall. */
>>  #define SECCOMP_SET_MODE_STRICT        0
>>  #define SECCOMP_SET_MODE_FILTER        1
>> +#define SECCOMP_ADD_LANDLOCK_RULE      2
>>
>>  /* Valid flags for SECCOMP_SET_MODE_FILTER */
>>  #define SECCOMP_FILTER_FLAG_TSYNC      1
>> diff --git a/kernel/fork.c b/kernel/fork.c
>> index a4f0d0e8aeb2..bd5c72dffe60 100644
>> --- a/kernel/fork.c
>> +++ b/kernel/fork.c
>> @@ -37,6 +37,7 @@
>>  #include <linux/security.h>
>>  #include <linux/hugetlb.h>
>>  #include <linux/seccomp.h>
>> +#include <linux/landlock.h>
>>  #include <linux/swap.h>
>>  #include <linux/syscalls.h>
>>  #include <linux/jiffies.h>
>> @@ -515,7 +516,10 @@ static struct task_struct *dup_task_struct(struct=
 task_struct *orig, int node)
>>          * the usage counts on the error path calling free_task.
>>          */
>>         tsk->seccomp.filter =3D NULL;
>> -#endif
>> +#ifdef CONFIG_SECURITY_LANDLOCK
>> +       tsk->seccomp.landlock_events =3D NULL;
>> +#endif /* CONFIG_SECURITY_LANDLOCK */
>> +#endif /* CONFIG_SECCOMP */
>>
>>         setup_thread_stack(tsk, orig);
>>         clear_user_return_notifier(tsk);
>> @@ -1388,7 +1392,13 @@ static void copy_seccomp(struct task_struct *p)=

>>
>>         /* Ref-count the new filter user, and assign it. */
>>         get_seccomp_filter(current);
>> -       p->seccomp =3D current->seccomp;
>> +       p->seccomp.mode =3D current->seccomp.mode;
>> +       p->seccomp.filter =3D current->seccomp.filter;
>> +#if defined(CONFIG_SECCOMP_FILTER) && defined(CONFIG_SECURITY_LANDLOC=
K)
>> +       p->seccomp.landlock_events =3D current->seccomp.landlock_event=
s;
>> +       if (p->seccomp.landlock_events)
>> +               atomic_inc(&p->seccomp.landlock_events->usage);
>> +#endif /* CONFIG_SECCOMP_FILTER && CONFIG_SECURITY_LANDLOCK */
>>
>>         /*
>>          * Explicitly enable no_new_privs here in case it got set
>> diff --git a/kernel/seccomp.c b/kernel/seccomp.c
>> index 06f2f3ee454c..ef412d95ff5d 100644
>> --- a/kernel/seccomp.c
>> +++ b/kernel/seccomp.c
>> @@ -32,6 +32,7 @@
>>  #include <linux/security.h>
>>  #include <linux/tracehook.h>
>>  #include <linux/uaccess.h>
>> +#include <linux/landlock.h>
>>
>>  /**
>>   * struct seccomp_filter - container for seccomp BPF programs
>> @@ -492,6 +493,9 @@ static void put_seccomp_filter(struct seccomp_filt=
er *filter)
>>  void put_seccomp(struct task_struct *tsk)
>>  {
>>         put_seccomp_filter(tsk->seccomp.filter);
>> +#ifdef CONFIG_SECURITY_LANDLOCK
>> +       put_landlock_events(tsk->seccomp.landlock_events);
>> +#endif /* CONFIG_SECURITY_LANDLOCK */
>>  }
>>
>>  /**
>> @@ -796,6 +800,10 @@ static long do_seccomp(unsigned int op, unsigned =
int flags,
>>                 return seccomp_set_mode_strict();
>>         case SECCOMP_SET_MODE_FILTER:
>>                 return seccomp_set_mode_filter(flags, uargs);
>> +#if defined(CONFIG_SECCOMP_FILTER) && defined(CONFIG_SECURITY_LANDLOC=
K)
>> +       case SECCOMP_ADD_LANDLOCK_RULE:
>> +               return landlock_seccomp_append_prog(flags, uargs);
>> +#endif /* CONFIG_SECCOMP_FILTER && CONFIG_SECURITY_LANDLOCK */
>>         default:
>>                 return -EINVAL;
>>         }
>> diff --git a/security/landlock/Makefile b/security/landlock/Makefile
>> index 8dc8bde660bd..6c1b0d8bd810 100644
>> --- a/security/landlock/Makefile
>> +++ b/security/landlock/Makefile
>> @@ -2,4 +2,4 @@ ccflags-$(CONFIG_SECURITY_LANDLOCK) +=3D -Werror=3Dunu=
sed-function
>>
>>  obj-$(CONFIG_SECURITY_LANDLOCK) :=3D landlock.o
>>
>> -landlock-y :=3D hooks.o
>> +landlock-y :=3D hooks.o manager.o
>> diff --git a/security/landlock/hooks.c b/security/landlock/hooks.c
>> index 88ebe3f01758..704ea18377d2 100644
>> --- a/security/landlock/hooks.c
>> +++ b/security/landlock/hooks.c
>> @@ -290,7 +290,44 @@ static u64 mem_prot_to_access(unsigned long prot,=
 bool private)
>>
>>  static inline bool landlock_used(void)
>>  {
>> +#ifdef CONFIG_SECCOMP_FILTER
>> +       return !!(current->seccomp.landlock_events);
>> +#else
>>         return false;
>> +#endif /* CONFIG_SECCOMP_FILTER */
>> +}
>> +
>> +/**
>> + * landlock_run_prog - run Landlock program for a syscall
>> + *
>> + * @event_idx: event index in the rules array
>> + * @ctx: non-NULL eBPF context
>> + * @events: Landlock events pointer
>> + */
>> +static int landlock_run_prog(u32 event_idx, const struct landlock_con=
text *ctx,
>> +               struct landlock_events *events)
>> +{
>> +       struct landlock_node *node;
>> +
>> +       if (!events)
>> +               return 0;
>> +
>> +       for (node =3D events->nodes[event_idx]; node; node =3D node->p=
rev) {
>> +               struct landlock_rule *rule;
>> +
>> +               for (rule =3D node->rule; rule; rule =3D rule->prev) {=

>> +                       u32 ret;
>> +
>> +                       if (WARN_ON(!rule->prog))
>> +                               continue;
>> +                       rcu_read_lock();
>> +                       ret =3D BPF_PROG_RUN(rule->prog, (void *)ctx);=

>> +                       rcu_read_unlock();
>> +                       if (ret)
>> +                               return -EPERM;
>> +               }
>> +       }
>> +       return 0;
>>  }
>>
>>  static int landlock_decide(enum landlock_subtype_event event,
>> @@ -309,7 +346,10 @@ static int landlock_decide(enum landlock_subtype_=
event event,
>>                 .arg2 =3D ctx_values[1],
>>         };
>>
>> -       /* insert manager call here */
>> +#ifdef CONFIG_SECCOMP_FILTER
>> +       ret =3D landlock_run_prog(event_idx, &ctx,
>> +                       current->seccomp.landlock_events);
>> +#endif /* CONFIG_SECCOMP_FILTER */
>>
>>         return ret;
>>  }
>> diff --git a/security/landlock/manager.c b/security/landlock/manager.c=

>> new file mode 100644
>> index 000000000000..00bb2944c85e
>> --- /dev/null
>> +++ b/security/landlock/manager.c
>> @@ -0,0 +1,321 @@
>> +/*
>> + * Landlock LSM - seccomp manager
>> + *
>> + * Copyright =C2=A9 2017 Micka=C3=ABl Sala=C3=BCn <mic@digikod.net>
>> + *
>> + * This program is free software; you can redistribute it and/or modi=
fy
>> + * it under the terms of the GNU General Public License version 2, as=

>> + * published by the Free Software Foundation.
>> + */
>> +
>> +#include <asm/page.h> /* PAGE_SIZE */
>> +#include <linux/atomic.h> /* atomic_*(), smp_store_release() */
>> +#include <linux/bpf.h> /* bpf_prog_put() */
>> +#include <linux/filter.h> /* struct bpf_prog */
>> +#include <linux/kernel.h> /* round_up() */
>> +#include <linux/landlock.h>
>> +#include <linux/sched.h> /* current_cred(), task_no_new_privs() */
>> +#include <linux/security.h> /* security_capable_noaudit() */
>> +#include <linux/slab.h> /* alloc(), kfree() */
>> +#include <linux/types.h> /* atomic_t */
>> +#include <linux/uaccess.h> /* copy_from_user() */
>> +
>> +#include "common.h"
>> +
>> +static void put_landlock_rule(struct landlock_rule *rule)
>> +{
>> +       struct landlock_rule *orig =3D rule;
>> +
>> +       /* clean up single-reference branches iteratively */
>> +       while (orig && atomic_dec_and_test(&orig->usage)) {
>> +               struct landlock_rule *freeme =3D orig;
>> +
>> +               bpf_prog_put(orig->prog);
>> +               orig =3D orig->prev;
>> +               kfree(freeme);
>> +       }
>> +}
>> +
>> +static void put_landlock_node(struct landlock_node *node)
>> +{
>> +       struct landlock_node *orig =3D node;
>> +
>> +       /* clean up single-reference branches iteratively */
>> +       while (orig && atomic_dec_and_test(&orig->usage)) {
>> +               struct landlock_node *freeme =3D orig;
>> +
>> +               put_landlock_rule(orig->rule);
>> +               orig =3D orig->prev;
>> +               kfree(freeme);
>> +       }
>> +}
>> +
>> +void put_landlock_events(struct landlock_events *events)
>> +{
>> +       if (events && atomic_dec_and_test(&events->usage)) {
>> +               size_t i;
>> +
>> +               /* XXX: Do we need to use lockless_dereference() here?=
 */
>> +               for (i =3D 0; i < ARRAY_SIZE(events->nodes); i++) {
>> +                       if (!events->nodes[i])
>> +                               continue;
>> +                       /* Are we the owner of this node? */
>> +                       if (events->nodes[i]->owner =3D=3D &events->no=
des[i])
>> +                               events->nodes[i]->owner =3D NULL;
>> +                       put_landlock_node(events->nodes[i]);
>> +               }
>> +               kfree(events);
>> +       }
>> +}
>> +
>> +static struct landlock_events *new_raw_landlock_events(void)
>> +{
>> +       struct landlock_events *ret;
>> +
>> +       /* array filled with NULL values */
>> +       ret =3D kzalloc(sizeof(*ret), GFP_KERNEL);
>> +       if (!ret)
>> +               return ERR_PTR(-ENOMEM);
>> +       atomic_set(&ret->usage, 1);
>> +       return ret;
>> +}
>> +
>> +static struct landlock_events *new_filled_landlock_events(void)
>> +{
>> +       size_t i;
>> +       struct landlock_events *ret;
>> +
>> +       ret =3D new_raw_landlock_events();
>> +       if (IS_ERR(ret))
>> +               return ret;
>> +       /*
>> +        * We need to initially allocate every nodes to be able to upd=
ate the
>> +        * rules they are pointing to, across every (future) children =
of the
>> +        * current task.
>> +        */
>> +       for (i =3D 0; i < ARRAY_SIZE(ret->nodes); i++) {
>> +               struct landlock_node *node;
>> +
>> +               node =3D kzalloc(sizeof(*node), GFP_KERNEL);
>> +               if (!node)
>> +                       goto put_events;
>> +               atomic_set(&node->usage, 1);
>> +               /* we are the owner of this node */
>> +               node->owner =3D &ret->nodes[i];
>> +               ret->nodes[i] =3D node;
>> +       }
>> +       return ret;
>> +
>> +put_events:
>> +       put_landlock_events(ret);
>> +       return ERR_PTR(-ENOMEM);
>> +}
>> +
>> +static void add_landlock_rule(struct landlock_events *events,
>> +               struct landlock_rule *rule)
>> +{
>> +       /* subtype.landlock_rule.event > 0 for loaded programs */
>> +       u32 event_idx =3D get_index(rule->prog->subtype.landlock_rule.=
event);
>> +
>> +       rule->prev =3D events->nodes[event_idx]->rule;
>> +       WARN_ON(atomic_read(&rule->usage));
>> +       atomic_set(&rule->usage, 1);
>> +       /* do not increment the previous rule usage */
>> +       smp_store_release(&events->nodes[event_idx]->rule, rule);
>> +}
>> +
>> +/* Limit Landlock events to 256KB. */
>> +#define LANDLOCK_EVENTS_MAX_PAGES (1 << 6)
>> +
>> +/**
>> + * landlock_append_prog - attach a Landlock rule to @current_events
>> + *
>> + * @current_events: landlock_events pointer, must be locked (if neede=
d) to
>> + *                  prevent a concurrent put/free. This pointer must =
not be
>> + *                  freed after the call.
>> + * @prog: non-NULL Landlock rule to append to @current_events. @prog =
will be
>> + *        owned by landlock_append_prog() and freed if an error happe=
ned.
>> + *
>> + * Return @current_events or a new pointer when OK. Return a pointer =
error
>> + * otherwise.
>> + */
>> +static struct landlock_events *landlock_append_prog(
>> +               struct landlock_events *current_events, struct bpf_pro=
g *prog)
>> +{
>> +       struct landlock_events *new_events =3D current_events;
>> +       unsigned long pages;
>> +       struct landlock_rule *rule;
>> +       u32 event_idx;
>> +
>> +       if (prog->type !=3D BPF_PROG_TYPE_LANDLOCK) {
>> +               new_events =3D ERR_PTR(-EINVAL);
>> +               goto put_prog;
>> +       }
>> +
>> +       /* validate memory size allocation */
>> +       pages =3D prog->pages;
>> +       if (current_events) {
>> +               size_t i;
>> +
>> +               for (i =3D 0; i < ARRAY_SIZE(current_events->nodes); i=
++) {
>> +                       struct landlock_node *walker_n;
>> +
>> +                       for (walker_n =3D current_events->nodes[i];
>> +                                       walker_n;
>> +                                       walker_n =3D walker_n->prev) {=

>> +                               struct landlock_rule *walker_r;
>> +
>> +                               for (walker_r =3D walker_n->rule;
>> +                                               walker_r;
>> +                                               walker_r =3D walker_r-=
>prev)
>> +                                       pages +=3D walker_r->prog->pag=
es;
>> +                       }
>> +               }
>> +               /* count a struct landlock_events if we need to alloca=
te one */
>> +               if (atomic_read(&current_events->usage) !=3D 1)
>> +                       pages +=3D round_up(sizeof(*current_events), P=
AGE_SIZE) /
>> +                               PAGE_SIZE;
>> +       }
>> +       if (pages > LANDLOCK_EVENTS_MAX_PAGES) {
>> +               new_events =3D ERR_PTR(-E2BIG);
>> +               goto put_prog;
>> +       }
>> +
>> +       rule =3D kzalloc(sizeof(*rule), GFP_KERNEL);
>> +       if (!rule) {
>> +               new_events =3D ERR_PTR(-ENOMEM);
>> +               goto put_prog;
>> +       }
>> +       rule->prog =3D prog;
>> +
>> +       /* subtype.landlock_rule.event > 0 for loaded programs */
>> +       event_idx =3D get_index(rule->prog->subtype.landlock_rule.even=
t);
>> +
>> +       if (!current_events) {
>> +               /* add a new landlock_events, if needed */
>> +               new_events =3D new_filled_landlock_events();
>> +               if (IS_ERR(new_events))
>> +                       goto put_rule;
>> +               add_landlock_rule(new_events, rule);
>> +       } else {
>> +               if (new_events->nodes[event_idx]->owner =3D=3D
>> +                               &new_events->nodes[event_idx]) {
>> +                       /* We are the owner, we can then update the no=
de. */
>> +                       add_landlock_rule(new_events, rule);
>> +               } else if (atomic_read(&current_events->usage) =3D=3D =
1) {
>> +                       WARN_ON(new_events->nodes[event_idx]->owner);
>> +                       /*
>> +                        * We can become the new owner if no other tas=
k use it.
>> +                        * This avoid an unnecessary allocation.
>> +                        */
>> +                       new_events->nodes[event_idx]->owner =3D
>> +                               &new_events->nodes[event_idx];
>> +                       add_landlock_rule(new_events, rule);
>=20
> I still don't get it all, but maybe here to make it simple you have to
> always allocate, since the WARN_ON() suggests it should be scheduled
> to be removed... and avoid to care about whether you are using/freeing
> old rules of the dead task... ?

I'm not sure to get your point but I will make the inheritance behavior
similar to seccomp filter at first, hence simpler.


--HIA4qlTVBktPbJimXjlUGrp6wV1AquGto--

--F3xB55hx7IcuVD8jPuj6rcwg628e0Ig7p
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEEUysCyY8er9Axt7hqIt7+33O9apUFAli4vrMACgkQIt7+33O9
apUQYggAlnl956QHc+TkQRc82VPR0QCfSpBnzuJl88puBCV4P05pGWlZ5D59/L4k
OcEqk+bK/IBYO/yXy1Tkl7jdAGBvvyYdrG6W30KNfSaIPxDpvaZbm3oc0+8jcSKn
n3OX17SMytUfK/ttH7H1oZIN74i2ayYDOD2YUdv7W8X7HJesaq1y244YFaGXa8B5
ph7iShkH6QUI6WR8+R8hewrVGpk8V5nQNFmxrrAirdZzKyZ3+4pZe+PP4niESK9R
D9r33zHf9jo8tHcRDko0EdB1Uu5yG/U65Dfg7/bWtiaPPSCBombKFm5K3cjIhkBD
NBHA4eaOblQgLLgOTrGDleMyvTSv9Q==
=BtBn
-----END PGP SIGNATURE-----

--F3xB55hx7IcuVD8jPuj6rcwg628e0Ig7p--

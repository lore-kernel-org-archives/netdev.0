From: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: Re: [RFC v3 03/22] bpf,landlock: Add a new arraymap type to deal with
 (Landlock) handles
Date: Mon, 3 Oct 2016 16:53:52 -0700
Message-ID: <CAGXu5jLgkbMN0KszLx3dcHfmksW_TORzT7JxHiGJL2Xux5TVBA@mail.gmail.com>
References: <20160914072415.26021-1-mic@digikod.net> <20160914072415.26021-4-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
        Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
        Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>,
        Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
        Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>,
        David Drysdale <drysdale-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Elena Reshetova <elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
        James Morris <james.l.morris-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        Paul Moore <pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>,
        "Serge E . Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        "kernel-hardening-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org"
        <kernel-hardening-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org>,
        Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160914072415.26021-4-mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 14, 2016 at 12:23 AM, Micka=C3=ABl Sala=C3=BCn <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org=
> wrote:
> This new arraymap looks like a set and brings new properties:
> * strong typing of entries: the eBPF functions get the array type of
>   elements instead of CONST_PTR_TO_MAP (e.g.
>   CONST_PTR_TO_LANDLOCK_HANDLE_FS);
> * force sequential filling (i.e. replace or append-only update), which
>   allow quick browsing of all entries.
>
> This strong typing is useful to statically check if the content of a map
> can be passed to an eBPF function. For example, Landlock use it to store
> and manage kernel objects (e.g. struct file) instead of dealing with
> userland raw data. This improve efficiency and ensure that an eBPF
> program can only call functions with the right high-level arguments.
>
> The enum bpf_map_handle_type list low-level types (e.g.
> BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_FD) which are identified when
> updating a map entry (handle). This handle types are used to infer a
> high-level arraymap type which are listed in enum bpf_map_array_type
> (e.g. BPF_MAP_ARRAY_TYPE_LANDLOCK_FS).
>
> For now, this new arraymap is only used by Landlock LSM (cf. next
> commits) but it could be useful for other needs.
>
> Changes since v2:
> * add a RLIMIT_NOFILE-based limit to the maximum number of arraymap
>   handle entries (suggested by Andy Lutomirski)
> * remove useless checks
>
> Changes since v1:
> * arraymap of handles replace custom checker groups
> * simpler userland API
>
> Signed-off-by: Micka=C3=ABl Sala=C3=BCn <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
> Cc: Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Cc: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
> Cc: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
> Cc: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
> Link: https://lkml.kernel.org/r/CALCETrWwTiz3kZTkEgOW24-DvhQq6LftwEXh77FD=
2G5o71yD7g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org
> ---
>  include/linux/bpf.h      |  14 ++++
>  include/uapi/linux/bpf.h |  18 +++++
>  kernel/bpf/arraymap.c    | 203 +++++++++++++++++++++++++++++++++++++++++=
++++++
>  kernel/bpf/verifier.c    |  12 ++-
>  4 files changed, 246 insertions(+), 1 deletion(-)
>
> [...]
> diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
> index a2ac051c342f..94256597eacd 100644
> --- a/kernel/bpf/arraymap.c
> +++ b/kernel/bpf/arraymap.c
> [...]
> +       /*
> +        * Limit number of entries in an arraymap of handles to the maxim=
um
> +        * number of open files for the current process. The maximum numb=
er of
> +        * handle entries (including all arraymaps) for a process is then
> +        * (RLIMIT_NOFILE - 1) * RLIMIT_NOFILE. If the process' RLIMIT_NO=
FILE
> +        * is 0, then any entry update is forbidden.
> +        *
> +        * An eBPF program can inherit all the arraymap FD. The worse cas=
e is
> +        * to fill a bunch of arraymaps, create an eBPF program, close th=
e
> +        * arraymap FDs, and start again. The maximum number of arraymap
> +        * entries can then be close to RLIMIT_NOFILE^3.
> +        *
> +        * FIXME: This should be improved... any idea?
> +        */
> +       if (unlikely(index >=3D rlimit(RLIMIT_NOFILE)))
> +               return -EMFILE;

I'm not sure what's best for resource management here. Landlock will
be holding open path structs, for example, but how are you expecting
to track things like network policies? An allowed IP address, for
example, doesn't have a handle outside of doing a full
socket()/connect() setup.

I think an explicit design for resource management should be
considered up front...

-Kees

--=20
Kees Cook
Nexus Security

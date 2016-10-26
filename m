From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC v4 02/18] bpf: Move u64_to_ptr() to BPF headers and inline it
Date: Wed, 26 Oct 2016 09:19:08 +0200
Message-ID: <4045933.vGduYR3PCp@wuerfel>
References: <20161026065654.19166-1-mic@digikod.net> <20161026065654.19166-3-mic@digikod.net>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>, Andy Lutomirski <luto@amacapital.net>, Daniel Borkmann <daniel@iogearbox.net>, Daniel Mack <daniel@zonque.org>, David Drysdale <drysdale@google.com>, "David S . Miller" <davem@davemloft.net>, "Eric W . Biederman" <ebiederm@xmission.com>, James Morris <james.l.morris@oracle.com>, Jann Horn <jann@thejh.net>, Kees Cook <keescook@chromium.org>, Paul Moore <pmoore@redhat.com>, Sargun Dhillon <sargun@sargun.me>, "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>, Thomas Graf <tgraf@suug.ch>, Will Drewry <wad@chromium.org>, kernel-hardening@lists.openwall.com, linux-api@vger.kernel.org, linux-security-module@vger.kernel.org, netdev@vger.kernel.org, cgroups@vger.kernel.org
To: =?ISO-8859-1?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>
Return-path: <kernel-hardening-return-5036-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20161026065654.19166-3-mic@digikod.net>
List-Id: netdev.vger.kernel.org

On Wednesday, October 26, 2016 8:56:38 AM CEST Micka=EBl Sala=FCn wrote:
>  include/linux/bpf.h  | 6 ++++++
>  kernel/bpf/syscall.c | 6 ------
>  2 files changed, 6 insertions(+), 6 deletions(-)
>=20
> diff --git a/include/linux/bpf.h b/include/linux/bpf.h
> index c201017b5730..cf87db6daf27 100644
> --- a/include/linux/bpf.h
> +++ b/include/linux/bpf.h
> @@ -283,6 +283,12 @@ static inline void bpf_long_memcpy(void *dst, const =
void *src, u32 size)
> =20
>  /* verify correctness of eBPF program */
>  int bpf_check(struct bpf_prog **fp, union bpf_attr *attr);
> +
> +/* helper to convert user pointers passed inside __aligned_u64 fields */
> +static inline void __user *u64_to_ptr(__u64 val)
> +{
> +       return (void __user *) (unsigned long) val;
> +}
>  #else
>=20


We already have at least six copies of this helper:

fs/btrfs/qgroup.c:#define u64_to_ptr(x) ((struct btrfs_qgroup *)(uintptr_t)=
x)
kernel/bpf/syscall.c:static void __user *u64_to_ptr(__u64 val)
drivers/staging/android/ion/ion_test.c:#define u64_to_uptr(x) ((void __user=
 *)(unsigned long)(x))
drivers/firewire/core-cdev.c:static void __user *u64_to_uptr(u64 value)
drivers/staging/android/ion/ion_test.c:#define u64_to_uptr(x) ((void __user=
 *)(unsigned long)(x))
include/linux/kernel.h:#define u64_to_user_ptr(x) (            \

Just use the one in linux/kernel.h

	Arnd

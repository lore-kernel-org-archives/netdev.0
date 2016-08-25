From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [RFC v2 09/10] landlock: Handle cgroups
Date: Thu, 25 Aug 2016 04:09:26 -0700
Message-ID: <CALCETrVqfTaY4gfwNdwynBqWwYh6xsGHaqdoA3uc_jHogbkA-A@mail.gmail.com>
References: <1472121165-29071-1-git-send-email-mic@digikod.net> <1472121165-29071-10-git-send-email-mic@digikod.net>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
	Arnd Bergmann <arnd@arndb.de>, Casey Schaufler <casey@schaufler-ca.com>,
	Daniel Borkmann <daniel@iogearbox.net>, Daniel Mack <daniel@zonque.org>,
	David Drysdale <drysdale@google.com>, "David S . Miller" <davem@davemloft.net>,
	Elena Reshetova <elena.reshetova@intel.com>, James Morris <james.l.morris@oracle.com>,
	Kees Cook <keescook@chromium.org>, Paul Moore <pmoore@redhat.com>,
	Sargun Dhillon <sargun@sargun.me>, "Serge E . Hallyn" <serge@hallyn.com>, Will Drewry <wad@chromium.org>,
	"kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Linux API <linux-api@vger.kernel.org>,
	LSM List <linux-security-module@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@digikod.net>
Return-path: <kernel-hardening-return-4463-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <1472121165-29071-10-git-send-email-mic@digikod.net>
List-Id: netdev.vger.kernel.org

On Thu, Aug 25, 2016 at 3:32 AM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.net>=
 wrote:
> Add an eBPF function bpf_landlock_cmp_cgroup_beneath(opt, map, map_op)
> to compare the current process cgroup with a cgroup handle, The handle
> can match the current cgroup if it is the same or a child. This allows
> to make conditional rules according to the current cgroup.
>
> A cgroup handle is a map entry created from a file descriptor referring
> a cgroup directory (e.g. by opening /sys/fs/cgroup/X). In this case, the
> map entry is of type BPF_MAP_HANDLE_TYPE_LANDLOCK_CGROUP_FD and the
> inferred array map is of type BPF_MAP_ARRAY_TYPE_LANDLOCK_CGROUP.

Can you elaborate on why this is useful?  I.e. why not just supply
different policies to different subtrees.

Also, how does this interact with the current cgroup v1 vs v2 mess?
As far as I can tell, no one can even really agree on what "what
cgroup am I in" means right now.

>
> An unprivileged process can create and manipulate cgroups thanks to
> cgroup delegation.

What is cgroup delegation?

--Andy

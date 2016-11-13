From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC v4 00/18] Landlock LSM: Unprivileged sandboxing
Date: Sun, 13 Nov 2016 09:38:11 -0800
Message-ID: <CAADnVQJURKRFbNiVTJ76XUWZ=P+DqyP0QMVZrCutzvS28bkhGw@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
	Andy Lutomirski <luto@amacapital.net>, Daniel Borkmann <daniel@iogearbox.net>,
	Daniel Mack <daniel@zonque.org>, David Drysdale <drysdale@google.com>,
	"David S . Miller" <davem@davemloft.net>, "Eric W . Biederman" <ebiederm@xmission.com>,
	James Morris <james.l.morris@oracle.com>, Jann Horn <jann@thejh.net>,
	Kees Cook <keescook@chromium.org>, Paul Moore <pmoore@redhat.com>,
	Sargun Dhillon <sargun@sargun.me>, "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
	Thomas Graf <tgraf@suug.ch>, Will Drewry <wad@chromium.org>, kernel-hardening@lists.openwall.com,
	Linux API <linux-api@vger.kernel.org>,
	LSM List <linux-security-module@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"open list:CONTROL GROUP (CGROUP)" <cgroups@vger.kernel.org>
To: =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@digikod.net>
Return-path: <kernel-hardening-return-5331-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
List-Id: netdev.vger.kernel.org

On Sun, Nov 13, 2016 at 6:23 AM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.net>=
 wrote:
> Hi,
>
> After the BoF at LPC last week, we came to a multi-step roadmap to
> upstream Landlock.
>
> A first patch series containing the basic properties needed for a
> "minimum viable product", which means being able to test it, without
> full features. The idea is to set in place the main components which
> include the LSM part (some hooks with the manager logic) and the new
> eBPF type. To have a minimum amount of code, the first userland entry
> point will be the seccomp syscall. This doesn't imply non-upstream
> patches and should be more simple. For the sake of simplicity and to
> ease the review, this first series will only be dedicated to privileged
> processes (i.e. with CAP_SYS_ADMIN). We may want to only allow one level
> of rules at first, instead of dealing with more complex rule inheritance
> (like seccomp-bpf can do).
>
> The second series will focus on the cgroup manager. It will follow the
> same rules of inheritance as the Daniel Mack's patches does.
>
> The third series will try to bring a BPF map of handles for Landlock and
> the dedicated BPF helpers.
>
> Finally, the fourth series will bring back the unprivileged mode (with
> no_new_privs), at least for process hierarchies (via seccomp). This also
> imply to handle multi-level of rules.
>
> Right now, an important point of attention is the userland ABI. We don't
> want LSM hooks to be exposed "as is" to userland. This may have some
> future implications if their semantic and/or enforcement point(s)
> change. In the next series, I will propose a new abstraction over the
> currently used LSM hooks. I'll also propose a new way to deal with
> resource accountability. Finally, I plan to create a minimal (kernel)
> developer documentation and a test suite.

Thanks for the summary.
That's exactly what we discussed and agreed upon.

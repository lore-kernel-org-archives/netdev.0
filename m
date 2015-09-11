From: Tycho Andersen <tycho.andersen@canonical.com>
Subject: Re: [PATCH v2 3/5] ebpf: add a way to dump an eBPF program
Date: Fri, 11 Sep 2015 08:44:51 -0600
Message-ID: <20150911144451.GJ27574@smitten>
References: <1441930862-14347-1-git-send-email-tycho.andersen@canonical.com>
 <1441930862-14347-4-git-send-email-tycho.andersen@canonical.com>
 <55F2D982.8010406@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kees Cook <keescook@chromium.org>,
	Alexei Starovoitov <ast@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Will Drewry <wad@chromium.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Pavel Emelyanov <xemul@parallels.com>,
	"Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-api@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <55F2D982.8010406@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 11, 2015 at 03:39:14PM +0200, Daniel Borkmann wrote:
> On 09/11/2015 02:21 AM, Tycho Andersen wrote:
> >This commit adds a way to dump eBPF programs. The initial implementation
> >doesn't support maps, and therefore only allows dumping seccomp ebpf
> >programs which themselves don't currently support maps.
> >
> >v2: don't export a prog_id for the filter
> >
> >Signed-off-by: Tycho Andersen <tycho.andersen@canonical.com>
> >CC: Kees Cook <keescook@chromium.org>
> >CC: Will Drewry <wad@chromium.org>
> >CC: Oleg Nesterov <oleg@redhat.com>
> >CC: Andy Lutomirski <luto@amacapital.net>
> >CC: Pavel Emelyanov <xemul@parallels.com>
> >CC: Serge E. Hallyn <serge.hallyn@ubuntu.com>
> >CC: Alexei Starovoitov <ast@kernel.org>
> >CC: Daniel Borkmann <daniel@iogearbox.net>
> [...]
> >diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
> >index dc9b464..58ae9f4 100644
> >--- a/kernel/bpf/syscall.c
> >+++ b/kernel/bpf/syscall.c
> >@@ -586,6 +586,44 @@ free_prog:
> >  	return err;
> >  }
> >
> >+static int bpf_prog_dump(union bpf_attr *attr, union bpf_attr __user *uattr)
> >+{
> >+	int ufd = attr->prog_fd;
> >+	struct fd f = fdget(ufd);
> >+	struct bpf_prog *prog;
> >+	int ret = -EINVAL;
> >+
> >+	prog = get_prog(f);
> >+	if (IS_ERR(prog))
> >+		return PTR_ERR(prog);
> >+
> >+	/* For now, let's refuse to dump anything that isn't a seccomp program.
> >+	 * Other program types have support for maps, which our current dump
> >+	 * code doesn't support.
> >+	 */
> >+	if (prog->type != BPF_PROG_TYPE_SECCOMP)
> >+		goto out;
> 
> Yep, also when you start adding helper calls (next to map objects) you'd
> need to undo kernel pointers that the verifier sets here.

Good point, I'll add that to the comment as well.

Tycho

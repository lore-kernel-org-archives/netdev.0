From: Tycho Andersen <tycho.andersen@canonical.com>
Subject: c/r of seccomp filters via underlying eBPF
Date: Fri,  4 Sep 2015 10:04:18 -0600
Message-ID: <1441382664-17437-1-git-send-email-tycho.andersen@canonical.com>
Cc: Will Drewry <wad@chromium.org>, Oleg Nesterov <oleg@redhat.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Pavel Emelyanov <xemul@parallels.com>,
	"Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Kees Cook <keescook@chromium.org>,
	Alexei Starovoitov <ast@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Here is a set that enables checkpoint restore of the underlying eBPF programs
that power seccomp filters via the API we discussed several months ago. A few
notes:

* We expose prog_id in the ebpf dump as the pointer to the ebpf program in
  kernel memory, since this is unique. I'm not sure if this is safe. The goal
  of exposing prog_id is to enable userspace to figure out how the seccomp
  filters are inherited (i.e. is the filter a result of a fork() or an
  identical filter installed). This is relevant because
  SECCOMP_FILTER_FLAG_TSYNC depends on this ancestry.

* I'm not sure what the fd argument to seccomp() should look like in the
  SECCOMP_FILTER_FLAG_EBPF case: it seems ugly either as &fd or fd; any
  thoughts on this are welcome.

* Please double check the first patch. I'm not too framiliar with eBPF, so this
  is mostly monkey see monkey do.

* The last patch is something I discovered while testing this set (I couldn't
  re-import some filters). I'm not sure if this is indicitave of a wider bug or
  if the fix is even correct but it Works For Me.

Thoughts welcome,

Tycho

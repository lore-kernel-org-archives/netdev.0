From: Sargun Dhillon <sargun@sargun.me>
Subject: [PATCH net-next v7 0/2] bpf: add bpf_probe_write_user helper &
 example
Date: Mon, 25 Jul 2016 05:54:29 -0700
Message-ID: <20160725125426.GA15045@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexei.starovoitov@gmail.com, daniel@iogearbox.net
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series contains two patches that add support for a probe_write
helper to BPF programs. This allows them to manipulate user memory during
the course of tracing. The second patch in the series has an example that
uses it, in one the intended ways to divert execution.

Thanks to Alexei Starovoitov, and Daniel Borkmann for being patient, review, and 
helping me get familiar with the code base. I've made changes based on their 
recommendations.

This helper should be considered for experimental usage and debugging, so we
print a warning to dmesg when it is along with the command and pid when someone
tries to install a proglet that uses it. A follow-up patchset will contain a
mechanism to verify the safety of the probe beyond what was done by hand.
----
v1->v2: restrict writing to user space, as opposed to globally v2->v3: Fixed
        formatting issues v3->v4: Rename copy_to_user -> bpf_probe_write
        Simplify checking of whether or not it's safe to write
        Add warnings to dmesg
v4->v5: Raise warning level
        Cleanup location of warning code
        Make test fail when helper is broken
v5->v6: General formatting cleanup
        Rename bpf_probe_write -> bpf_probe_write_user
v6->v7: More formatting cleanup.
        Clarifying a few comments
	Clarified log message

Sargun Dhillon (2):
  bpf: Add bpf_probe_write_user BPF helper to be called in tracers
  samples/bpf: Add test/example of using bpf_probe_write_user bpf helper

 include/uapi/linux/bpf.h                 | 10 ++++
 kernel/trace/bpf_trace.c                 | 45 ++++++++++++++++++
 samples/bpf/Makefile                     |  4 ++
 samples/bpf/bpf_helpers.h                |  2 +
 samples/bpf/test_probe_write_user_kern.c | 52 +++++++++++++++++++++
 samples/bpf/test_probe_write_user_user.c | 78 ++++++++++++++++++++++++++++++++
 6 files changed, 191 insertions(+)
 create mode 100644 samples/bpf/test_probe_write_user_kern.c
 create mode 100644 samples/bpf/test_probe_write_user_user.c

-- 
2.7.4

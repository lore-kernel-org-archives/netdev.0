From: Sargun Dhillon <sargun@sargun.me>
Subject: [PATCH net-next v6 0/2] bpf: add bpf_probe_write_user helper &
 example
Date: Sat, 23 Jul 2016 20:22:04 -0700
Message-ID: <20160724032201.GA1631@ircssh.c.rugged-nimbus-611.internal>
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

Thanks to Alexei Starovoitov, and Daniel Borkmann for review, I've made
changes based on their recommendations. 

This helper should be considered experimental, so we print a warning
to dmesg when it is along with the command and pid. A follow-up patchset
will contain a mechanism to verify the safety of the probe beyond what
was done by hand.


Sargun Dhillon (2):
  bpf: Add bpf_probe_write_user BPF helper to be called in tracers
  samples/bpf: Add test/example of using bpf_probe_write_user bpf helper

 include/uapi/linux/bpf.h                 | 10 ++++
 kernel/trace/bpf_trace.c                 | 48 ++++++++++++++++++++
 samples/bpf/Makefile                     |  4 ++
 samples/bpf/bpf_helpers.h                |  2 +
 samples/bpf/test_probe_write_user_kern.c | 52 +++++++++++++++++++++
 samples/bpf/test_probe_write_user_user.c | 78 ++++++++++++++++++++++++++++++++
 6 files changed, 194 insertions(+)
 create mode 100644 samples/bpf/test_probe_write_user_kern.c
 create mode 100644 samples/bpf/test_probe_write_user_user.c

-- 
2.7.4

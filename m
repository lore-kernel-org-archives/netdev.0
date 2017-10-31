From: Josef Bacik <josef@toxicpanda.com>
Subject: [PATCH 0/2][v2] Add the ability to do BPF directed error injection
Date: Tue, 31 Oct 2017 11:45:55 -0400
Message-ID: <1509464757-2222-1-git-send-email-josef@toxicpanda.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, ast@kernel.org, kernel-team@fb.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

v1->v2:
- moved things around to make sure that bpf_override_return could really only be
  used for an ftrace kprobe.
- killed the special return values from trace_call_bpf.
- renamed pc_modified to bpf_kprobe_state so bpf_override_return could tell if
  it was being called from an ftrace kprobe context.
- reworked the logic in kprobe_perf_func to take advantage of bpf_kprobe_state.
- updated the test as per Alexei's review.

A lot of our error paths are not well tested because we have no good way of
injecting errors generically.  Some subystems (block, memory) have ways to
inject errors, but they are random so it's hard to get reproduceable results.

With BPF we can add determinism to our error injection.  We can use kprobes and
other things to verify we are injecting errors at the exact case we are trying
to test.  This patch gives us the tool to actual do the error injection part.
It is very simple, we just set the return value of the pt_regs we're given to
whatever we provide, and then override the PC with a dummy function that simply
returns.

Right now this only works on x86, but it would be simple enough to expand to
other architectures.  Thanks,

Josef

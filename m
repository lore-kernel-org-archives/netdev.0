From: Josef Bacik <josef@toxicpanda.com>
Subject: [PATCH 0/2] Add the ability to do BPF directed error injection
Date: Mon, 30 Oct 2017 17:19:33 -0400
Message-ID: <1509398375-11927-1-git-send-email-josef@toxicpanda.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, ast@kernel.org, kernel-team@fb.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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

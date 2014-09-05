From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: bpf: make eBPF interpreter images
 read-only
Date: Fri, 05 Sep 2014 12:03:09 -0700 (PDT)
Message-ID: <20140905.120309.442605076285121829.davem@davemloft.net>
References: <aa5126f747594d768e0c518189a13e8674ad8ee5.1409690486.git.hannes@stressinduktion.org>
	<2bf2e54282097642db88e2b596b06a9ac3742883.1409690849.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	spender@grsecurity.net, dborkman@redhat.com, ast@plumgrid.com,
	keescook@chromium.org
To: hannes@stressinduktion.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2bf2e54282097642db88e2b596b06a9ac3742883.1409690849.git.hannes@stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Tue,  2 Sep 2014 22:53:44 +0200

> From: Daniel Borkmann <dborkman@redhat.com>
> 
> With eBPF getting more extended and exposure to user space is on it's way,
> hardening the memory range the interpreter uses to steer its command flow
> seems appropriate.  This patch moves the to be interpreted bytecode to
> read-only pages.
> 
> In case we execute a corrupted BPF interpreter image for some reason e.g.
> caused by an attacker which got past a verifier stage, it would not only
> provide arbitrary read/write memory access but arbitrary function calls
> as well. After setting up the BPF interpreter image, its contents do not
> change until destruction time, thus we can setup the image on immutable
> made pages in order to mitigate modifications to that code. The idea
> is derived from commit 314beb9bcabf ("x86: bpf_jit_comp: secure bpf jit
> against spraying attacks").
> 
> This is possible because bpf_prog is not part of sk_filter anymore.
> After setup bpf_prog cannot be altered during its life-time. This prevents
> any modifications to the entire bpf_prog structure (incl. function/JIT
> image pointer).
> 
> Every eBPF program (including classic BPF that are migrated) have to call
> bpf_prog_select_runtime() to select either interpreter or a JIT image
> as a last setup step, and they all are being freed via bpf_prog_free(),
> including non-JIT. Therefore, we can easily integrate this into the
> eBPF life-time, plus since we directly allocate a bpf_prog, we have no
> performance penalty.
> 
> Tested with seccomp and test_bpf testsuite in JIT/non-JIT mode and manual
> inspection of kernel_page_tables.  Brad Spengler proposed the same idea
> via Twitter during development of this patch.
> 
> Joint work with Hannes Frederic Sowa.
> 
> Suggested-by: Brad Spengler <spender@grsecurity.net>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied, thanks.

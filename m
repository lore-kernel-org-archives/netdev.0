From: Aurelien Jarno <aurelien@aurel32.net>
Subject: Re: [PATCH 6/6] MIPS: net: BPF: Introduce BPF ASM helpers
Date: Thu, 13 Aug 2015 22:42:46 +0200
Message-ID: <20150813204246.GA24857@aurel32.net>
References: <1433415376-20952-1-git-send-email-markos.chandras@imgtec.com>
 <1433415376-20952-7-git-send-email-markos.chandras@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-mips@linux-mips.org, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <ast@plumgrid.com>,
        Daniel Borkmann <dborkman@redhat.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        linux-kernel@vger.kernel.org, debian-kernel@lists.debian.org
To: Markos Chandras <markos.chandras@imgtec.com>
Return-path: <linux-mips-bounce@linux-mips.org>
Content-Disposition: inline
In-Reply-To: <1433415376-20952-7-git-send-email-markos.chandras@imgtec.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

On 2015-06-04 11:56, Markos Chandras wrote:
> This commit introduces BPF ASM helpers for MIPS and MIPS64 kernels.
> The purpose of this patch is to twofold:
> 
> 1) We are now able to handle negative offsets instead of either
> falling back to the interpreter or to simply not do anything and
> bail out.
> 
> 2) Optimize reads from the packet header instead of calling the C
> helpers
> 
> Because of this patch, we are now able to get rid of quite a bit of
> code in the JIT generation process by using MIPS optimized assembly
> code. The new assembly code makes the test_bpf testsuite happy with
> all 60 test passing successfully compared to the previous
> implementation where 2 tests were failing.
> Doing some basic analysis in the results between the old
> implementation and the new one we can obtain the following
> summary running current mainline on an ER8 board (+/- 30us delta is
> ignored to prevent noise from kernel scheduling or IRQ latencies):
> 
> Summary: 22 tests are faster, 7 are slower and 47 saw no improvement
> 
> with the most notable improvement being the tcpdump tests. The 7 tests
> that seem to be a bit slower is because they all follow the slow path
> (bpf_internal_load_pointer_neg_helper) which is meant to be slow so
> that's not a problem.
> 
> Cc: netdev@vger.kernel.org
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Alexei Starovoitov <ast@plumgrid.com>
> Cc: Daniel Borkmann <dborkman@redhat.com>
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Cc: linux-kernel@vger.kernel.org
> Signed-off-by: Markos Chandras <markos.chandras@imgtec.com>
> ---
> I have uploaded the script and the bpf result files in my LMO webspace
> in case you want to have a look. I didn't paste them in here because they
> are nearly 200 lines. Simply download all 3 files and run './bpf_analysis.py'

This patch relies on R2 instructions, and thus the Linux kernel fails to
build when targetting non-R2 CPUs. See for example:

https://buildd.debian.org/status/fetch.php?pkg=linux&arch=mipsel&ver=4.2%7Erc6-1%7Eexp1&stamp=1439480000

-- 
Aurelien Jarno                          GPG: 4096R/1DDD8C9B
aurelien@aurel32.net                 http://www.aurel32.net
